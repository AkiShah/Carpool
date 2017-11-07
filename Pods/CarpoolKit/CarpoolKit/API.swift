@_exported import FirebaseDatabase
@_exported import FirebaseAuth
import CoreLocation
import FirebaseAuth
import PromiseKit

public enum API {
    /// if `false` you should be showing the login
    public static var isAuthorized: Bool {
        return Auth.auth().currentUser != nil
    }

    public enum Error: Swift.Error {
        case notAuthorized
        case noChild
        case noChildren
        case noSuchTrip
        case decode
        case legAndTripAreNotRelated
    }

    /// returns the current list of trips, once
    public static func fetchTripsOnce(completion: @escaping (Result<[Trip]>) -> Void) {
        firstly {
            Database.fetch(path: "trips")
        }.then { bar -> [String: [String: Any]] in
            guard let foo = bar.value as? [String: [String: Any]] else { throw API.Error.decode }
            return foo
        }.then {
            when(fulfilled: $0.map{ Trip.make(key: $0, json: $1) })
        }.then {
            completion(.success($0))
        }.catch {
            completion(.failure($0))
        }
    }

    public static func observeTrips(completion: @escaping (Result<[Trip]>) -> Void) {
        Database.database().reference().child("trips").observe(.value) { snapshot in
            guard let foo = snapshot.value as? [String: [String: Any]] else {
                return completion(.failure(API.Error.noChildren))
            }
            firstly {
                when(fulfilled: foo.map{ Trip.make(key: $0, json: $1) })
            }.then {
                completion(.success($0))
            }.catch {
                completion(.failure($0))
            }
        }
    }

    /// claims the initial leg by the current user, so pickUp leg is UNCLAIMED
    public static func createTrip(eventDescription desc: String, eventTime time: Date, eventLocation location: CLLocation, completion: @escaping (Result<Trip>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return DispatchQueue.main.async {
                completion(.failure(Error.notAuthorized))
            }
        }

        let geohash = Geohash(location: location).value

        let eventDict: [String: Any] = [
            "location": geohash,
            "description": desc,
            "time": time.timeIntervalSince1970,
            "owner": uid
        ]
        let eventRef = Database.database().reference().child("events").childByAutoId()
        eventRef.setValuesForKeys(eventDict)

        API.fetchUser(id: uid) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let user):
                let tripRef = Database.database().reference().child("trips").childByAutoId()
                tripRef.setValuesForKeys([
                    "dropOff": [uid: user.name ?? "Anonymous Parent"],
                    "event": eventDict,
                    "owner": uid
                ])

                let event = Event(key: eventRef.key, description: desc, owner: user, time: time, geohash: geohash)
                let trip = Trip(key: tripRef.key, event: event, pickUp: nil, dropOff: Leg(driver: user))
                completion(.success(trip))
            }
        }
    }

    public static func fetchUser(id uid: String, completion: @escaping (Result<User>) -> Void) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snap in
            do {
                completion(.success(try snap.value(key: uid)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// if there is no error, completes with nil
    public static func claimPickUp(trip: Trip, completion: @escaping (Swift.Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return DispatchQueue.main.async {
                completion(Error.notAuthorized)
            }
        }
        API.fetchUser(id: uid) { result in
            switch result {
            case .success(let user):
                Database.database().reference().child("trips").child(trip.key).updateChildValues([
                    "pickUp": [user.key: user.name ?? "Anonymous Parent"]
                ])
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    /// if there is no error, completes with nil
    public static func claimDropOff(trip: Trip, completion: @escaping (Swift.Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return DispatchQueue.main.async {
                completion(Error.notAuthorized)
            }
        }
        API.fetchUser(id: uid) { result in
            switch result {
            case .success(let user):
                Database.database().reference().child("trips").child(trip.key).updateChildValues([
                    "dropOff": [user.key: user.name ?? "Anonymous Parent"]
                ])
                completion(nil)
            case .failure(let error):
                completion(error)
            }
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
        let data = try JSONSerialization.data(withJSONObject: value)
        var foo: T = try JSONDecoder().decode(T.self, from: data)
        foo.key = key
        return foo
    }

    func array<T: Decodable & Keyed>() throws -> [T] {
        guard let values = self.value as? [String: Any] else { throw API.Error.noChildren }

        return try values.map {
            let data = try JSONSerialization.data(withJSONObject: $0.value)
            var foo: T = try JSONDecoder().decode(T.self, from: data)
            foo.key = $0.key
            return foo
        }
    }
}

extension Database {
    static func fetch(path key: String) -> Promise<DataSnapshot> {
        return Promise<DataSnapshot> { fulfill, reject in
            database().reference().child(key).observeSingleEvent(of: .value) { snapshot in
                fulfill(snapshot)
            }
        }
    }
}

protocol Keyed {
    var key: String! { get set }
}
