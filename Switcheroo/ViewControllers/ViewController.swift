//
//  ViewController.swift
//  Switcheroo
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

        statusController = StatusController(urls: sitemap.items.map(\.location), scheme: scheme, host: host, delegate: self)
        statusController?.start()
        progressView.doubleValue = 0
    }
    
    @IBAction private func removeSelectedItem(sender: AnyObject?) {
        guard tableView.selectedRow >= 0 else { return }
        let removedIndex = tableView.selectedRow
        sitemap.removeItem(at: removedIndex)
        tableView.removeRows(at: IndexSet(integer: removedIndex), withAnimation: .slideUp)

        guard tableView.numberOfRows > 0 else { return }
        if (0..<sitemap.items.count).contains(removedIndex) {
            tableView.selectRowIndexes(IndexSet(integer: removedIndex), byExtendingSelection: false)
        }
        else if (0..<sitemap.items.count).contains(removedIndex - 1) {
            tableView.selectRowIndexes(IndexSet(integer: removedIndex - 1), byExtendingSelection: false)
        }
    }
    
    @IBAction private func doubleClickedRow(sender: AnyObject?) {
        guard tableView.clickedRow >= 0 else { return }
        let originalURL = sitemap.items[tableView.clickedRow].location

        guard let domain = sitemap.domain, let domainURL = URL(string: domain), let modifiedURL = URL(string: originalURL.pathWithQuery, relativeTo: domainURL) else { return }
        NSWorkspace.shared.open(modifiedURL)
    }
    
    @IBAction private func exportAsCSV(sender: AnyObject?) {
        var content = [String]()
        content.append("Path;Status")
        sitemap.items.forEach { item in
            content.append("\(item.location.pathWithQuery);\(item.status?.csvStatus ?? "")")
        }
        
        let panel = NSSavePanel()
        panel.directoryURL = sitemap.fileURL?.deletingLastPathComponent()
        panel.allowsOtherFileTypes = false
        panel.allowedFileTypes = ["csv"]
        panel.isExtensionHidden = false
        panel.beginSheetModal(for: self.view.window!) { response in
            if let url = panel.url, response == .OK {
                try? content.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
            }
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
        
        if selectedRow >= 0 && selectedRow < sitemap.items.count {
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
        case #selector(exportAsCSV(sender:)):
            return true
        default:
            return false
        }
    }
}

extension ViewController: NSTextFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(insertNewline(_:)), !hostTextField.stringValue.isEmpty {
            startButtonTap(sender: textView)
            return true
        }
        return false
    }
}

extension ViewController: StatusControllerDelegate {
    func statusController(_ statusController: StatusController, didUpdateStatusFor url: URL, status: PathStatus) {
        sitemap.setStatus(status, for: url)
        progressView.doubleValue = sitemap.percentOfDeterminedStatuses * 100
        
        if let index = sitemap.items.firstIndex(where: { $0.location ==  url}) {
            tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet([0, 1]))
        }
    }

    func statusControllerDidFinish(_ statusController: StatusController) {
        self.statusController = nil
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return sitemap.items.count
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
        return sitemap.items[row]
    }
}

extension ViewController: NSTableViewDelegate {
    
}
