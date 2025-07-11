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
        let endpoint_from = try #require(Endpoint(from: "127.0.0.1:8080"))

        #expect(endpoint.host == endpoint_from.host)
        #expect(endpoint.port == endpoint_from.port)
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
}
