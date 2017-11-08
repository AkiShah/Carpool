import FirebaseCommunity
import CoreLocation
import PromiseKit

public enum API {
    public enum Error: Swift.Error {
        case notAuthorized
        case noChild
        case noChildren
        case noSuchTrip
        case decode
        case legAndTripAreNotRelated
        case invalidJsonType
    }

    static func auth() -> Promise<Void> {
        return firstly {
            PromiseKit.wrap(Auth.auth().signInAnonymously)
        }.then { fbuser in
            Database.fetch(path: "users/\(fbuser.uid)").then {
                (fbuser.uid, $0.string(for: "name"))
            }
        }.then { uid, name -> Void in
            if name != nil { return }
            Database.database().reference().child("users").child(uid).setValue([
                "name": "Anonymous Parent",
                "ctime": Date().timeIntervalSince1970
            ])
        }
    }

    /// returns the current list of trips, once
    public static func fetchTripsOnce(completion: @escaping (Result<[Trip]>) -> Void) {
        firstly {
            auth()
        }.then {
            Database.fetch(path: "trips")
        }.then { bar -> [String: [String: Any]] in
            guard let foo = bar.value as? [String: [String: Any]] else { throw API.Error.decode }
            return foo
        }.then {
            when(resolved: $0.map{ Trip.make(key: $0, json: $1) })
        }.then { results -> Void in
            var trips: [Trip] = []
            for case .fulfilled(let trip) in results { trips.append(trip) }

            if trips.isEmpty && !results.isEmpty {
                throw Error.noChildren
            }

            completion(.success(trips))
        }.catch {
            completion(.failure($0))
        }
    }

    public static func observeTrips(completion: @escaping (Result<[Trip]>) -> Void) {
        firstly {
            auth()
        }.then {
            let (promise, joint) = Promise<[Trip]>.joint()
            Database.database().reference().child("trips").observe(.value) { snapshot in
                guard let foo = snapshot.value as? [String: [String: Any]] else {
                    return completion(.failure(API.Error.noChildren))
                }
                when(fulfilled: foo.map{ Trip.make(key: $0, json: $1) }).join(joint)
            }
            return promise
        }.then {
            completion(.success($0))
        }.catch {
            completion(.failure($0))
        }
    }

    /// claims the initial leg by the current user, so pickUp leg is UNCLAIMED
    public static func createTrip(eventDescription desc: String, eventTime time: Date, eventLocation location: CLLocation?, completion: @escaping (Result<Trip>) -> Void) {
        firstly {
            fetchCurrentUser()
        }.then { user -> Void in
            guard let uid = Auth.auth().currentUser?.uid else {
                throw Error.notAuthorized
            }

            let geohash = location.flatMap{ Geohash(location: $0) }?.value

            var eventDict: [String: Any] = [
                "description": desc,
                "time": time.timeIntervalSince1970,
                "owner": [uid: user.name]
            ]
            eventDict["geohash"] = geohash
            let eventRef = Database.database().reference().child("events").childByAutoId()
            eventRef.setValue(eventDict)

            let tripRef = Database.database().reference().child("trips").childByAutoId()
            tripRef.setValue([
                "dropOff": [uid: user.name ?? "Anonymous Parent"],
                "event": [eventRef.key: eventDict],
                "owner": uid
            ])

            let event = Event(key: eventRef.key, description: desc, owner: user, time: time, location: geohash)
            let trip = Trip(key: tripRef.key, event: event, dropOff: Leg(driver: user), pickUp: nil, _children: [])
            completion(.success(trip))
        }.catch {
            completion(.failure($0))
        }
    }

    public static func add(child: Child, to trip: Trip) throws {
        Database.database().reference().child("trips").child(trip.key).child("children").updateChildValues([
            child.key: try child.json()
        ])
    }

    static func fetchCurrentUser() -> Promise<User> {
        return firstly {
            auth()
        }.then { () -> Promise<User> in
            guard let uid = Auth.auth().currentUser?.uid else {
                throw Error.notAuthorized
            }
            return Promise { fulfill, reject in
                fetchUser(id: uid, completion: { result in
                    switch result {
                    case .success(let user):
                        fulfill(user)
                    case .failure(let error):
                        reject(error)
                    }
                })
            }
        }
    }

    static func fetchUser(id uid: String) -> Promise<User> {
        return firstly {
            auth()
        }.then {
            Database.fetch(path: "users", uid)
        }.then { snap -> User in
            let name = (try? snap.childSnapshot(forPath: "name").string()) ?? "Anonymous Parent"
            let kids: [Child] = try snap.childSnapshot(forPath: "children").array()
            return User(key: uid, name: name, _children: kids)
        }
    }

    public static func fetchUser(id uid: String, completion: @escaping (Result<User>) -> Void) {
        firstly {
            fetchUser(id: uid)
        }.then {
            completion(.success($0))
        }.catch {
            completion(.failure($0))
        }
    }

    /// if there is no error, completes with nil
    public static func claimPickUp(trip: Trip, completion: @escaping (Swift.Error?) -> Void) {
        claim("pickUp", trip: trip, completion: completion)
    }

    /// if there is no error, completes with nil
    public static func claimDropOff(trip: Trip, completion: @escaping (Swift.Error?) -> Void) {
        claim("dropOff", trip: trip, completion: completion)
    }

    static func claim(_ key: String, trip: Trip, completion: @escaping (Swift.Error?) -> Void) {
        firstly {
            auth()
        }.then { _ -> Promise<User> in
            guard let uid = Auth.auth().currentUser?.uid else {
                throw Error.notAuthorized
            }
            return API.fetchUser(id: uid)
        }.then { user -> Void in
            Database.database().reference().child("trips").child(trip.key).updateChildValues([
                key: [user.key: user.name ?? "Anonymous Parent"]
            ])
            completion(nil)
        }.catch {
            completion($0)
        }
    }

    /// adds children to the logged in user
    /// if a child already exists with that name, returns the existing child
    public static func addChild(name: String, completion: @escaping (Result<Child>) -> Void) {
        firstly {
            fetchCurrentUser()
        }.then { user -> Child in
            if let child = user.children.first(where: { $0.name == name }) {
                return child
            } else {
                let ref1 = Database.database().reference().child("children").childByAutoId()
                ref1.setValue(["name": name])
                Database.database().reference().child("users").child(user.key).child("children").updateChildValues([
                    ref1.key: name
                ])
                return Child(key: ref1.key, name: name)
            }
        }.then {
            completion(.success($0))
        }.catch {
            completion(.failure($0))
        }
    }
}

public enum Result<T> {
    case success(T)
    case failure(Swift.Error)
}

extension DataSnapshot {
    func value<T: Decodable & Keyed>(key: String) throws -> T {
        guard let value = self.value else { throw API.Error.noChild }
        try checkIsValidJsonType(value)
        let data = try JSONSerialization.data(withJSONObject: value)
        var foo: T = try JSONDecoder().decode(T.self, from: data)
        foo.key = key
        return foo
    }

    func array<T: Decodable & Keyed>() throws -> [T] {
        guard let rawValues = self.value else { return [] }  // nothing there yet, which means empty array
        if rawValues is NSNull { return [] }  // nothing there yet, which means empty array
        guard let values = rawValues as? [String: Any] else { throw API.Error.noChildren }

        return try values.map {
            try checkIsValidJsonType($0.value)
            let data = try JSONSerialization.data(withJSONObject: $0.value)
            var foo: T = try JSONDecoder().decode(T.self, from: data)
            foo.key = $0.key
            return foo
        }
    }

    func string() throws -> String {
        guard let string = value as? String else { throw API.Error.invalidJsonType }
        return string
    }

    func string(for key: String) -> String? {
        guard let values = self.value as? [String: Any] else { return nil }
        return values[key] as? String
    }
}

extension Database {
    static func fetch(path keys: String...) -> Promise<DataSnapshot> {
        return Promise<DataSnapshot> { fulfill, reject in
            var ref = database().reference()
            for key in keys { ref = ref.child(key) }
            ref.observeSingleEvent(of: .value) { snapshot in
                fulfill(snapshot)
            }
        }
    }
}

protocol Keyed {
    var key: String! { get set }
}
