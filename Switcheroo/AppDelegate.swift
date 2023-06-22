//
//  AppDelegate.swift
//  Switcheroo
//
//  Created by Stanislas Chevallier on 03/11/2021.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    override init() {
        super.init()
        _ = DocumentController.init() // force use of our subclass as early as possible
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

