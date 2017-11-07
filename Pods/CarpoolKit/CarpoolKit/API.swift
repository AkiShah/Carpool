import CoreLocation

private var globalCompletion: (([Trip]) -> Void)!

public enum API {

    public static var isAuthorized: Bool {
        return true
    }

    public static func fetchTripsOnce(completion: @escaping ([Trip]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completion(fakeTrips)
        }
    }

    public static func observeTrips(completion: @escaping ([Trip]) -> Void) {
        fetchTripsOnce(completion: completion)
        globalCompletion = completion
    }

    public static func createTrip(eventDescription: String, eventTime: Date, eventLocation: CLLocation, completion: @escaping (Trip) -> Void) {
        let event = Event(id: UUID().uuidString, description: eventDescription, time: eventTime, location: eventLocation)
        let leg1 = Leg(id: UUID().uuidString, driver: User.current)
        let leg2 = Leg(id: UUID().uuidString, driver: nil)
        let trip = Trip(id: UUID().uuidString, event: event, pickUp: leg1, dropOff: leg2)
        fakeTrips.insert(trip, at: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completion(trip)
            globalCompletion(fakeTrips)
        }
    }

    public static func update(user: User, name: String) {
        UserDefaults.standard.set(name, forKey: "username")
    }
}
