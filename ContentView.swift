import SwiftUI
import WebKit
import AppKit
import UniformTypeIdentifiers

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

class AppState: ObservableObject {
    @AppStorage("downloadDirectory") var downloadDirectory: String = ""
    @Published var webUrl: URL = URL(string: "https://macosicons.com/")!
}

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Icon Changer", systemImage: "wand.and.stars")
                }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                
            DocumentationView()
                .tabItem {
                    Label("Documentation", systemImage: "text.book.closed")
                }
            
            CreditsView()
                .tabItem {
                    Label("Credits", systemImage: "person.2")
                }
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(nsImage: NSImage(named: "NSApplicationIcon") ?? NSImage())
                .resizable()
                .frame(width: 128, height: 128)
            
            Text("Icon Changer")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Version 1.0")
                .foregroundColor(.secondary)
            
            Text("Icon Changer is a native macOS application that allows you to seamlessly customize the icons of your files, folders, and applications with a single click or drag-and-drop. Designed for Apple Silicon and modern macOS, it integrates directly with the best icon repositories on the web.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
                .frame(maxWidth: 600)
            
            Spacer()
        }
        .padding(.top, 50)
    }
}

struct DocumentationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Documentation")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Group {
                    Text("How to use Icon Changer").font(.title2)
                    
                    Text("1. Target Selection")
                        .font(.headline)
                    Text("Drag the file or application you want to modify and drop it into the 'Target' zone on the left sidebar.")
                    
                    Text("2. Finding an Icon")
                        .font(.headline)
                    Text("Browse the built-in repositories on the right. You can switch between macOSIcons, Icons8, Flaticon, and others using the toolbar buttons.")
                    
                    Text("3. Applying an Icon")
                        .font(.headline)
                    Text("• **Drag & Drop**: Click and drag any image from the web view directly over the Target zone to apply it instantly.\n• **One-Click**: Click the download button on any .icns file to have it applied automatically.")
                    
                    Text("4. Troubleshooting")
                        .font(.headline)
                    Text("If the icon doesn't update in your Dock immediately, click the 'Refresh Dock' button at the bottom of the sidebar. To revert an icon to its system default, click 'Restore Original Icon'.")
                    
                    Text("5. Saving Icons")
                        .font(.headline)
                    Text("Click the Gear icon in the top right to set a Download Directory. Any icons you apply will be permanently saved to this folder for future use.")
                }
            }
            .padding(40)
        }
    }
}

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
                    Text("Wako")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Divider().frame(width: 200)
                
                VStack(spacing: 15) {
                    Text("Integrated Services")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    CreditRow(name: "macOSIcons", url: "https://macosicons.com", desc: "A massive community-driven repository of macOS icons. Thanks to the macOSIcons community and developers.")
                    CreditRow(name: "Icons8", url: "https://icons8.com", desc: "High-quality design assets and Mac icons.")
                    CreditRow(name: "Flaticon", url: "https://flaticon.com", desc: "Great repository for minimal folder and UI icons.")
                    CreditRow(name: "IconFinder", url: "https://iconfinder.com", desc: "Search engine for premium and free icons.")
                    CreditRow(name: "DeviantArt", url: "https://deviantart.com", desc: "Community for artists and custom Mac folder icons.")
                }
            }
            .padding(40)
        }
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

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var targetPath: String?
    @State private var statusMessage: String = "Drop an App or File here to start"
    @State private var refreshId: UUID = UUID()
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            // Left Sidebar: Drop Zone
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
            .frame(minWidth: 220, maxWidth: 260, maxHeight: .infinity)
            .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).ignoresSafeArea())
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

            // Right Area: Browser
            WebView(appState: appState) { downloadUrl in
                guard let target = targetPath else {
                    DispatchQueue.main.async {
                        statusMessage = "Please drop a target file first!"
                    }
                    return
                }
                DispatchQueue.main.async {
                    statusMessage = "Applying icon..."
                }
                
                if let image = NSImage(contentsOf: downloadUrl) {
                    DispatchQueue.main.async {
                        applyImage(image, to: target)
                    }
                } else {
                    DispatchQueue.main.async {
                        statusMessage = "Invalid image file."
                    }
                }
            }
            .frame(minWidth: 600, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
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
                    Button("Icons8") {
                        appState.webUrl = URL(string: "https://icons8.com/icons/set/mac-app")!
                    }
                    Button("Flaticon") {
                        appState.webUrl = URL(string: "https://www.flaticon.com/search?word=mac%20folder")!
                    }
                    Button("IconFinder") {
                        appState.webUrl = URL(string: "https://www.iconfinder.com/search?q=mac+folder&price=free")!
                    }
                    Button("DeviantArt") {
                        appState.webUrl = URL(string: "https://www.deviantart.com/search?q=mac+folder+icons")!
                    }
                    
                    Spacer()
                    
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gearshape")
                    }
                    .popover(isPresented: $showSettings, arrowEdge: .bottom) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Settings")
                                .font(.headline)
                            
                            Text("Download Directory:")
                            
                            HStack {
                                Text(appState.downloadDirectory.isEmpty ? "Default (Temporary)" : appState.downloadDirectory)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .frame(width: 200, alignment: .leading)
                                
                                Button("Change") {
                                    let panel = NSOpenPanel()
                                    panel.canChooseFiles = false
                                    panel.canChooseDirectories = true
                                    panel.allowsMultipleSelection = false
                                    
                                    if panel.runModal() == .OK, let url = panel.url {
                                        appState.downloadDirectory = url.path
                                    }
                                }
                            }
                            
                            if !appState.downloadDirectory.isEmpty {
                                Button("Reset to Default") {
                                    appState.downloadDirectory = ""
                                }
                                .padding(.top, 5)
                            }
                        }
                        .padding()
                        .frame(width: 350)
                    }
                }
            }
        }
    }
    
    private func applyImage(_ image: NSImage, to target: String) {
        let success = NSWorkspace.shared.setIcon(image, forFile: target, options: [])
        if success {
            statusMessage = "Icon successfully updated!"
            refreshId = UUID()
            
            // Save a copy if a custom directory is set
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
        
        func downloadDidFinish(_ download: WKDownload) {
        }
        
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
