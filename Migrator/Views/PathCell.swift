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
        textView.stringValue = (objectValue as? String) ?? ""
    }
}
