import Foundation

class Formatter {
  static let shared = Formatter()

  private let key = "path"

  var savePath: String {
    UserDefaults.standard.string(forKey: key) ?? "There is no path."
  }

  func set(path: String) {
    UserDefaults.standard.set(path, forKey: "path")
  }

  func findChangedSwiftFilesAndFormat() throws {
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
      }
      else {
        throw NSError(domain: "0", code: 0, userInfo: ["text": "Failed to read output"])
      }
    }
    catch {
      throw NSError(domain: "1", code: 1, userInfo: ["text": "Error running task: \(error.localizedDescription)"])
    }
  }
}
