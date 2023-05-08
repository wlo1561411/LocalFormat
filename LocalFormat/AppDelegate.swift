import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var menu: NSMenu!

  var window: NSWindow!

  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

  func applicationDidFinishLaunching(_: Notification) {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    guard let viewController = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else {
      fatalError("Unable to instantiate ViewController from the Main storyboard")
    }

    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    window.center()
    window.title = "Local Format"
    window.setFrameAutosaveName("Main Window")
    window.contentView = viewController.view
    window.makeKeyAndOrderFront(nil)

    let button = statusItem.button
    let image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
    button?.image = image

    statusItem.menu = menu
  }

  @IBAction
  func format(_: NSMenuItem) {
    try? Formatter.shared.findChangedSwiftFilesAndFormat()
  }

  @IBAction
  func quit(_: NSMenuItem) {
    NSApplication.shared.terminate(self)
  }

  func applicationWillTerminate(_: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
    true
  }
}
