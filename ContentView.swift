import SwiftUI
import WebKit
import AppKit
import UniformTypeIdentifiers

// MARK: - AppState
class AppState: ObservableObject {
    @AppStorage("downloadDirectory") var downloadDirectory: String = ""
    @AppStorage("customSiteUrl") var customSiteUrl: String = "https://www.google.com/search?tbm=isch&q=mac+folder+icon"
    @Published var webUrl: URL = URL(string: "https://macosicons.com/")!
}

// MARK: - VisualEffectView
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .sidebar
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - MainView
enum NavigationItem: Hashable {
    case iconChanger
    case settings
    case whatsNew
    case about
    case credits
}

struct ContentView: View {
    @AppStorage("themePreference") var themePreference: Int = 0
    @State private var selection: NavigationItem? = .iconChanger
    
    var colorScheme: ColorScheme? {
        if themePreference == 1 { return .light }
        if themePreference == 2 { return .dark }
        return nil
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("App Management")) {
                    NavigationLink(destination: IconChangerView(), tag: .iconChanger, selection: $selection) {
                        Label("Icon Changer", systemImage: "wand.and.stars")
                    }
                    NavigationLink(destination: SettingsView(), tag: .settings, selection: $selection) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                Section(header: Text("Information")) {
                    NavigationLink(destination: WhatsNewView(), tag: .whatsNew, selection: $selection) {
                        Label("What's New", systemImage: "sparkles")
                    }
                    NavigationLink(destination: AboutView(), tag: .about, selection: $selection) {
                        Label("About", systemImage: "info.circle")
                    }
                    NavigationLink(destination: CreditsView(), tag: .credits, selection: $selection) {
                        Label("Credits", systemImage: "person.2")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)
            
            IconChangerView()
        }
        .preferredColorScheme(colorScheme)
        .frame(minWidth: 1000, minHeight: 650)
    }
}

// MARK: - IconChangerView
struct IconChangerView: View {
    @StateObject private var appState = AppState()
    @State private var targetPath: String?
    @State private var statusMessage: String = "Drop an App or File here to start"
    @State private var refreshId: UUID = UUID()

    var body: some View {
        HStack(spacing: 0) {
            // Left Panel: Drop Zone
            VStack {
                Text("Target")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                if let target = targetPath {
                    Text((target as NSString).lastPathComponent)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .font(.caption)
                    
                    VStack {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: target))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding()
                            .shadow(radius: 10)
                            .id(refreshId)
                        
                        Text("Drag an image here to apply")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Button("Clear Target") {
                        withAnimation {
                            targetPath = nil
                            statusMessage = "Drop an App or File here to start"
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.top)
                    
                    Button("Restore Original Icon") {
                        if NSWorkspace.shared.setIcon(nil, forFile: target, options: []) {
                            statusMessage = "Icon restored!"
                            refreshId = UUID()
                        } else {
                            statusMessage = "Failed to restore icon."
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 5)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.secondary.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .frame(width: 150, height: 150)
                            .background(Color.secondary.opacity(0.1).cornerRadius(15))
                        
                        VStack {
                            Image(systemName: "square.and.arrow.down")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Drop File/.app Here")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                        }
                    }
                    .padding()
                }

                Spacer()
                
                Button("Refresh Dock") {
                    let task = Process()
                    task.launchPath = "/usr/bin/killall"
                    task.arguments = ["Dock"]
                    task.launch()
                    statusMessage = "Dock refreshed!"
                }
                .buttonStyle(.link)
                .padding(.bottom, 5)

                Text(statusMessage)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                    .padding(.horizontal)
            }
            .frame(width: 260, height: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
            .onDrop(of: [.fileURL, .image, .url], isTargeted: nil) { providers in
                if let target = targetPath {
                    for provider in providers {
                        if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                                if let data = data, let image = NSImage(data: data) {
                                    DispatchQueue.main.async {
                                        applyImage(image, to: target)
                                    }
                                }
                            }
                            return true
                        }
                    }
                }
                
                if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }) {
                    _ = provider.loadObject(ofClass: URL.self) { url, _ in
                        if let url = url {
                            DispatchQueue.main.async {
                                if let target = targetPath, 
                                   ["png", "jpg", "jpeg", "icns"].contains(url.pathExtension.lowercased()) {
                                    if let image = NSImage(contentsOf: url) {
                                        applyImage(image, to: target)
                                    }
                                } else {
                                    withAnimation {
                                        self.targetPath = url.path
                                        self.statusMessage = "Ready for \((url.path as NSString).lastPathComponent)"
                                    }
                                    let name = (url.path as NSString).lastPathComponent.replacingOccurrences(of: ".app", with: "")
                                    if let searchUrl = URL(string: "https://macosicons.com/?search=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name)") {
                                        self.appState.webUrl = searchUrl
                                    }
                                }
                            }
                        }
                    }
                    return true
                }
                
                if let target = targetPath, let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
                    _ = provider.loadObject(ofClass: URL.self) { url, _ in
                        if let url = url {
                            DispatchQueue.main.async {
                                if let image = NSImage(contentsOf: url) {
                                    applyImage(image, to: target)
                                }
                            }
                        }
                    }
                    return true
                }
                return false
            }
            
            Divider()

            // Right Panel: Browser
            VStack(spacing: 0) {
                HStack(spacing: 15) {
                    Menu("Applications ▾") {
                        Button("macOSIcons") {
                            var name = ""
                            if let target = targetPath {
                                name = (target as NSString).lastPathComponent.replacingOccurrences(of: ".app", with: "")
                            }
                            if name.isEmpty {
                                appState.webUrl = URL(string: "https://macosicons.com/")!
                            } else {
                                appState.webUrl = URL(string: "https://macosicons.com/?search=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name)")!
                            }
                        }
                        Button("Icons8") { appState.webUrl = URL(string: "https://icons8.com/icons/set/mac-app")! }
                        Button("IconArchive") { appState.webUrl = URL(string: "https://iconarchive.com/search?q=mac+app")! }
                        Button("Dribbble") { appState.webUrl = URL(string: "https://dribbble.com/search/mac-icon")! }
                        Button("IconScout") { appState.webUrl = URL(string: "https://iconscout.com/icons/mac-app")! }
                    }
                    .buttonStyle(.bordered)
                    
                    Menu("Files & Folders ▾") {
                        Button("Flaticon") { appState.webUrl = URL(string: "https://www.flaticon.com/search?word=mac%20folder")! }
                        Button("IconFinder") { appState.webUrl = URL(string: "https://www.iconfinder.com/search?q=mac+folder&price=free")! }
                        Button("DeviantArt") { appState.webUrl = URL(string: "https://www.deviantart.com/search?q=mac+folder+icons")! }
                        Button("Pinterest") { appState.webUrl = URL(string: "https://www.pinterest.com/search/pins/?q=mac%20folder%20icons")! }
                        Button("Freepik") { appState.webUrl = URL(string: "https://www.freepik.com/search?format=search&query=mac%20folder")! }
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Custom Site") {
                        if let url = URL(string: appState.customSiteUrl) {
                            appState.webUrl = url
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(10)
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
                
                WebView(appState: appState) { downloadUrl in
                    guard let target = targetPath else {
                        DispatchQueue.main.async { statusMessage = "Please drop a target file first!" }
                        return
                    }
                    DispatchQueue.main.async { statusMessage = "Applying icon..." }
                    
                    if let image = NSImage(contentsOf: downloadUrl) {
                        DispatchQueue.main.async { applyImage(image, to: target) }
                    } else {
                        DispatchQueue.main.async { statusMessage = "Invalid image file." }
                    }
                }
            }
        }
        .navigationTitle("Icon Changer")
    }
    
    private func applyImage(_ image: NSImage, to target: String) {
        let success = NSWorkspace.shared.setIcon(image, forFile: target, options: [])
        if success {
            statusMessage = "Icon successfully updated!"
            refreshId = UUID()
            if !appState.downloadDirectory.isEmpty {
                let saveDir = URL(fileURLWithPath: appState.downloadDirectory)
                let fileName = (target as NSString).lastPathComponent + "_\(UUID().uuidString.prefix(4)).png"
                let saveUrl = saveDir.appendingPathComponent(fileName)
                if let tiffData = image.tiffRepresentation,
                   let bitmapImage = NSBitmapImageRep(data: tiffData),
                   let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                    try? pngData.write(to: saveUrl)
                }
            }
        } else {
            statusMessage = "Failed to set icon. Check permissions."
        }
    }
}

// MARK: - SettingsView
struct SettingsView: View {
    @AppStorage("themePreference") var themePreference: Int = 0
    @AppStorage("customSiteUrl") var customSiteUrl: String = "https://www.google.com/search?tbm=isch&q=mac+folder+icon"
    @AppStorage("downloadDirectory") var downloadDirectory: String = ""

    var body: some View {
        Form {
            Section(header: Text("Appearance").font(.headline)) {
                Picker("Theme", selection: $themePreference) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 250)
                .padding(.bottom, 20)
            }
            
            Section(header: Text("Custom Site").font(.headline)) {
                Text("Set your own custom URL to browse for icons.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Custom URL", text: $customSiteUrl)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 400)
                    .padding(.bottom, 20)
            }
            
            Section(header: Text("Download Directory").font(.headline)) {
                Text("Where to permanently archive applied icons.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(downloadDirectory.isEmpty ? "Default (Temporary)" : downloadDirectory)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(width: 300, alignment: .leading)
                    
                    Button("Change") {
                        let panel = NSOpenPanel()
                        panel.canChooseFiles = false
                        panel.canChooseDirectories = true
                        panel.allowsMultipleSelection = false
                        if panel.runModal() == .OK, let url = panel.url {
                            downloadDirectory = url.path
                        }
                    }
                    if !downloadDirectory.isEmpty {
                        Button("Clear") { downloadDirectory = "" }
                    }
                }
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Settings")
    }
}

// MARK: - AboutView
struct AboutView: View {
    let currentVersion = "v1.1.2"
    @State private var latestVersion = "Checking..."
    @State private var updateAvailable = false
    @State private var updateAssetUrl: String?
    @State private var isUpdating = false
    @State private var updateStatus = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(nsImage: NSImage(named: "NSApplicationIcon") ?? NSImage())
                .resizable()
                .frame(width: 128, height: 128)
            
            Text("Icon Changer")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Version \(currentVersion)")
                .foregroundColor(.secondary)
            
            if latestVersion != "Checking..." {
                if updateAvailable {
                    VStack(spacing: 5) {
                        Text("Update Available: \(latestVersion)")
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                        
                        if isUpdating {
                            Text(updateStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ProgressView()
                                .padding(.top, 5)
                        } else {
                            Button("Auto Update") {
                                if let url = updateAssetUrl {
                                    performAutoUpdate(downloadUrl: url)
                                } else {
                                    // Fallback to github if no zip asset is found
                                    NSWorkspace.shared.open(URL(string: "https://github.com/wako69420/IconChanger/releases/latest")!)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } else {
                    Text("You're on the latest version.")
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
            
            Text("A utility hub for your Mac icons.\nDrag and drop customization directly from the web.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
                .padding(.top, 20)
                .frame(maxWidth: 600)
            
            HStack(spacing: 20) {
                Button("View on GitHub") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/wako69420/IconChanger")!)
                }
                Button("View Privacy Policy") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/wako69420/IconChanger/blob/main/PRIVACY.md")!)
                }
            }
            .padding(.top, 20)
            
            Spacer()
            
            Text("© 2026 wako69420")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
        .padding(.top, 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("About")
        .onAppear(perform: checkUpdates)
    }
    
    private func checkUpdates() {
        guard let url = URL(string: "https://api.github.com/repos/wako69420/IconChanger/releases/latest") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async { latestVersion = "Failed to check" }
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let tagName = json["tag_name"] as? String {
                
                var zipUrl: String? = nil
                if let assets = json["assets"] as? [[String: Any]] {
                    for asset in assets {
                        if let name = asset["name"] as? String, name.hasSuffix(".zip"),
                           let dlUrl = asset["browser_download_url"] as? String {
                            zipUrl = dlUrl
                            break
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.latestVersion = tagName
                    self.updateAvailable = tagName != currentVersion
                    self.updateAssetUrl = zipUrl
                }
            }
        }.resume()
    }
    
    private func performAutoUpdate(downloadUrl: String) {
        isUpdating = true
        updateStatus = "Downloading update..."
        
        let task = URLSession.shared.downloadTask(with: URL(string: downloadUrl)!) { localUrl, response, error in
            guard let localUrl = localUrl else {
                DispatchQueue.main.async {
                    self.updateStatus = "Download failed."
                    self.isUpdating = false
                }
                return
            }
            
            DispatchQueue.main.async { self.updateStatus = "Extracting..." }
            
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            let zipDest = tempDir.appendingPathComponent("update.zip")
            try? FileManager.default.moveItem(at: localUrl, to: zipDest)
            
            let appPath = Bundle.main.bundlePath
            
            let script = """
            #!/bin/bash
            cd "\(tempDir.path)"
            unzip -q update.zip
            sleep 1
            rm -rf "\(appPath)"
            mv "Icon Changer.app" "\(appPath)"
            open "\(appPath)"
            """
            
            let scriptUrl = tempDir.appendingPathComponent("update.sh")
            try? script.write(to: scriptUrl, atomically: true, encoding: .utf8)
            try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptUrl.path)
            
            DispatchQueue.main.async { self.updateStatus = "Restarting app..." }
            
            let process = Process()
            process.launchPath = "/bin/bash"
            process.arguments = [scriptUrl.path]
            process.launch()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApplication.shared.terminate(nil)
            }
        }
        task.resume()
    }
}

// MARK: - WhatsNewView
struct WhatsNewView: View {
    @State private var releaseNotes = "Loading latest release notes..."

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("What's New")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(releaseNotes)
                    .font(.body)
            }
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("What's New")
        .onAppear(perform: fetchReleaseNotes)
    }
    
    private func fetchReleaseNotes() {
        guard let url = URL(string: "https://api.github.com/repos/wako69420/IconChanger/releases/latest") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let body = json["body"] as? String else {
                DispatchQueue.main.async { releaseNotes = "Failed to load release notes." }
                return
            }
            DispatchQueue.main.async {
                self.releaseNotes = body
            }
        }.resume()
    }
}

// MARK: - CreditsView
struct CreditsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 30) {
                Text("Credits")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 10) {
                    Text("Lead Developer")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("wako69420")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Divider().frame(width: 200)
                
                VStack(spacing: 15) {
                    Text("Integrated Services")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    CreditRow(name: "macOSIcons", url: "https://macosicons.com", desc: "A massive community-driven repository of macOS icons.")
                    CreditRow(name: "Icons8", url: "https://icons8.com", desc: "High-quality design assets and Mac icons.")
                    CreditRow(name: "IconArchive", url: "https://iconarchive.com", desc: "Huge database of app and system icons.")
                    CreditRow(name: "Dribbble", url: "https://dribbble.com", desc: "Creative community for UI/UX app icons.")
                    CreditRow(name: "IconScout", url: "https://iconscout.com", desc: "High-quality vector app icons.")
                    CreditRow(name: "Flaticon", url: "https://flaticon.com", desc: "Great repository for minimal folder and UI icons.")
                    CreditRow(name: "IconFinder", url: "https://iconfinder.com", desc: "Search engine for premium and free icons.")
                    CreditRow(name: "DeviantArt", url: "https://deviantart.com", desc: "Community for artists and custom Mac folder icons.")
                    CreditRow(name: "Pinterest", url: "https://pinterest.com", desc: "Great for finding aesthetic folder icon packs.")
                    CreditRow(name: "Freepik", url: "https://freepik.com", desc: "High-quality graphics and folder vectors.")
                }
            }
            .padding(40)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Credits")
    }
}

struct CreditRow: View {
    let name: String
    let url: String
    let desc: String
    var body: some View {
        VStack {
            Text(name).font(.headline)
            Link(url, destination: URL(string: url)!)
                .font(.subheadline)
            Text(desc)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 5)
    }
}

// MARK: - WebView
struct WebView: NSViewRepresentable {
    @ObservedObject var appState: AppState
    var onDownload: (URL) -> Void

    func makeNSView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        if webView.url?.absoluteString != appState.webUrl.absoluteString {
            let request = URLRequest(url: appState.webUrl)
            webView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKDownloadDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                if url.pathExtension == "icns" || url.pathExtension == "png" || url.pathExtension == "zip" {
                    if url.pathExtension == "icns" {
                        decisionHandler(.cancel)
                        downloadAndCallback(url: url)
                        return
                    }
                }
            }
            if navigationAction.shouldPerformDownload {
                decisionHandler(.download)
                return
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if navigationResponse.canShowMIMEType {
                decisionHandler(.allow)
            } else {
                decisionHandler(.download)
            }
        }
        
        func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
            download.delegate = self
        }
        func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
            download.delegate = self
        }
        
        func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
            let targetURL: URL
            if !self.parent.appState.downloadDirectory.isEmpty {
                targetURL = URL(fileURLWithPath: self.parent.appState.downloadDirectory).appendingPathComponent(suggestedFilename)
            } else {
                let tempDir = FileManager.default.temporaryDirectory
                targetURL = tempDir.appendingPathComponent(suggestedFilename)
            }
            try? FileManager.default.removeItem(at: targetURL)
            completionHandler(targetURL)
        }
        
        func downloadDidFinish(_ download: WKDownload) {}
        
        private func downloadAndCallback(url: URL) {
            let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
                if let localURL = localURL {
                    if !self.parent.appState.downloadDirectory.isEmpty {
                        let saveUrl = URL(fileURLWithPath: self.parent.appState.downloadDirectory).appendingPathComponent(url.lastPathComponent)
                        try? FileManager.default.copyItem(at: localURL, to: saveUrl)
                        self.parent.onDownload(saveUrl)
                    } else {
                        self.parent.onDownload(localURL)
                    }
                }
            }
            task.resume()
        }
    }
}
