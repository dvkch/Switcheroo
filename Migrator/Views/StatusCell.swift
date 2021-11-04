//
//  StatusCell.swift
//  Migrator
//
//  Created by Stanislas Chevallier on 04/11/2021.
//

import Cocoa

class StatusCell: NSTableCellView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        badgeView.wantsLayer = true
        badgeView.layer?.cornerRadius = badgeView.bounds.height / 2
        objectValue = nil
    }
    
    // MARK: Properties
    override var objectValue: Any? {
        didSet {
            updateContent()
        }
    }
    
    // MARK: Views
    @IBOutlet private var badgeView: NSView!
    @IBOutlet private var textView: NSTextField!

    // MARK: Content
    private func updateContent() {
        guard let value = objectValue as? PathStatus else {
            badgeView.layer?.backgroundColor = NSColor.systemGray.cgColor
            textView.stringValue = "N/A"
            return
        }
        
        switch value.badge {
        case .success:
            badgeView.layer?.backgroundColor = NSColor.systemGreen.cgColor

        case .warning:
            badgeView.layer?.backgroundColor = NSColor.systemOrange.cgColor

        case .error:
            badgeView.layer?.backgroundColor = NSColor.systemRed.cgColor
        }
        
        textView.stringValue = String(value.code)
    }
}
