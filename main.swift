import SwiftUI

@main
struct IconChangerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandMenu("Tools") {
                Button("Refresh Dock") {
                    let task = Process()
                    task.launchPath = "/usr/bin/killall"
                    task.arguments = ["Dock"]
                    task.launch()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
                
                Button("Clear Temporary Downloads") {
                    let tempDir = FileManager.default.temporaryDirectory
                    if let urls = try? FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil) {
                        for url in urls where url.pathExtension == "png" || url.pathExtension == "icns" {
                            try? FileManager.default.removeItem(at: url)
                        }
                    }
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])
            }
            
            CommandGroup(replacing: .help) {
                Button("Icon Changer Documentation") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/wako69420/IconChanger#readme")!)
                }
                Divider()
                Button("Report a Bug") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/wako69420/IconChanger/issues/new?template=bug_report.md")!)
                }
                Button("Request a Feature") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/wako69420/IconChanger/issues/new?template=feature_request.md")!)
                }
            }
        }
    }
}
