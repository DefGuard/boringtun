import Foundation

final class Peer {
    var publicKey: KeyBytes
    var preSharedKey: KeyBytes?
    var endpoint: Endpoint?
    var lastHandshake: Date?
    var txBytes: UInt64?
    var rxBytes: UInt64?
    var persistentKeepAlive: UInt16?
    var allowedIPs = [IpAddrMask]()

    convenience init?(data: Data) {
        do {
            let key = try KeyBytes.fromBytes(bytes: data)
            self.init(publicKey: key)
        } catch {
            return nil
        }
    }

    init(publicKey: KeyBytes) {
        self.publicKey = publicKey
    }

    enum CodingKeys: String, CodingKey {
        case publicKey
    }
}

extension Peer: Decodable {
    convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let data = try values.decode(Data.self, forKey: .publicKey)
        let publicKey = try KeyBytes.fromBytes(bytes: data)
        self.init(publicKey: publicKey)
    }
}

extension Peer: Encodable {
    func encode(to encoder: Encoder) throws {
        var peer = encoder.container(keyedBy: CodingKeys.self)
        try peer.encode(publicKey.rawBytes(), forKey: .publicKey)
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
