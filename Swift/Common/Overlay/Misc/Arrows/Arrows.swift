//
//  Crosshair.swift
//  Suake3D
//
//  Created by dave on 02.06.18.
//  Copyright © 2018 DaVe Inc. All rights reserved.
//

import Foundation
import SpriteKit

class Arrows: NSObject {
    
    public var imgArrowLeft:SKSpriteNode!
    public var imgArrowRight:SKSpriteNode!
    public var imgArrowUp:SKSpriteNode!
    public var imgArrowDown:SKSpriteNode!
    
    var game:GameViewController!
    
    override init(){
        super.init()
    }
    
    convenience init(_game:GameViewController) {
        self.init()
        self.game = _game
        
        imgArrowLeft = (game.sk.childNode(withName: "arrLeft") as! SKSpriteNode)
        imgArrowLeft.texture = SKTexture(imageNamed: "game.scnassets/textures/_weapons/arrows/arrow.png")
        imgArrowLeft.name = "arrLeft"
        imgArrowLeft.alpha = 0.4
        imgArrowLeft.isHidden = true
        imgArrowLeft.position = CGPoint(x: (game.gameWindowSize.width / -2) + 10 + (imgArrowLeft.frame.width / 2), y: imgArrowLeft.frame.height / 2) // LEFT
        
        imgArrowRight = imgArrowLeft.copy() as! SKSpriteNode
        imgArrowRight.name = "arrRight"
        imgArrowRight.zRotation = CGFloat(Float.pi)
        imgArrowRight.position = CGPoint(x: (game.gameWindowSize.width / 2) - 10 - (imgArrowRight.frame.width / 2), y: imgArrowRight.frame.height / 2) // RIGHT
        game.sk.addChild(imgArrowRight)
        
        imgArrowUp = imgArrowLeft.copy() as! SKSpriteNode
        imgArrowUp.name = "arrUp"
        imgArrowUp.zRotation = CGFloat(Float.pi) / 2 * 3
        imgArrowUp.position = CGPoint(x: 0, y: (game.gameWindowSize.height / 2) - 10 - (imgArrowUp.frame.height / 2)) // UP
        game.sk.addChild(imgArrowUp)
        
        imgArrowDown = imgArrowLeft.copy() as! SKSpriteNode
        imgArrowDown.name = "arrDown"
        imgArrowDown.zRotation = CGFloat(Float.pi) / 2
        imgArrowDown.position = CGPoint(x: 0, y: (game.gameWindowSize.height / -2) + 15 + (imgArrowDown.frame.height / 2)) // DOWN
        game.sk.addChild(imgArrowDown)
        
    }
    
    /*var imgHidden = false
    func isHiddedToggle()->Bool{
        imgHidden = !imgHidden
        imgArrowUp.isHidden = !(game.goodyNode.pos.z > game.suake.suakeHead.pos.z) && imgHidden
        imgArrowRight.isHidden = !(game.goodyNode.pos.z < game.suake.suakeHead.pos.z) && imgHidden
        imgArrowDown.isHidden = !(game.goodyNode.pos.x > game.suake.suakeHead.pos.x) && imgHidden
        imgArrowLeft.isHidden = !(game.goodyNode.pos.x < game.suake.suakeHead.pos.x) && imgHidden
        return imgHidden
    }*/
    
    // TODO: Convert to enum
    // 0 = None, 1 = Only Direction, 2 = All
    var showArrows:ArrowsShowState = .NONE
    public enum ArrowsShowState:Int{
        case NONE = 0, DIR = 1, ALL = 2
    }
    
    /*func setArrowsVisibility(vis:ArrowsShowState){
        showArrows = vis
        showHideHelperArrows()
        //setArrowsHiddedOrNot(imgUp: imgArrowUp, imgRight: imgArrowRight, imgDown: imgArrowDown, imgLeft: imgArrowLeft)
    }*/
    
    func areArrowsHiddedToggleNG()->ArrowsShowState{
        if(showArrows == .NONE){
            showArrows = .DIR
        }else if(showArrows == .DIR){
            showArrows = .ALL
        }else{
            showArrows = .NONE
        }
        setArrowsHiddedOrNot(imgUp: imgArrowUp, imgRight: imgArrowRight, imgDown: imgArrowDown, imgLeft: imgArrowLeft)
        return showArrows
    }
    
    func setArrowsHiddedOrNot(imgUp:SKSpriteNode, imgRight:SKSpriteNode, imgDown:SKSpriteNode, imgLeft:SKSpriteNode){
        imgUp.isHidden = (!((game.goodyNode.pos.z > game.suake.suakeHead.pos.z) && showArrows == .DIR)) && showArrows != .ALL
        imgRight.isHidden = (!((game.goodyNode.pos.x < game.suake.suakeHead.pos.x) && showArrows == .DIR)) && showArrows != .ALL
        imgDown.isHidden = (!((game.goodyNode.pos.z < game.suake.suakeHead.pos.z) && showArrows == .DIR)) && showArrows != .ALL
        imgLeft.isHidden = (!((game.goodyNode.pos.x > game.suake.suakeHead.pos.x) && showArrows == .DIR)) && showArrows != .ALL
    }
    
    func showHideHelperArrows(){
        var imgUp:SKSpriteNode = imgArrowUp
        var imgRight:SKSpriteNode = imgArrowRight
        var imgDown:SKSpriteNode = imgArrowDown
        var imgLeft:SKSpriteNode = imgArrowLeft
        if(game.suake.suakeHead.dir == .RIGHT){
            imgUp = imgArrowLeft
            imgRight = imgArrowUp
            imgDown = imgArrowRight
            imgLeft = imgArrowDown
        }else if(game.suake.suakeHead.dir == .DOWN){
            imgUp = imgArrowDown
            imgRight = imgArrowLeft
            imgDown = imgArrowUp
            imgLeft = imgArrowRight
        }else if(game.suake.suakeHead.dir == .LEFT){
            imgUp = imgArrowRight
            imgRight = imgArrowDown
            imgDown = imgArrowLeft
            imgLeft = imgArrowUp
        }
        setArrowsHiddedOrNot(imgUp: imgUp, imgRight: imgRight, imgDown: imgDown, imgLeft: imgLeft)
    }
}

