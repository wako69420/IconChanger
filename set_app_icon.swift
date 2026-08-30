import AppKit

let appPath = "/Users/chris/Downloads/Antigravity Folder/mac Icon changer/Icon Changer.app"
let imagePath = "/Users/chris/.gemini/antigravity/brain/f36bfdb2-1b2b-4573-ad62-b72142298364/icon_changer_app_icon_1788092099841.jpg"

if let image = NSImage(contentsOfFile: imagePath) {
    let success = NSWorkspace.shared.setIcon(image, forFile: appPath, options: [])
    print("Set icon success: \(success)")
} else {
    print("Could not load image")
}
