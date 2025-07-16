import NetworkExtension
import os

enum WireGuardTunnelError: Error {
    case invalidTunnelConfiguration
}

class PacketTunnelProvider: NEPacketTunnelProvider {

    private var logger = Logger(subsystem: "net.defguard.NetExt", category: "VPNExtension")

    private lazy var adapter: Adapter = {
        return Adapter(with: self)
    }()

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        self.logger.log("\(#function)")
        if let options = options {
            self.logger.log("Options: \(options)")
        }

        guard let protocolConfig = self.protocolConfiguration as? NETunnelProviderProtocol,
        let providerConfig = protocolConfig.providerConfiguration,
        let tunnelConfig = try? TunnelConfiguration.from(dictionary: providerConfig) else {
            completionHandler(WireGuardTunnelError.invalidTunnelConfiguration)
            return
        }

        // Keep 127.0.0.1 as remote address for WireGuard.
        let networkSettings = tunnelConfig.asNetworkSettings()
        self.setTunnelNetworkSettings(networkSettings) { error in
            self.logger.log("Set tunnel network settings returned \(error)")
            completionHandler(error)
            return
        }

        do {
            try self.adapter.start(tunnelConfiguration: tunnelConfig)
        } catch {
            // TODO: completionHandler(error)
            self.logger.log("Failed to start tunnel")
        }

        // No error.
        completionHandler(nil)
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        self.logger.log("\(#function)")
        // Add code here to start the process of stopping the tunnel.
        completionHandler()
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        self.logger.log("\(#function)")
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }

    override func sleep(completionHandler: @escaping () -> Void) {
        self.logger.log("\(#function)")
        // Add code here to get ready to sleep.
        completionHandler()
    }

    override func wake() {
        self.logger.log("\(#function)")
        // Add code here to wake up.
    }
}
