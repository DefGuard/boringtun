import Foundation
import Testing
import Network
@testable import NetExt

struct EndpointTests {
    let endpoint = Endpoint(host: "127.0.0.1", port: 8080)

    @Test("Check Endpoint initialiaser") func endpoint_init() {
        #expect(endpoint.host == "127.0.0.1")
        #expect(endpoint.port == 8080)
    }

    @Test("Check Endpoint initialisation from string") func endpoint_from_string() throws {
        let endpoint1 = try #require(Endpoint(from: "88.99.11.38:8080"))

        #expect(endpoint1.host == "88.99.11.38")
        #expect(endpoint1.port == 8080)

        let endpoint2 = try #require(Endpoint(from: "[fc00::0001]:8080"))

        #expect(endpoint2.host == "fc00::0001")
        #expect(endpoint2.port == 8080)

        let endpoint3 = try #require(Endpoint(from: "vpn.teonite.net:8080"))

        #expect(endpoint3.host == "vpn.teonite.net")
        #expect(endpoint3.port == 8080)
    }

    @Test("Check Endpoint encoding and decoding") func endpoint_coding() throws {
        let encoder = JSONEncoder()
        let json = try encoder.encode(endpoint)

        let decoder = JSONDecoder()
        let decoded_endpoint = try decoder.decode(Endpoint.self, from: json)

        #expect(endpoint.host == decoded_endpoint.host)
        #expect(endpoint.port == decoded_endpoint.port)
    }
}

struct IpAddrMaskTests {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    @Test func ipaddrmask_coding() throws {
        let ipv4 = try #require(IPv4Address("88.99.11.38"))
        let ipaddrmask_ipv4 = IpAddrMask(address: ipv4, cidr: 8)
        let json_ipv4 = try encoder.encode(ipaddrmask_ipv4)
        let decoded_ipv4 = try decoder.decode(IpAddrMask.self, from: json_ipv4)

        #expect(ipaddrmask_ipv4 == decoded_ipv4)

        let ipv6 = try #require(IPv6Address("fc00::dead:f00d"))
        let ipaddrmask_ipv6 = IpAddrMask(address: ipv6, cidr: 16)
        let json_ipv6 = try encoder.encode(ipaddrmask_ipv6)
        let decoded_ipv6 = try decoder.decode(IpAddrMask.self, from: json_ipv6)

        #expect(ipaddrmask_ipv6 == decoded_ipv6)
    }

    @Test("IPv4 mask", arguments: [
        0: "0.0.0.0",
        1: "128.0.0.0",
        2: "192.0.0.0",
        3: "224.0.0.0",
        4: "240.0.0.0",
        8: "255.0.0.0",
        9: "255.128.0.0",
        30: "255.255.255.252",
        31: "255.255.255.254",
        32: "255.255.255.255"
    ]) func ipaddrmask_mask_v4(_ cidr: UInt8, _ mask: String) throws {
        let ipv4 = try #require(IPv4Address("88.99.11.38"))
        let ipaddrmask_ipv4 = IpAddrMask(address: ipv4, cidr: cidr)
        let mask_ipv4 = ipaddrmask_ipv4.mask()
        #expect("\(mask_ipv4)" == mask)
    }

    @Test("IPv6 mask", arguments: [
        0: "::",
        1: "8000::",
        2: "c000::",
        3: "e000::",
        4: "f000::",
        126: "ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffc",
        127: "ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffe",
        128: "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff"
    ]) func ipaddrmask_mask_v6(_ cidr: UInt8, _ mask: String) throws {
        let ipv6 = try #require(IPv6Address("fc00::dead:f00d"))
        let ipaddrmask_ipv6 = IpAddrMask(address: ipv6, cidr: cidr)
        let mask_ipv6 = ipaddrmask_ipv6.mask()
        #expect("\(mask_ipv6)" == mask)
    }
}
