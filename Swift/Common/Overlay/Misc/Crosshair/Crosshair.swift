//
//  Crosshair.swift
//  Suake3D
//
//  Created by dave on 02.06.18.
//  Copyright © 2018 DaVe Inc. All rights reserved.
//

import Foundation
import SpriteKit

protocol MoveCrosshairDelegate {
    // !!! WONT ALLOW STATISTICS CLICK (DBG MENU) !!!!
    //func mouseDown(in view: NSView, with event: NSEvent) -> Bool
    //func mouseDragged(in view: NSView, with event: NSEvent) -> Bool
    //func mouseUp(in view: NSView, with event: NSEvent) -> Bool
    //func keyDown(in view: NSView, with event: NSEvent) -> Bool
    //func keyUp(in view: NSView, with event: NSEvent) -> Bool
    func mouseEntered(with event: NSEvent)
    func mouseExited(with event: NSEvent)
    func mouseMoved(with event: NSEvent)
    func panCamera(_ direction: float2) 
}

class Crosshair: NSObject {
    
    public var chMax:CGFloat = 0.5
    public var imgCrosshair:SKSpriteNode!
    
    var game:GameViewController!

    override init(){
        super.init()
    }
    
    convenience init(_game:GameViewController) {
        self.init()
        self.game = _game
        imgCrosshair = (game.sk.childNode(withName: "imgCrosshair") as! SKSpriteNode)
        //imgCrosshair.texture = SKTexture(imageNamed: "art.scnassets/_weapons/Crosshair/ch_1a.png") // crosshair_edt
        imgCrosshair.alpha = self.chMax
    }
    
    public func toggleCh(){
        hideCh(newVal: !imgCrosshair.isHidden)
    }
    
    public func hideCh(newVal:Bool){
        imgCrosshair.isHidden = newVal
        if(imgCrosshair.isHidden){
            NSCursor.unhide()
        }else{
            //NSCursor.hide()
        }
        
    }
}
