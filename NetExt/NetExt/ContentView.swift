import SwiftUI
import NetworkExtension
import os

struct ContentView: View {
    @State private var tunnelConfig: TunnelConfiguration?;
    @State private var configName = "My Custom VPN"

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("VPN")
            Button(action: startVPN) {
                Text("Start")
            }
            Text("Config")
            TextField("Name:", text: $configName).border(.secondary)
            Button(action: loadConfig) {
                Text("Load Config")
            }
            Button(action: saveConfig) {
                Text("Save Config")
            }
            Divider()
            Text("Config details")
            if let config = Binding($tunnelConfig) {
                TextField("Name", text: config.name)
                let key = config.interface.privateKey.wrappedValue
                Text("Interface key: \(key)")
                List {
                    ForEach(config.peers, id: \.publicKey) { peer in
                        let key = peer.publicKey.wrappedValue
                        Text("Peer key: \(key)")
                    }
                }
            } else {
                Text("No config available")
            }
        }
        .padding()
    }

    private func startVPN() {
        guard let appId = Bundle.main.bundleIdentifier else {
            os_log("Failed to get AppId")
            return
        }
        os_log("AppId \(appId)")

        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            os_log("loadAllFromPreferences \(managers?.count ?? 0)")
            guard error == nil else {
                os_log("\(error)")
                return
            }
            if let tunnelManagers = managers {
                for (index, _) in tunnelManagers.enumerated() {
                    os_log("\(index)")
                }
            }

            let isSaved = managers != nil
            let providerManager = managers?.first ?? NETunnelProviderManager()

            let tunnelProtocol = NETunnelProviderProtocol()
            tunnelProtocol.providerBundleIdentifier = "\(appId).VPNExtension"
            tunnelProtocol.serverAddress = "" // "185.33.37.192:7301" // Optional, can be empty string
            //tunnelProtocol.providerConfiguration = ["configKey": configData] // Pass config data if needed

            providerManager.protocolConfiguration = tunnelProtocol
            providerManager.localizedDescription = configName
            providerManager.isEnabled = true

            if !isSaved {
                providerManager.saveToPreferences { error in
                    if let error = error {
                        os_log("Failed to save preferences: \(error)")
                    }
                }
            }

            do {
                try providerManager.connection.startVPNTunnel()
            } catch {
                os_log("Failed to start VPN: \(error)")
            }
        }
    }

    private func loadConfig() {
        if configName.isEmpty {
            os_log("Empty config name")
            return
        }
        guard let appId = Bundle.main.bundleIdentifier else {
            os_log("Failed to get AppId")
            return
        }
        NETunnelProviderManager.loadAllFromPreferences {
            managers,
            error in
            os_log("loadAllFromPreferences \(managers?.count ?? 0)")
            guard error == nil else {
                os_log("\(error)")
                return
            }
            guard let managers = managers else {
                return
            }
            for manager in managers {
                if manager.localizedDescription == configName {
                    os_log("Config found")
                    if let protocolConfiguration = (
                        manager as NETunnelProviderManager
                    ).protocolConfiguration as? NETunnelProviderProtocol,
                       let providerConfiguration = protocolConfiguration.providerConfiguration {
                        do {
                            tunnelConfig = try TunnelConfiguration.from(
                                dictionary: providerConfiguration
                            )
                            os_log("Converted to NETunnelProviderProtocol")
                        } catch {
                            os_log("Failed to convert to NETunnelProviderProtocol")
                        }
                    }
                }
            }
        }
    }

    private func saveConfig() {
        if configName.isEmpty {
            os_log("Empty config name")
            return
        }
        guard let appId = Bundle.main.bundleIdentifier else {
            os_log("Failed to get AppId")
            return
        }

        let privateKey = "PRIVATE KEY"
        let publicKey =  "PUBLIC KEY"
        let interfaceConfiguration = InterfaceConfiguration(privateKey: privateKey)
        let peer = Peer(publicKey: publicKey)
        let tunnelConfiguration = TunnelConfiguration(name: "Adam was here", interface: interfaceConfiguration, peers: [peer])
        guard let providerConfiguration = try? tunnelConfiguration.toDictionary() else {
            return
        }

        let tunnelProtocol = NETunnelProviderProtocol()
        tunnelProtocol.providerBundleIdentifier = "\(appId).VPNExtension"
        tunnelProtocol.serverAddress = ""
        tunnelProtocol.providerConfiguration = providerConfiguration

        let providerManager = NETunnelProviderManager()
        providerManager.protocolConfiguration = tunnelProtocol
        providerManager.localizedDescription = configName
        providerManager.isEnabled = true

        providerManager.saveToPreferences { error in
            if let error = error {
                os_log("Failed to save preferences: \(error)")
            } else {
                os_log("Config '\(configName)' saved to preferences")
            }
        }
    }
}

#Preview {
    ContentView()
}
