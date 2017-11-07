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
    }

    static func auth() -> Promise<Void> {
        return PromiseKit.wrap(Auth.auth().signInAnonymously(completion:)).asVoid()
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
            when(fulfilled: $0.map{ Trip.make(key: $0, json: $1) })
        }.then {
            completion(.success($0))
        }.catch {
            completion(.failure($0))
        }
    }

    public static func observeTrips(completion: @escaping (Result<[Trip]>) -> Void) {
        firstly {
            auth()
        }.then {
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
    }

    /// claims the initial leg by the current user, so pickUp leg is UNCLAIMED
    public static func createTrip(eventDescription desc: String, eventTime time: Date, eventLocation location: CLLocation, completion: @escaping (Result<Trip>) -> Void) {
        firstly {
            auth()
        }.then { _ -> Void in
            guard let uid = Auth.auth().currentUser?.uid else {
                throw Error.notAuthorized
            }

            let geohash = Geohash(location: location).value

            let eventDict: [String: Any] = [
                "location": geohash,
                "description": desc,
                "time": time.timeIntervalSince1970,
                "owner": uid
            ]
            let eventRef = Database.database().reference().child("events").childByAutoId()
            eventRef.setValue(eventDict)

            API.fetchUser(id: uid) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let user):
                    let tripRef = Database.database().reference().child("trips").childByAutoId()
                    tripRef.setValue([
                        "dropOff": [uid: user.name ?? "Anonymous Parent"],
                        "event": eventDict,
                        "owner": uid
                    ])

                    let event = Event(key: eventRef.key, description: desc, owner: user, time: time, geohash: geohash)
                    let trip = Trip(key: tripRef.key, event: event, pickUp: nil, dropOff: Leg(driver: user))
                    completion(.success(trip))
                }
            }
        }.catch {
            completion(.failure($0))
        }
    }

    public static func fetchUser(id uid: String, completion: @escaping (Result<User>) -> Void) {
        firstly {
            auth()
        }.then {
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snap in
                do {
                    completion(.success(try snap.value(key: uid)))
                } catch {
                    completion(.failure(error))
                }
            }
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
        }.then { _ -> Void in
            guard let uid = Auth.auth().currentUser?.uid else {
                throw Error.notAuthorized
            }
            API.fetchUser(id: uid) { result in
                switch result {
                case .success(let user):
                    Database.database().reference().child("trips").child(trip.key).updateChildValues([
                        key: [user.key: user.name ?? "Anonymous Parent"]
                    ])
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        }.catch {
            completion($0)
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
