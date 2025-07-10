import Network

struct Endpoint: CustomStringConvertible, Codable {
    let host: NWEndpoint.Host
    let port: NWEndpoint.Port

    init(host: NWEndpoint.Host, port: NWEndpoint.Port) {
        self.host = host
        self.port = port
    }

    /// Custom initializer from String. Assume format "host:port".
    init?(from string: String) {
        let components = string.split(separator: ":")
        guard components.count == 2,
              let port = NWEndpoint.Port(String(components[1])) else {
            return nil
        }
        self.host = NWEndpoint.Host(String(components[0]))
        self.port = port
    }

    /// A textual representation of this instance. Required for `CustomStringConvertible`.
    var description: String {
        "\(host):\(port)"
    }

    enum CodingKeys: String, CodingKey {
        case host
        case port
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(host)", forKey: .host)
        try container.encode(port.rawValue, forKey: .port)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        host = try NWEndpoint.Host(values.decode(String.self, forKey: .host))
        port = try NWEndpoint.Port(rawValue: values.decode(UInt16.self, forKey: .port)) ?? 0
    }
}
