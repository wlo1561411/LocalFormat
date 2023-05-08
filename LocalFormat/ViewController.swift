import Cocoa

class ViewController: NSViewController {
  @IBOutlet weak var pathLabel: NSTextField!

  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    pathLabel.stringValue = Formatter.shared.savePath
  }

  @IBAction
  func AddPath(_: NSButton) {
    let openPanel = NSOpenPanel()
    openPanel.allowedFileTypes = ["public.folder"]
    openPanel.showsResizeIndicator = true
    openPanel.showsHiddenFiles = false
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    openPanel.canCreateDirectories = false

    openPanel.begin { [unowned self] result in
      if result == NSApplication.ModalResponse.OK {
        let directoryPath = openPanel.url?.path
        if self.hasGitFolder(in: directoryPath) {
          Formatter.shared.set(path: directoryPath ?? "")
          self.pathLabel.stringValue = Formatter.shared.savePath
        }
        else {
          self.showAlert(title: "錯誤", message: "選擇的目錄沒有包含 .git 文件夾。")
        }
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

  private func hasGitFolder(in path: String?) -> Bool {
    guard let path = path else { return false }
    let fileManager = FileManager.default
    let gitFolderPath = (path as NSString).appendingPathComponent(".git")
    return fileManager.fileExists(atPath: gitFolderPath)
  }
}
