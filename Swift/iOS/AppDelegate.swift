/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The iOS implementation of the application delegate of the game.
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    @IBOutlet var window: UIWindow?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let screen = NSScreen.main() {
            window.setFrame(screen.visibleFrame, display: true, animate: true)
        }
    }
    
}
