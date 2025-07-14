import Foundation
import NetworkExtension

final class InterfaceConfiguration: Codable {
    var privateKey: String
    var addresses = [IpAddrMask]()
    var listenPort: UInt16?
    var mtu: UInt16?
    var dns = [IPAddress]()
    var dnsSearch = [String]()

    init(privateKey: String) {
        self.privateKey = privateKey
    }

    enum CodingKeys: String, CodingKey {
        case privateKey
    }

    func asNetworkSettings() -> NEPacketTunnelNetworkSettings {
        // Keep 127.0.0.1 as remote address for WireGuard.
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")

        let addrs_v4 = addresses.filter { $0.address is IPv4Address }
            .map { String(describing: $0.address) }
        let masks_v4 = addresses.filter { $0.address is IPv4Address }
            .map { String(describing: $0.mask()) }
        let ipv4Settings = NEIPv4Settings(addresses: addrs_v4, subnetMasks: masks_v4)

        let addrs_v6 = addresses.filter { $0.address is IPv6Address }
            .map { String(describing: $0.address) }
        let masks_v6 = addresses.filter { $0.address is IPv6Address }
            .map { NSNumber(value: $0.cidr) }
        let ipv6Settings = NEIPv6Settings(addresses: addrs_v6, networkPrefixLengths: masks_v6)

        networkSettings.ipv4Settings = ipv4Settings
        networkSettings.mtu = mtu as NSNumber?
        let dnsServers = dns.map { ip in String(describing: ip) }
        let dnsSettings = NEDNSSettings(servers: dnsServers)
        dnsSettings.searchDomains = dnsSearch
        networkSettings.dnsSettings = dnsSettings

        return networkSettings
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
