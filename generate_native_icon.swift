import AppKit
import CoreGraphics

func createSquirclePath(in rect: CGRect, cornerRadius: CGFloat) -> NSBezierPath {
    let path = NSBezierPath()
    // A simplified squircle (rounded rect for now, macOS usually uses a continuous curve but this is close enough)
    path.appendRoundedRect(rect, xRadius: cornerRadius, yRadius: cornerRadius)
    return path
}

func generateIcon() -> NSImage {
    let size = CGSize(width: 1024, height: 1024)
    let image = NSImage(size: size)
    
    image.lockFocus()
    
    // Draw transparent background (already transparent by default, but just to be sure)
    NSColor.clear.set()
    NSRect(origin: .zero, size: size).fill()
    
    // Icon frame (macOS icons have some padding)
    let inset: CGFloat = 82 // Padding for standard squircle drop shadow
    let rect = NSRect(origin: CGPoint(x: inset, y: inset), size: CGSize(width: size.width - inset * 2, height: size.height - inset * 2))
    
    // Shadow
    let shadow = NSShadow()
    shadow.shadowBlurRadius = 40
    shadow.shadowOffset = CGSize(width: 0, height: -20)
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.4)
    shadow.set()
    
    // Path
    let path = createSquirclePath(in: rect, cornerRadius: 180)
    
    // Fill Gradient
    NSGraphicsContext.current?.saveGraphicsState()
    path.addClip()
    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),
        NSColor(calibratedRed: 0.0, green: 0.3, blue: 0.8, alpha: 1.0)
    ])
    gradient?.draw(in: rect, angle: -90)
    NSGraphicsContext.current?.restoreGraphicsState()
    
    // Draw stroke (subtle border)
    path.lineWidth = 4
    NSColor.white.withAlphaComponent(0.3).setStroke()
    path.stroke()
    
    // Clear shadow for next drawings
    NSShadow().set()
    
    // Draw SF Symbol in the center
    if let symbolImage = NSImage(systemSymbolName: "paintbrush.fill", accessibilityDescription: nil) {
        let symbolConfig = NSImage.SymbolConfiguration(pointSize: 400, weight: .regular)
        let configuredSymbol = symbolImage.withSymbolConfiguration(symbolConfig)
        
        if let configured = configuredSymbol {
            configured.isTemplate = true
            NSColor.white.set() // white tint
            let symbolRect = NSRect(
                x: size.width / 2 - 200,
                y: size.height / 2 - 200,
                width: 400,
                height: 400
            )
            configured.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1.0)
        }
    }
    
    image.unlockFocus()
    return image
}

let appPath = "/Users/chris/Downloads/Antigravity Folder/mac Icon changer/Icon Changer.app"
let newIcon = generateIcon()

let success = NSWorkspace.shared.setIcon(newIcon, forFile: appPath, options: [])
print("Set native icon success: \(success)")
