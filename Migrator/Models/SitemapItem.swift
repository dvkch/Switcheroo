//
//  SitemapItem.swift
//  Migrator
//
//  Created by Stanislas Chevallier on 04/11/2021.
//

import Foundation

struct SitemapItem {
    
    // MARK: Properties
    let location: URL
    let lastModification: String?
    let priority: Double
    
    // MARK: Coding
    enum CodingKeys: String, CodingKey {
        case location = "loc"
        case lastModification = "lastmod"
        case priority = "priority"
    }
    
    init?(node: XMLNode) {
        guard let loc = node.children?.first(where: { $0.name == CodingKeys.location.rawValue })?.stringValue, let location = URL(string: loc) else { return nil }
        self.location = location.withoutQuery // queries are not useful to determine if a page exists or not
        
        let priority = node.children?.first(where: { $0.name == CodingKeys.priority.rawValue })?.stringValue
        self.priority = Double(priority ?? "") ?? 1

        self.lastModification = node.children?.first(where: { $0.name == CodingKeys.lastModification.rawValue })?.stringValue
    }
    
    var asNode: XMLNode {
        let children = [
            XMLElement.element(name: CodingKeys.location.rawValue, string: location.absoluteString),
            XMLElement.element(name: CodingKeys.lastModification.rawValue, string: lastModification),
            XMLElement.element(name: CodingKeys.priority.rawValue, string: String(format: "%.02lf", priority))
        ].compactMap { $0 }

        return XMLElement.element(name: "url", children: children)
    }
}


extension SitemapItem: Equatable, Hashable {
    // let's allow unicity on location alone
    static func ==(lhs: SitemapItem, rhs: SitemapItem) -> Bool {
        return lhs.location == rhs.location
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(location)
    }
}

extension SitemapItem: Comparable {
    static func <(lhs: SitemapItem, rhs: SitemapItem) -> Bool {
        if lhs.priority != rhs.priority {
            return lhs.priority < rhs.priority
        }
        return lhs.location.absoluteURL.absoluteString < rhs.location.absoluteURL.absoluteString
    }
}
