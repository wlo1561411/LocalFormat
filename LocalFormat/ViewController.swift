import Cocoa

class WindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false)

        self.init(window: window)

        window.center()
        window.title = "Local Format"

        setup()
    }

    func setup() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard
            let viewController = storyboard
                .instantiateController(withIdentifier: "ViewController") as? ViewController
        else {
            fatalError("Unable to instantiate ViewController from the Main storyboard")
        }

        contentViewController = viewController
    }
}

class ViewController: NSViewController {
    @IBOutlet weak var pathLabel: NSTextField!

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pathLabel.stringValue = Entity.shared.savePath
    }

    @IBAction
    func AddPath(_: NSButton) {
        Entity.shared
            .openPanel { [unowned self] path in
                if let path {
                    self.pathLabel.stringValue = path
                }
                else {
                    self.showAlert(title: "錯誤", message: "選擇的目錄沒有包含 .git 文件夾。")
                }
            }
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
