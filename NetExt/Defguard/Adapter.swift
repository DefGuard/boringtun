//
//  Adapter.swift
//  VPNExtension
//
//  Created by Adam on 17/06/2025.
//

import Foundation
import NetworkExtension
import os

public class Adapter {
    /// Packet tunnel provider.
    private weak var packetTunnelProvider: NEPacketTunnelProvider?
    /// BortingTun tunnel
    private var tunnel: Tunnel?

    /// Designated initializer.
    /// - Parameter packetTunnelProvider: an instance of `NEPacketTunnelProvider`. Internally stored
    public init(with packetTunnelProvider: NEPacketTunnelProvider) {
        self.packetTunnelProvider = packetTunnelProvider
    }

    //    deinit {
    //        // Shutdown the tunnel
    //        if case .started(let handle, _) = self.state {
    //            wgTurnOff(handle)
    //        }
    //    }

    public func start(tunnelConfiguration: TunnelConfiguration) {
        // TODO: kill exising tunnel
        os_log("Initalizing Tunnel...")
        tunnel = Tunnel.init(
            privateKey: tunnelConfiguration.interface.privateKey,
            serverPublicKey: tunnelConfiguration.peers[0].publicKey,
            keepAlive: tunnelConfiguration.peers[0].persistentKeepAlive,
            index: 0
        )

        os_log("Sniffing packets...")
        readPackets()
    }

    func readPackets() {
        packetTunnelProvider?.packetFlow.readPacketObjects { packets in
            for packet in packets  {
                os_log("Received packet \(packet.data.count)")
                switch packet.direction {
                    case.any:
                        os_log("Any direction")
                    case .inbound:
//                        self.tunnel?.read(src: packet.data)
                        os_log("Inbound")
                    case .outbound:
//                        self.tunnel?.read(src: packet.data)
                        os_log("Outbound")
                    @unknown default:
                        os_log("Unknown direction")
                }
            }
            // Write packets unchanged ]:-)
            self.packetTunnelProvider?.packetFlow.writePacketObjects(packets)
            self.readPackets()
        }
    }
}
