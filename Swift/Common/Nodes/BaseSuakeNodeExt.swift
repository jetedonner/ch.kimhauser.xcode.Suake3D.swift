//
//  BaseSuakeNode.swift
//  iSuake3DNG
//
//  Created by dave on 11.01.18.
//  Copyright © 2018 dave. All rights reserved.
//

import Foundation
import SceneKit

class BaseSuakeNodeExt : BaseSuakeNode {
    
    var game:GameViewController!
    
    required override init() {
        super.init()
    }
    
    init(node: SCNNode, game: GameViewController) {
        super.init(node: node)
        self.game = game
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
