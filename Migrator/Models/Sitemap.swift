//
//  Sitemap.swift
//  Migrator
//
//  Created by Stanislas Chevallier on 04/11/2021.
//

import Cocoa

class Sitemap: NSDocument {
    
    // MARK: Document
    override init() {
        super.init()
        self.isTransient = true
        self.hasUndoManager = true
    }

    override class var autosavesInPlace: Bool {
        return true
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        contentViewController = windowController.contentViewController as? ViewController
        contentViewController?.representedObject = self
        self.addWindowController(windowController)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        switch typeName {
        case "public.xml":
            let document = try XMLDocument(data: data)
            let nodes = try document.nodes(forXPath: "/urlset/url")
            items = nodes.compactMap { SitemapItem(node: $0) }
            items = Array(Set(items)).sorted().reversed()
            domain = try document.nodes(forXPath: "/urlset/@domain").first?.stringValue
            
            isTransient = false

        default:
            throw AppError.invalidFileType
        }
    }

    override func data(ofType typeName: String) throws -> Data {
        switch typeName {
        case "public.xml":
            let nodes = items.map(\.asNode)
            let attributes = [XMLNode.attribute(withName: "domain", stringValue: domain ?? "") as! XMLNode]
            let root = XMLElement.element(name: "urlset", children: nodes, attributes: attributes)
            let document = XMLDocument.document(withRootElement: root) as! XMLDocument
            return document.xmlData(options: .nodePrettyPrint)

        default:
            throw AppError.invalidFileType
        }
    }

    
    // MARK: Properties
    private(set) var isTransient: Bool = false
    weak var contentViewController: ViewController?

    private var items: [SitemapItem] = []
    private var statuses: [URL: PathStatus] = [:]

    var isEmpty: Bool {
        return items.isEmpty
    }
    
    var urls: [URL] {
        return items.map { $0.location }
    }

    var percentOfDeterminedStatuses: Double {
        guard !isEmpty else { return 0 }
        return Double(statuses.count) / Double(items.count)
    }
    
    private(set) var domain: String?
    
    // MARK: Status
    func clearStatuses() {
        statuses = [:]
    }
    
    func status(for url: URL) -> PathStatus? {
        return statuses[url]
    }
    
    func setStatus(_ status: PathStatus, for url: URL) {
        statuses[url] = status
    }
    
    // MARK: Modifications
    private func add(_ item: SitemapItem, at index: Int? = nil) -> Int {
        isTransient = false
        updateChangeCount(.changeDone)
        
        let index = index ?? items.count - 1
        items.insert(item, at: index)

        undoManager?.registerUndo(withTarget: self, handler: { selfTarget in
            selfTarget.removeItem(at: index)
            selfTarget.contentViewController?.reloadTableView()
        })
        undoManager?.setActionName("Add item")

        return index
    }

    func removeItem(at index: Int) {
        isTransient = false
        updateChangeCount(.changeDone)

        let removedItem = items.remove(at: index)

        undoManager?.registerUndo(withTarget: self, handler: { selfTarget in
            _ = selfTarget.add(removedItem, at: index)
            selfTarget.contentViewController?.reloadTableView()
        })
        undoManager?.setActionName("Remove item")
    }
    
    func updateDomain(_ domain: String?) {
        guard domain != self.domain else { return }

        let oldValue = self.domain
        self.domain = domain
        updateChangeCount(.changeDone)
        
        undoManager?.registerUndo(withTarget: self, handler: { selfTarget in
            selfTarget.updateDomain(oldValue)
            selfTarget.contentViewController?.reloadDomain()
        })
        undoManager?.setActionName("Update new domain")
    }
}
