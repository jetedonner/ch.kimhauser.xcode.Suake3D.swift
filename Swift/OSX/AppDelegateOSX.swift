/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The OS X implementation of the application delegate of the game.
*/

import Cocoa

@NSApplicationMain
class AppDelegateOSX: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    //@IBOutlet weak var scrollView: NSScrollView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let screen = NSScreen.main() {
            window.setFrame(screen.visibleFrame, display: true, animate: true)
        }
    }
    
    private func applicationShouldTerminate(afterLastWindowClosed sender: NSApplication) -> Bool {
        return true
    }
    
    /* LEGACY code
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }*/
}
