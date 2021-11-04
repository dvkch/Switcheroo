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
        self.hasUndoManager = false
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
            let nodes = try document.nodes(forXPath: "/urlset/url/loc")
            urls = nodes.compactMap(\.stringValue).compactMap { URL(string: $0) }
            urls = Array(Set(urls.map(\.withoutQuery))).sorted()

            isTransient = false

        default:
            throw AppError.invalidFileType
        }
    }

    override func data(ofType typeName: String) throws -> Data {
        throw AppError.noSaveSupport
    }

    
    // MARK: Properties
    private(set) var isTransient: Bool = false
    weak var contentViewController: ViewController?

    private(set) var urls: [URL] = []
    private var statuses: [URL: PathStatus] = [:]

    var isEmpty: Bool {
        return urls.isEmpty
    }

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
}
