import CoreLocation

let fakeUsers = [
    User(key: "0", name: "Akiva"),
    User(key: "1", name: "Akash"),
    User(key: "2", name: "Naina"),
    User(key: "3", name: "Riyazh"),
    User(key: "4", name: "Shannon"),
    User(key: "5", name: "Nathan"),
    User(key: "6", name: "Aleshia"),
    User(key: "7", name: "Max"),
    User(key: "8", name: "Ernesto"),
    User(key: "9", name: "Jess"),
    User(key: "10", name: "Josh"),
    User(key: "11", name: "Laurie"),
    User(key: "12", name: "Alex"),
    User(key: "13", name: "Gary"),
]

let fakeEvents = [
    Event(key: "0", description: "Take Johnny to band-camp", owner: fakeUsers.sample, time: Date(), geohash: "gbsuv"),
    Event(key: "1", description: "Visit Grandma in hospital", owner: fakeUsers.sample, time: Date(), geohash: "gbsuv"),
    Event(key: "2", description: "Take Arya to faceless men HQ", owner: fakeUsers.sample, time: Date(), geohash: "gbsuv"),
    Event(key: "3", description: "Dentist Appt. for Bill", owner: fakeUsers.sample, time: Date(), geohash: "gbsuv"),
    Event(key: "4", description: "Drop off Will at The-Upside-Down", owner: fakeUsers.sample, time: Date(), geohash: "gbsuv"),
]

var fakeTrips = fakeEvents.enumerated().map {
    Trip(key: "\($0.0)",
        event: $0.1,
        pickUp: fakeUsers.maybe.map(Leg.init),
        dropOff: fakeUsers.maybe.map(Leg.init))
}



extension Array {
    public var sample: Element {
        let n = Int(arc4random_uniform(UInt32(count)))
        return self[n]
    }

    var maybe: Element? {
        if arc4random() % 3 == 0 {
            return nil
        } else {
            return sample
        }
    }
}

