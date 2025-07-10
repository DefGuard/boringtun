import Foundation

final class Peer {
    var publicKey: KeyBytes
    var preSharedKey: KeyBytes?
    var endpoint: Endpoint?
    var lastHandshake: Date?
    var txBytes: UInt64 = 0
    var rxBytes: UInt64 = 0
    var persistentKeepAlive: UInt16?
    var allowedIPs = [IpAddrMask]()

    init(publicKey: KeyBytes, preSharedKey: KeyBytes? = nil, endpoint: Endpoint? = nil,
         lastHandshake: Date? = nil, txBytes: UInt64 = 0, rxBytes: UInt64 = 0,
         persistentKeepAlive: UInt16? = nil, allowedIPs: [IpAddrMask] = [IpAddrMask]()) {
        self.publicKey = publicKey
        self.preSharedKey = preSharedKey
        self.endpoint = endpoint
        self.lastHandshake = lastHandshake
        self.txBytes = txBytes
        self.rxBytes = rxBytes
        self.persistentKeepAlive = persistentKeepAlive
        self.allowedIPs = allowedIPs
    }

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
        case preSharedKey
        case endpoint
        case lastHandshake
        case txBytes
        case rxBytes
        case persistentKeepAlive
        case allowedIPs
    }
}

extension Peer: Decodable {
    convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let publicKeyData = try values.decode(Data.self, forKey: .publicKey)
        let publicKey = try KeyBytes.fromBytes(bytes: publicKeyData)

        let preSharedKeyData = try values.decode(Data.self, forKey: .preSharedKey)
        let preSharedKey = try KeyBytes.fromBytes(bytes: preSharedKeyData)

        let endpoint = try values.decode(Endpoint.self, forKey: .endpoint)

        let lastHandshake = try values.decode(Date.self, forKey: .lastHandshake)
        let txBytes = try values.decode(UInt64.self, forKey: .txBytes)
        let rxBytes = try values.decode(UInt64.self, forKey: .rxBytes)
        let persistentKeepAlive = try values.decode(UInt16.self, forKey: .persistentKeepAlive)
        let allowedIPs = try values.decode([IpAddrMask].self, forKey: .allowedIPs)

        self.init(
            publicKey: publicKey, preSharedKey: preSharedKey, endpoint: endpoint,
            lastHandshake: lastHandshake,
            txBytes: txBytes, rxBytes: rxBytes, persistentKeepAlive: persistentKeepAlive,
            allowedIPs: allowedIPs
        )
    }
}

extension Peer: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(publicKey.rawBytes(), forKey: .publicKey)
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
