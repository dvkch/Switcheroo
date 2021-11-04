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
    private var statusController: StatusController? {
        didSet {
            hostTextField.isEnabled = statusController == nil
            startButton.isEnabled = statusController == nil
        }
    }

    // MARK: Views
    @IBOutlet private var hostTextField: NSTextField!
    @IBOutlet private var startButton: NSButton!
    @IBOutlet private var tableView: NSTableView!

    // MARK: Actions
    @IBAction private func textfieldDidReturn(sender: AnyObject?) {
        guard !hostTextField.stringValue.isEmpty else { return }
        startButtonTap(sender: sender)
    }

    @IBAction private func startButtonTap(sender: AnyObject?) {
        guard statusController == nil else { return }

        guard let url = URL(string: hostTextField.stringValue),
              let host = url.host, let scheme = url.scheme,
              ["http", "https"].contains(scheme.lowercased())
        else {
            NSAlert(error: AppError.invalidHost).runModal()
            return
        }
        
        sitemap.clearStatuses()
        statusController = StatusController(urls: sitemap.urls, scheme: scheme, host: host, delegate: self)
        statusController?.start()
    }

    // MARK: Content
    private func updateContent() {
        tableView.reloadData()
    }
}

extension ViewController: StatusControllerDelegate {
    func statusController(_ statusController: StatusController, didUpdateStatusFor url: URL, status: PathStatus) {
        sitemap.setStatus(status, for: url)
    }
    func statusControllerDidFinish(_ statusController: StatusController) {
        self.statusController = nil
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
