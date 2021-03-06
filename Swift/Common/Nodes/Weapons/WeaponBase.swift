//
//  WeaponBase.swift
//  Suake3D
//
//  Created by dave on 26.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

class WeaponBase{
    
    var game:GameViewController!
    var firedShots:[BulletBase] = [BulletBase]()
    
    
    var gunName:String = "WeaponBase"
    var soundType:MediaManager.SoundType = MediaManager.SoundType.beep
    
    var _ammoCount:Int = 0
    public var ammoCount:Int{
        set{ _ammoCount = newValue }
        get{ return _ammoCount }
    }
    
    public convenience init(_game: GameViewController){
        self.init()
        self.game = _game
        //self.name = "WeaponBase"
    }
    
    func initWeapon(gunName:String, soundType:MediaManager.SoundType, initAmmoCount: Int = 1) {
        self.gunName = gunName
        self.soundType = soundType
        self.ammoCount = initAmmoCount
    }
    
    func shoot(){
        if(ammoCount > 0){
            ammoCount -= 1
            game.lblAmmoCount.text = ammoCount.description
            let newShot:BulletBase = fireSpecificShot()
            firedShots.append(newShot)
            game.gameView.scene?.rootNode.addChildNode(newShot)
            game.mediaManager.playSound(soundType: self.soundType)
            game.showDbgMsg(dbgMsg: DbgMsgs.suake + gunName + " " + DbgMsgs.fired)
        }else{
            game.showDbgMsg(dbgMsg: DbgMsgs.noAmmo)
            game.mediaManager.playSound(soundType: .noammo)
        }
    }
    
    func fireSpecificShot()->BulletBase{
        return BulletBase(_game: self.game)
    }
}
