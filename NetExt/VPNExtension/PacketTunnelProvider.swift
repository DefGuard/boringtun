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

        // FIXME: test configuration
        // Keep 127.0.0.1 as remote address for WireGuard.
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        let ipv4Settings = NEIPv4Settings(addresses: [ "192.168.3.4" ],
                                          subnetMasks: [ "255.255.255.0" ])
        ipv4Settings.includedRoutes = [ NEIPv4Route(destinationAddress: "192.168.3.0",
                                                    subnetMask: "255.255.255.0") ]
        networkSettings.ipv4Settings = ipv4Settings
        self.setTunnelNetworkSettings(networkSettings) { error in
            self.logger.log(level: .default, "Set tunnel network settings returned \(error)")
            os_log("Set tunnel network settings returned \(error)")
            completionHandler(error)
        }

        let interfaceConfiguration = InterfaceConfiguration(privateKey: KeyBytes.secret())
        let peer = PeerConfiguration(publicKey: KeyBytes.secret())
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
