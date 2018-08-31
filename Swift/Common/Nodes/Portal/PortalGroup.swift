//
//  PortalGroup.swift
//  Suake3D
//
//  Created by dave on 01.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

class PortalGroup{
    
    var game:GameViewController!
    var id:Int = 0
    var portalIn:Portal!
    var portalOut:Portal!
    
    //private var _isHidden: Bool = false             // _x -> backingX
    var coords:[SCNVector3] {
        /*set {
            //_isHidden = newValue
            //portalIn.isHidden = _isHidden
            //portalOut.isHidden = _isHidden
            portalIn.coord = newValue[0]
            portalOut.coord = newValue[1]
        }*/
        get {
            return  [portalIn.coord, portalOut.coord]
        }
    }
    
    private var _isHidden: Bool = false
    var isHidden: Bool {
        set {
            _isHidden = newValue
            portalIn.isHidden = _isHidden
            portalOut.isHidden = _isHidden
        }
        get { return _isHidden }
    }
    
    private var _lblIsHidden: Bool = false
    var lblIsHidden: Bool {
        set {
            _lblIsHidden = newValue
            portalIn.lblIsHidden = _lblIsHidden
            portalOut.lblIsHidden = _lblIsHidden
        }
        get { return _lblIsHidden }
    }
    
    public func removeFromParentNode(){
        portalIn.removeFromParentNode()
        portalOut.removeFromParentNode()
    }
    
    convenience init(game:GameViewController, id:Int, inCoord:SCNVector3, outCoord:SCNVector3){
        self.init()
        self.id = id
        self.game = game
        
        portalIn = Portal(game: self.game, grpId: id, inPortal: true, coord: inCoord)
        self.game.gameView.scene?.rootNode.addChildNode(portalIn)
        
        portalOut = Portal(game: self.game, grpId: id, inPortal: false, coord: outCoord)
        self.game.gameView.scene?.rootNode.addChildNode(portalOut)
    }
}
