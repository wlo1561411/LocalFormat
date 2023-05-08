//
//  ViewController.swift
//  LocalFormat
//
//  Created by Finn Wu on 2023/5/8.
//

import Cocoa

class ViewController: NSViewController {
    let key = "path"
    
    @IBOutlet weak var pathLabel: NSTextField!
    @IBOutlet weak var resultLabel: NSTextField!
    
    var savePath: String {
        UserDefaults.standard.string(forKey: key) ?? "There is no path."
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pathLabel.stringValue = savePath
    }

    @IBAction func AddPath(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["public.folder"]
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = false
        
        openPanel.begin { [unowned self] (result) in
            if result == NSApplication.ModalResponse.OK {
                let directoryPath = openPanel.url?.path
                if self.hasGitFolder(in: directoryPath) {
                    UserDefaults.standard.set(directoryPath, forKey: "path")
                    self.pathLabel.stringValue = savePath
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
    
    @IBAction func foramt(_ sender: NSButton) {
        findChangedSwiftFiles()
    }
    
    private func findChangedSwiftFiles() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.currentDirectoryURL = URL(fileURLWithPath: savePath)
        task.arguments = ["sh", "-c", """
            if [ -f "./format.sh" ]; then
                chmod +x ./format.sh
                ./format.sh
            else
                echo "format.sh not found in the current directory."
            fi
        """]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = outputPipe

        do {
            try task.run()
            task.waitUntilExit()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if let outputString = String(data: outputData, encoding: .utf8) {
                print("Output:\n\(outputString)")
            } else {
                print("Failed to read output")
            }
        } catch {
            print("Error running task: \(error)")
        }
    }
}

