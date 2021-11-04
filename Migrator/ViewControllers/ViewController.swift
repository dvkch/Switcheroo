//
//  ViewController.swift
//  Migrator
//
//  Created by Stanislas Chevallier on 03/11/2021.
//

import Cocoa

class ViewController: NSViewController {

    // MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        representedObject = representedObject ?? Sitemap()
    }

    // MARK: Properties
    override var representedObject: Any? {
        didSet {
            updateContent()
        }
    }
    private var sitemap: Sitemap {
        get { representedObject as! Sitemap }
        set { representedObject = newValue }
    }
    private var isRunning: Bool = false {
        didSet {
            hostTextField.isEnabled = !isRunning
            startButton.isEnabled = !isRunning
        }
    }

    // MARK: Views
    @IBOutlet private var hostTextField: NSTextField!
    @IBOutlet private var startButton: NSButton!
    @IBOutlet private var tableView: NSTableView!

    // MARK: Actions
    @IBAction private func textfieldDidReturn(sender: AnyObject?) {
        startButtonTap(sender: sender)
    }

    @IBAction private func startButtonTap(sender: AnyObject?) {
        guard !isRunning else { return }

        guard let url = URL(string: hostTextField.stringValue),
              let host = url.host,
              ["http", "https"].contains(url.scheme?.lowercased() ?? "")
        else {
            NSAlert(error: AppError.invalidHost).runModal()
            return
        }
        
        isRunning = true
        
    }

    // MARK: Content
    private func updateContent() {
        tableView.reloadData()
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return sitemap.urls.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch tableColumn?.identifier.rawValue {
        case "path":
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PathCell"), owner: self)

        case "status":
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "StatusCell"), owner: self)

        default:
            return nil
        }
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let url = sitemap.urls[row]

        switch tableColumn?.identifier.rawValue {
        case "path":
            return url.pathWithQuery
            
        case "status":
            return sitemap.status(for: url)
            
        default:
            return nil
        }
    }
}

extension ViewController: NSTableViewDelegate {
    
}
