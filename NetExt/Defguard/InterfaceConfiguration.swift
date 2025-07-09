import Foundation
import Network

final class InterfaceConfiguration {
    var privateKey: KeyBytes
    var addresses = [IpAddrMask]()
    var listenPort: UInt16?
    var mtu: UInt16?
    var dns = [IPAddress]()
    var dnsSearch = [String]()

    convenience init?(data: Data) {
        do {
            let key = try KeyBytes.fromBytes(bytes: data)
            self.init(privateKey: key)
        } catch {
            return nil
        }
    }

    init(privateKey: KeyBytes) {
        self.privateKey = privateKey
    }

    enum CodingKeys: String, CodingKey {
        case privateKey
    }
}

extension InterfaceConfiguration: Decodable {
    convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let data = try values.decode(Data.self, forKey: .privateKey)
        let privateKey = try KeyBytes.fromBytes(bytes: data)
        self.init(privateKey: privateKey)
    }
}

extension InterfaceConfiguration: Encodable {
    func encode(to encoder: Encoder) throws {
        var interfaceConfiguration = encoder.container(keyedBy: CodingKeys.self)
        try interfaceConfiguration.encode(privateKey.rawBytes(), forKey: .privateKey)
    }
}

//extension InterfaceConfiguration: Equatable {
//    public static func == (lhs: InterfaceConfiguration, rhs: InterfaceConfiguration) -> Bool {
//        let lhsAddresses = lhs.addresses.filter { $0.address is IPv4Address } + lhs.addresses.filter { $0.address is IPv6Address }
//        let rhsAddresses = rhs.addresses.filter { $0.address is IPv4Address } + rhs.addresses.filter { $0.address is IPv6Address }
//
//        return lhs.privateKey == rhs.privateKey &&
//            lhsAddresses == rhsAddresses &&
//            lhs.listenPort == rhs.listenPort &&
//            lhs.mtu == rhs.mtu &&
//            lhs.dns == rhs.dns &&
//            lhs.dnsSearch == rhs.dnsSearch
//    }
//}
