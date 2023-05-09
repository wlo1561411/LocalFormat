import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var menu: NSMenu!

    var window: NSWindow!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_: Notification) {
        setup()
        openWindow()
    }

    func setup() {
        setButtonImage(loading: false)
        statusItem.menu = menu
    }

    func openWindow() {
        let windowController = WindowController()
        windowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func setButtonImage(loading: Bool) {
        statusItem.button?.image = .init(
            systemSymbolName: loading ? "water.waves" : "play.fill",
            accessibilityDescription: nil)
    }

    @IBAction
    func addPath(_: NSMenuItem) {
        openWindow()
    }

    @IBAction
    func format(_: NSMenuItem) {
        do {
            setButtonImage(loading: true)
            try Entity.shared
                .findChangedSwiftFilesAndFormat(completion: { [unowned self] _ in
                    self.setButtonImage(loading: false)
                })
        }
        catch {
            self.setButtonImage(loading: false)
            print(error)
        }
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
