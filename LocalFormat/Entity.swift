import Cocoa
import Foundation

class Entity {
    static let shared = Entity()

    private let key = "path"

    var savePath: String {
        UserDefaults.standard.string(forKey: key) ?? "There is no path."
    }

    func set(path: String) {
        UserDefaults.standard.set(path, forKey: "path")
    }

    func openPanel(completion: ((_ path: String?) -> Void)?) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["public.folder"]
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = true
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = false

        openPanel.begin { [unowned self] result in
            if result == NSApplication.ModalResponse.OK {
                let directoryPath = openPanel.url?.path
                if self.hasGitFolder(in: directoryPath) {
                    self.set(path: directoryPath ?? "")
                    completion?(self.savePath)
                }
                else {
                    completion?(nil)
                }
            }
        }
    }

    private func hasGitFolder(in path: String?) -> Bool {
        guard let path else { return false }
        let fileManager = FileManager.default
        let gitFolderPath = (path as NSString).appendingPathComponent(".git")
        return fileManager.fileExists(atPath: gitFolderPath)
    }

    func findChangedSwiftFilesAndFormat(completion: ((_ output: String?) -> Void)?) throws {
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
                print(matchPattern(input: outputString) ?? outputString)
                completion?(outputString)
            }
            else {
                throw NSError(domain: "0", code: 0, userInfo: ["text": "Failed to read output"])
            }
        }
        catch {
            throw NSError(domain: "1", code: 1, userInfo: ["text": "Error running task: \(error.localizedDescription)"])
        }
    }

    func matchPattern(input: String) -> String? {
        let pattern =
            "Format Swift file: (.*\\nRunning SwiftFormat...\\n)Reading config file at .*\\.swiftformat\\n(SwiftFormat completed in \\d+\\.\\d+s\\.\\n1/1 files formatted.)"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: [])
        else { return nil }

        let range = NSRange(location: 0, length: input.utf16.count)

        if let match = regex.firstMatch(in: input, options: [], range: range) {
            let firstPart = (input as NSString).substring(with: match.range(at: 1))
            let secondPart = (input as NSString).substring(with: match.range(at: 2))
            return firstPart + secondPart
        }

        return nil
    }
}
