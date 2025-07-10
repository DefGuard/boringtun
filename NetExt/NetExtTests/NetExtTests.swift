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
    @Test func ipaddrmask_coding() throws {
        let address = try #require(IPv4Address("127.0.0.1"))
        let ipaddrmask = IpAddrMask(address: address, cidr: 8)

        let encoder = JSONEncoder()
        let json = try encoder.encode(ipaddrmask)

        let decoder = JSONDecoder()
        let decoded_address = try decoder.decode(IpAddrMask.self, from: json)

        #expect(ipaddrmask == decoded_address)
    }
}
