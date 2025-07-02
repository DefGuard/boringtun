import Foundation

public struct Peer {
    public var publicKey: KeyBytes
    public var preSharedKey: KeyBytes?
    public var endpoint: Endpoint?
    public var lastHandshake: Date?
    public var txBytes: UInt64?
    public var rxBytes: UInt64?
    public var persistentKeepAlive: UInt16?
    public var allowedIPs = [IpAddrMask]()

    public init(publicKey: KeyBytes) {
        self.publicKey = publicKey
    }
}

//extension Peer: Equatable {
//    public static func == (lhs: Peer, rhs: Peer) -> Bool {
//        return lhs.publicKey == rhs.publicKey &&
//            lhs.preSharedKey == rhs.preSharedKey &&
//            Set(lhs.allowedIPs) == Set(rhs.allowedIPs) &&
//            lhs.endpoint == rhs.endpoint &&
//            lhs.persistentKeepAlive == rhs.persistentKeepAlive
//    }
//}

//extension Peer: Hashable {
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(publicKey)
//        hasher.combine(preSharedKey)
//        hasher.combine(Set(allowedIPs))
//        hasher.combine(endpoint)
//        hasher.combine(persistentKeepAlive)
//
//    }
//}
