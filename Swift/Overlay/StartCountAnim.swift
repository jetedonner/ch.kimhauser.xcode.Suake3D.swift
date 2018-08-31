//
//  StartCountAnim.swift
//  Suake3D
//
//  Created by dave on 24.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class StartCountAnim{
    
    private static let counterStepTimeout:TimeInterval = 0.8
    private static let counterTextScaleFactor:CGFloat = 3.0
    
    static func showStartCountAnim(game:GameViewController, completionblock: @escaping () -> Swift.Void)->(){
        game.mediaManager.playSound(soundType: .beep)
        game.lblStartCounter.text = "1"
        game.lblStartCounter.isHidden = false
        game.lblStartCounter.run(SKAction.scale(to: 1, duration: 0.0))
        game.lblStartCounter.run(SKAction.fadeOut(withDuration: counterStepTimeout))
        game.lblStartCounter.run(SKAction.scale(to: counterTextScaleFactor, duration: counterStepTimeout)){
            game.mediaManager.playSound(soundType: .beep)
            game.lblStartCounter.run(SKAction.scale(to: 1, duration: 0.0))
            game.lblStartCounter.text = "2"
            game.lblStartCounter.alpha = 1.0
            game.lblStartCounter.run(SKAction.fadeOut(withDuration: counterStepTimeout))
            game.lblStartCounter.run(SKAction.scale(to: counterTextScaleFactor, duration: counterStepTimeout)){
                game.mediaManager.playSound(soundType: .beep2)
                game.lblStartCounter.run(SKAction.scale(to: 1, duration: 0.0))
                game.lblStartCounter.text = "3"
                game.lblStartCounter.alpha = 1.0
                game.lblStartCounter.run(SKAction.fadeOut(withDuration: counterStepTimeout))
                game.lblStartCounter.run(SKAction.scale(to: counterTextScaleFactor, duration: counterStepTimeout)){
                    game.lblStartCounter.isHidden = true
                    game.lblStartCounter.alpha = 1.0
                    completionblock()
                }
            }
        }
        return
    }
}
