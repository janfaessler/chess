import SwiftUI

struct SettingsView: View {

    private var settings: EngineSettings { EngineSettings.shared }

    private let maxCores = ProcessInfo.processInfo.processorCount

    var body: some View {
        Form {
            Section("Engine") {
                Stepper(
                    "Cores: \(settings.coreCount)",
                    value: Binding(get: { settings.coreCount }, set: { settings.coreCount = $0 }),
                    in: 1...maxCores
                )
                .accessibilityIdentifier("settings-cores")

                Stepper(
                    "Lines: \(settings.lineCount)",
                    value: Binding(get: { settings.lineCount }, set: { settings.lineCount = $0 }),
                    in: 1...5
                )
                .accessibilityIdentifier("settings-lines")

                Stepper(
                    "Depth: \(settings.depth)",
                    value: Binding(get: { settings.depth }, set: { settings.depth = $0 }),
                    in: 1...30
                )
                .accessibilityIdentifier("settings-depth")

                Toggle(
                    "Debug logging",
                    isOn: Binding(get: { settings.debug }, set: { settings.debug = $0 })
                )
                .accessibilityIdentifier("settings-debug")
            }
        }
        .padding()
        .frame(width: 300)
    }
}
