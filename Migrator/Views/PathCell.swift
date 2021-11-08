//
//  PathCell.swift
//  Migrator
//
//  Created by Stanislas Chevallier on 04/11/2021.
//

import Cocoa

class PathCell: NSTableCellView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        objectValue = nil
    }
    
    // MARK: Properties
    override var objectValue: Any? {
        didSet {
            updateContent()
        }
    }
    
    // MARK: Views
    @IBOutlet private var textView: NSTextField!

    // MARK: Content
    private func updateContent() {
        guard let value = objectValue as? SitemapItem else { return }
        
        let text = NSMutableAttributedString(string: value.location.pathWithQuery, attributes: [.font: textView.font!, .foregroundColor: NSColor.labelColor])
        if let redirection = value.status?.redirect {
            let subtitle = NSMutableAttributedString(string: "\n→  " + redirection.pathWithQuery, attributes: [.font: textView.font!, .foregroundColor: NSColor.secondaryLabelColor])
            text.append(subtitle)
        }
        
        textView.attributedStringValue = text
    }
}
