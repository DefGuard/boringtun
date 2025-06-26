//
//  ContentView.swift
//  NetExt
//
//  Created by Adam on 12/06/2025.
//

import SwiftUI
import NetworkExtension
import os

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button(action: startVPN) {
                Text("Start VPN")
            }
        }
        .padding()
    }

    private func startVPN() {
        guard let appId = Bundle.main.bundleIdentifier else { return }
        os_log("AppId \(appId)")
        var providerManager = NETunnelProviderManager()
        var isSaved = false

        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            os_log("loadAllFromPreferences \(managers?.count ?? 0)")
            guard error == nil else {
                // Handle error
                os_log("\(error)")
                return
            }
            if let tunnelManagers = managers {
                for (index, _) in tunnelManagers.enumerated() {
                    os_log("\(index)")
                }
            }

            if managers != nil {
                isSaved = true
            }
            providerManager = managers?.first ?? NETunnelProviderManager()
        }

        let tunnelProtocol = NETunnelProviderProtocol()
        tunnelProtocol.providerBundleIdentifier = "\(appId).VPNExtension"
        tunnelProtocol.serverAddress = "127.0.0.1:7301" // Optional, can be empty string
        //tunnelProtocol.providerConfiguration = ["configKey": configData] // Pass config data if needed

        providerManager.protocolConfiguration = tunnelProtocol
        providerManager.localizedDescription = "My Custom VPN"
        providerManager.isEnabled = true

        if !isSaved {
            providerManager.saveToPreferences { error in
                if let error = error {
                    // Handle error
                    os_log("Failed to save preferences: \(error)")
                }
            }
        }

        do {
            try providerManager.connection.startVPNTunnel()
        } catch {
            // Handle error
            os_log("Failed to start VPN: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
