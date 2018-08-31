//
//  CameraHelper.swift
//  Suake3D
//
//  Created by dave on 13.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class CameraHelper{
    
    static let goDownDist:CGFloat = 10.0
    static let goDownDistFP:CGFloat = 5.0
    
    static func showDieAnim(game:GameViewController, didYouDie:Bool){
        game.gameStarted = false
        game.gameView.isPlaying = false
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        game.lblGameOver.fontColor = NSColor.white
        game.lblGameOver.alpha = 0
        game.lblGameOver.isHidden = false
        
        if(didYouDie){
            game.lblWinOrLoose.text = "YOU LOOSE"
        }else{
            game.lblWinOrLoose.text = "YOU WIN"
        }
        
        game.lblWinOrLoose.fontColor = NSColor.white
        game.lblWinOrLoose.alpha = 0
        game.lblWinOrLoose.isHidden = false
        if(didYouDie){
            game.cameraNode.position.y -= self.goDownDist
            game.cameraNodeFP.position.y -= self.goDownDistFP
        }
        SCNTransaction.commit()
        if(didYouDie){
            let when2 = DispatchTime.now() + (game.moveDelay * 0.5)
            DispatchQueue.main.asyncAfter(deadline: when2) {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.4
                game.cameraNode.position.y += self.goDownDist
                game.cameraNodeFP.position.y += self.goDownDistFP
                SCNTransaction.commit()
            }
            game.mediaManager.playCutSuakePainSound(percentLeft: 25)
            game.imgBloodDie.alpha = 1.0
            game.imgBloodDie.run(SKAction.fadeOut(withDuration: 1.0))
            game.imgBlackout.run(SKAction.fadeIn(withDuration: 1.0))
        }
        game.lblGameOver.run(SKAction.fadeIn(withDuration: 1.0))
        game.lblWinOrLoose.run(SKAction.fadeIn(withDuration: 1.0))
        game.lblWinOrLoose.run(SKAction.scale(to: 3.0, duration: 0.3)){
            game.lblWinOrLoose.run(SKAction.scale(to: 1.0, duration: 0.3)){
                game.lblWinOrLoose.run(SKAction.scale(to: 3.0, duration: 0.3)){
                    game.lblWinOrLoose.run(SKAction.scale(to: 1.0, duration: 0.3)){
                        game.lblWinOrLoose.run(SKAction.scale(to: 3.0, duration: 0.4)){
                            game.lblWinOrLoose.run(SKAction.scale(to: 1.0, duration: 0.5))
                        }
                    }
                }
            }
        }
        game.cameraNode.camera?.wantsDepthOfField = true
        if(didYouDie){
            let when = DispatchTime.now() + (game.moveDelay * 0.7)
            DispatchQueue.main.asyncAfter(deadline: when) {
                let when2 = DispatchTime.now() + (1.0)
                DispatchQueue.main.asyncAfter(deadline: when2) {
                    game.imgBlackout.run(SKAction.fadeOut(withDuration: 1.0))
                }
            }
        }
    }
    
    static func showHitAnim(game:GameViewController){
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        game.cameraNode.position.y -= self.goDownDist
        game.cameraNodeFP.position.y -= self.goDownDistFP
        game.imgBlackout.run(SKAction.fadeAlpha(by: 0.2, duration: 0.5))
        SCNTransaction.commit()
        let when2 = DispatchTime.now() + (game.moveDelay * 0.5)
        DispatchQueue.main.asyncAfter(deadline: when2) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.4
            game.cameraNode.position.y += self.goDownDist
            game.cameraNodeFP.position.y += self.goDownDistFP
            SCNTransaction.commit()
            game.imgBlackout.run(SKAction.fadeAlpha(by: -0.2, duration: 0.4))
        }
        game.mediaManager.playCutSuakePainSound(percentLeft: 25)
        game.imgBlood.alpha = 1.0
        let when = DispatchTime.now() + (game.moveDelay * 0.7)
        DispatchQueue.main.asyncAfter(deadline: when) {
            game.imgBlood.run(SKAction.fadeOut(withDuration: 1.0))
        }
    }
}
