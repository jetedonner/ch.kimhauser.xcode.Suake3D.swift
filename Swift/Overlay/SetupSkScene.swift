//
//  CreditsSkScene.swift
//  Suake3D
//
//  Created by dave on 01.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SpriteKit

class SetupSkScene : SKScene {
    
    var game:GameViewController!
    var scrollView:NSScrollView!
    
    convenience init(game:GameViewController){
        self.init(fileNamed: "game.scnassets/overlays/Setup")!
        //self.init()
        self.game = game
    }
    
    override func mouseMoved(with event: NSEvent)
    {
        // Get mouse position in scene coordinates
        let location = event.location(in: self)
        // Get node at mouse position
        let node = self.atPoint(location)
        if(node == game.lblSetupControls){
            print("YES HOVER")
        }
    }
    
    /*override func didMove(to view: SKView) {
        super.didMove(to: view)
        // Show custom mouse cursor
        let myCursor: NSCursor = NSCursor(image: NSImage(named: "ch_1a.png")!, hotSpot: NSPoint(x: 0.5, y: 0.5))
        game.gameView.addCursorRect(game.gameView.frame, cursor: myCursor)
    }*/
    
    override func scrollWheel(with event: NSEvent) {
        var i = -1
        i /= -1
        //scene.scrollWheel(with: event)
    }
    
    func dictionaryOfNames(arr:NSView...) -> Dictionary<String,NSView> {
        var d = Dictionary<String,NSView>()
        for (ix,v) in arr.enumerated(){
            d["v\(ix+1)"] = v
        }
        return d
    }
}
