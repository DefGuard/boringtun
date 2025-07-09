import Network

struct IpAddrMask {
    let address: IPAddress
    let cidr: UInt8

    init(address: IPAddress, cidr: UInt8) {
        self.address = address
        self.cidr = cidr
    }
}
