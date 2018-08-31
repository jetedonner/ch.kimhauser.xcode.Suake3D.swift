//
//  WeaponPickupBase.swift
//  Suake3D
//
//  Created by dave on 25.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class WeaponPickupBase:BaseSuakeNode{
    
    var game:GameViewController!
    var rescale:CGFloat = 0.02
    
    //public var shots:Int = 1
    public var shotsPerPickup:Int = 1
    public var colorOnMap:SKColor = SKColor.white
    
    public convenience init(_game: GameViewController){
        self.init()
        self.game = _game
        self.pos.y = 8
    }
        
    override init(node: SCNNode) {
        super.init(node: node)
    }
    
    required override init(){
        super.init()
    }
    
    func initShots(/*shots: Int = 1, */shotsPerPickup:Int = 1, colorOnMap:NSColor = SKColor.white) {
        //self.shots = shots
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
