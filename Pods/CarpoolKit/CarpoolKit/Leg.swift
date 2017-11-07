
public struct Leg: Codable {
    public let driver: User?

    public var isClaimed: Bool {
        return driver != nil
    }
}
