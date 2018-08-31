//
//  BulletBase.swift
//  Suake3D iOS
//
//  Created by dave on 26.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class BulletBase:BaseSuakeNode{
    
    var game:GameViewController!
    var rescale:CGFloat = 0.02
    
    var shootingVelocity:CGFloat = 285.0
    var damage:Int = 0
    
    var isTargetHit:Bool = false
    var isBeaming:Bool = false
    
    public convenience init(_game: GameViewController){
        self.init()
        self.game = _game
        //self.pos.y = 8
    }
    
    override init(node: SCNNode) {
        super.init(node: node)
        self.name = "BulletBase"
    }
    
    required override init(){
        super.init()
    }
    
    /*func initShots(shots: Int = 1, shotsPerPickup:Int = 1, colorOnMap:NSColor = SKColor.white) {
        self.shots = shots
        self.shotsPerPickup = shotsPerPickup
        self.colorOnMap = colorOnMap
    }
    
    func posOnBoard(pos:SCNVector3){
        self.pos = pos
        self.oldPos = pos
        self.position = SCNVector3(x: (self.pos.x * game.suake.moveDist), y: self.pos.y, z: self.pos.z * game.suake.moveDist + game.suake.moveDist)
    }
    
    func placeOnBoard(pos:SCNVector3){
        posOnBoard(pos: pos)
        game.gameView.scene?.rootNode.addChildNode(self)
    }*/
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
