//
//  PacketTunnelProvider.swift
//  VPNExtension
//
//  Created by Adam on 12/06/2025.
//

import NetworkExtension
import os

class PacketTunnelProvider: NEPacketTunnelProvider {

    private var logger = Logger(subsystem: "net.defguard.NetExt", category: "VPNExtension")

    private lazy var adapter: Adapter = {
        return Adapter(with: self)
    }()

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        self.logger.log(level: .default, "\(#function)")
        os_log("\(#function)")

        // FIXME: this is a test configuration
        // Keep 127.0.0.1 as remote address for WireGuard.
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        let ipv4Settings = NEIPv4Settings(addresses: [ "10.6.0.10" ],
                                          subnetMasks: [ "255.255.255.255" ])
        ipv4Settings.includedRoutes = [
            NEIPv4Route(destinationAddress: "10.6.0.0", subnetMask: "255.255.255.0"),
            NEIPv4Route(destinationAddress: "10.4.0.0", subnetMask: "255.255.255.0"),
            NEIPv4Route(destinationAddress: "10.7.0.0", subnetMask: "255.255.0.0")
        ]
        networkSettings.ipv4Settings = ipv4Settings
        let dnsSettings = NEDNSSettings(servers: ["10.6.0.1"])
        networkSettings.dnsSettings = dnsSettings
        self.setTunnelNetworkSettings(networkSettings) { error in
            self.logger.log(level: .default, "Set tunnel network settings returned \(error)")
            os_log("Set tunnel network settings returned \(error)")
            completionHandler(error)
        }

        // This end's key
        guard let privateKey = try? KeyBytes.fromString(s: "==PRIVATE KEY==") else {
            os_log("Private key constructor failed")
            return
        }
        // The other end's key
        guard let publicKey = try? KeyBytes.fromString(s: "==PUBLIC KEY==") else {
            os_log("Public key constructor failed")
            return
        }
        let interfaceConfiguration = InterfaceConfiguration(privateKey: privateKey)
        let peer = PeerConfiguration(publicKey: publicKey)
        let tunnelConfiguration = TunnelConfiguration(name: "Adam was here", interface: interfaceConfiguration, peers: [peer])
        self.adapter.start(tunnelConfiguration: tunnelConfiguration)

        // No error.
        completionHandler(nil)
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        self.logger.log(level: .default, "\(#function)")
        os_log("\(#function)")
        // Add code here to start the process of stopping the tunnel.
        completionHandler()
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        self.logger.log(level: .default, "\(#function)")
        os_log("\(#function)")
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }

    override func sleep(completionHandler: @escaping () -> Void) {
        self.logger.log(level: .default, "\(#function)")
        os_log("\(#function)")
        // Add code here to get ready to sleep.
        completionHandler()
    }

    override func wake() {
        self.logger.log(level: .default, "\(#function)")
        os_log("\(#function)")
        // Add code here to wake up.
    }
}
