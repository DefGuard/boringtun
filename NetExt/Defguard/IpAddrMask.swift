import Network

public struct IpAddrMask {
    public let address: IPAddress
    public let cidr: UInt8

    init(address: IPAddress, cidr: UInt8) {
        self.address = address
        self.cidr = cidr
    }
}
