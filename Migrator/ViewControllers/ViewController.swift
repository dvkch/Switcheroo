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
        statusController = nil
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
            startButton.title = statusController == nil ? "Start" : "Stop"
            progressView.isHidden = statusController == nil
        }
    }

    // MARK: Views
    @IBOutlet private var hostTextField: NSTextField!
    @IBOutlet private var startButton: NSButton!
    @IBOutlet private var progressView: NSProgressIndicator!
    @IBOutlet private var tableView: NSTableView!

    // MARK: Actions
    @IBAction private func textfieldDidReturn(sender: AnyObject?) {
        guard !hostTextField.stringValue.isEmpty else { return }
        startButtonTap(sender: sender)
    }

    @IBAction private func startButtonTap(sender: AnyObject?) {
        if statusController != nil {
            statusController?.stop()
            return
        }

        var urlString = hostTextField.stringValue
        if !urlString.hasPrefix("http") {
            urlString = "https://" + urlString
        }
        guard let url = URL(string: urlString),
              let host = url.host,
              let scheme = url.scheme,
              ["http", "https"].contains(scheme.lowercased())
        else {
            NSAlert(error: AppError.invalidHost).runModal()
            return
        }

        sitemap.updateDomain(scheme + "://" + host)
        sitemap.clearStatuses()
        updateContent()

        statusController = StatusController(urls: sitemap.urls, scheme: scheme, host: host, delegate: self)
        statusController?.start()
        progressView.doubleValue = 0
    }
    
    @IBAction private func removeSelectedItem(sender: AnyObject?) {
        guard tableView.selectedRow >= 0 else { return }
        let removedIndex = tableView.selectedRow
        sitemap.removeItem(at: removedIndex)
        tableView.removeRows(at: IndexSet(integer: removedIndex), withAnimation: .slideUp)

        if removedIndex - 1 >= 0 && tableView.numberOfRows > 0 {
            tableView.selectRowIndexes(IndexSet(integer: removedIndex - 1), byExtendingSelection: false)
        }
        else if tableView.numberOfRows > 0 {
            tableView.selectRowIndexes(IndexSet(integer: removedIndex), byExtendingSelection: false)
        }
    }

    // MARK: Content
    private func updateContent() {
        reloadDomain()
        reloadTableView()
    }

    func reloadTableView() {
        let selectedRow = tableView.selectedRow
        tableView.reloadData()
        
        if selectedRow >= 0 && selectedRow < sitemap.urls.count {
            tableView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
        }
    }
    
    func reloadDomain() {
        hostTextField.stringValue = sitemap.domain ?? ""
    }
}

extension ViewController: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(removeSelectedItem(sender:)):
            return tableView.selectedRow >= 0
        default:
            return false
        }
    }
}

extension ViewController: StatusControllerDelegate {
    func statusController(_ statusController: StatusController, didUpdateStatusFor url: URL, status: PathStatus) {
        sitemap.setStatus(status, for: url)
        progressView.doubleValue = sitemap.percentOfDeterminedStatuses * 100
        
        if let index = sitemap.urls.firstIndex(of: url) {
            tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 1))
        }
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
