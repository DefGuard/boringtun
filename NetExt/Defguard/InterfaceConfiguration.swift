import Foundation
import Network

public struct InterfaceConfiguration {
    public var privateKey: KeyBytes
    public var addresses = [IpAddrMask]()
    public var listenPort: UInt16?
    public var mtu: UInt16?
    public var dns = [IPAddress]()
    public var dnsSearch = [String]()

    public init(privateKey: KeyBytes) {
        self.privateKey = privateKey
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
