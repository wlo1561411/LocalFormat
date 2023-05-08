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
}

