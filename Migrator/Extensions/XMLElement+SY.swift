//
//  XMLElement+SY.swift
//  Migrator
//
//  Created by Stanislas Chevallier on 04/11/2021.
//

import Foundation

extension XMLElement {
    static func element(name: String, string: String?) -> XMLElement? {
        guard let string = string else { return nil }

        let node = XMLElement(kind: .element)
        node.name = name
        node.stringValue = string
        return node
    }

    static func element(name: String, children: [XMLNode], attributes: [XMLNode]? = nil) -> XMLElement {
        return XMLElement.element(withName: name, children: children, attributes: attributes) as! XMLElement
    }
}
