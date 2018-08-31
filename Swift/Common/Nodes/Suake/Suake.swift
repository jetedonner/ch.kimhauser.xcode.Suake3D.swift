//
//  Suake.swift
//  iSuake3DNG
//
//  Created by dave on 28.02.18.
//  Copyright © 2018 dave. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

extension SCNNode{
    func duplicateSCNNode(/*_ node: SCNNode?, with material: SCNMaterial?*/)->SCNNode{
        let newNode = self.clone() as? SCNNode
        newNode?.geometry = self.geometry
        newNode?.geometry?.firstMaterial = self.geometry?.firstMaterial
        //newNode?.bbMax = self.boundingBox.max
        //newNode?.bbMin = self.boundingBox.min
        //newNode?.size = SCNVector3(x: self.bbMax.x * 2, y: self.bbMax.y * 2, z: self.bbMax.z * 2)
        
        //let nodeCopy:SCNNode = origNode.clone()
        //copy.geometry = self.geometry
        //copy.geometry?.materials = (self.geometry?.materials)!
        newNode?.position = self.position
        
        //newNode?.pos = self.pos // SCNVector3(x: 0, y: 0, z: 0)
        //newNode?.oldPos = self.oldPos //SCNVector3(x: 0, y: 0, z: 0)
        //for anim in self.anim
        //newNode?.animPlayer = self.animPlayer
        //newNode?.addAnimation(self.animation(), forKey: self.animPlayer)
        //newNode?.addAnimationPlayer(self.animationPlayer(), forKey: self.animPlayer)
        return newNode!
    }
}

class Suake: NSObject, CAAnimationDelegate{
    
    // Weapons
    public var machinegun:Machinegun!
    public var shotgun:Shotgun!
    public var rocketlauncher:Rocketlauncher!
    public var railgun:RailgunNG!
    
    public var nextKeyForRenderLoop:KeyboardDirection = KeyboardDirection.KEY_NONE
    public var keysForRenderLoop:[KeyboardDirection] = [KeyboardDirection]()
    public var nextKeyModifierFlags:NSEvent.ModifierFlags!
    
    public var arrSuakeNodes:[SuakeNode] = [SuakeNode]()
    
    public var suakeComplete:SuakeNode!
    public var suakeHead:SuakeNode!
    public var suakeHeadLeft:SuakeNode!
    public var suakeHeadRight:SuakeNode!
    
    public var suakeTail:SuakeNode!
    public var suakeTailLeft:SuakeNode!
    public var suakeTailRight:SuakeNode!
    
    public var suakeExpand:SuakeNode!
    public var suakeMiddle:SuakeNode!
    //public var suakeMiddle2:SuakeNode!
    public var suakeMiddles:[SuakeNode] = []
    
    public var selectedWeapon:Int = CollisionCategory.RocketLauncherCategory
    
    public var score:Int = 0
    public var health:Int = 100
    
    public var opponent:Bool = false
    public var expanded:Bool = false
    public var growCount:Int = 0
    public var opStep:Int = 0
    public var anims:[CAAnimation] = [CAAnimation]()
    var nodeBendToUse:SuakeNode!
    public var startWithExtrude:Bool = false
    let moveDist:CGFloat = 100.0
    public var animsRunning:Bool = false
    var porting:Bool = false
    
    var opPath:[SuakeDir] = [SuakeDir.LEFT, SuakeDir.LEFT, SuakeDir.DOWN, SuakeDir.DOWN, SuakeDir.RIGHT, SuakeDir.RIGHT, SuakeDir.UP, SuakeDir.UP]
    var game:GameViewController
    
    public struct SuakeFields: OptionSet {
        let rawValue: Int
        
        static let empty = SuakeFields(rawValue: 1)
        static let wall = SuakeFields(rawValue: 2)
        static let goody = SuakeFields(rawValue: 4)
        static let own_suake = SuakeFields(rawValue: 8)
        static let opp_suake = SuakeFields(rawValue: 16)
        static let weapon = SuakeFields(rawValue: 32)
        static let machinegun = SuakeFields(rawValue: 64)
        static let shotgun = SuakeFields(rawValue: 128)
        static let rocketlauncher = SuakeFields(rawValue: 256)
        static let railgun = SuakeFields(rawValue: 512)
        static let portal = SuakeFields(rawValue: 1024)
        static let fire = SuakeFields(rawValue: 2048)
    }
    
    var _speed:Int = 1
    var speed:Int{
        set{ _speed = newValue }
        get{ return _speed }
    }
    func incSpeed(){
        if(speed < 5){
            speed += 1
            for i in (0..<arrSuakeNodes.count){
                arrSuakeNodes[i].animationPlayer().speed = CGFloat(speed)
            }
        }
    }
    func decSpeed(){
        if(speed > 1){
            speed -= 1
            for i in (0..<arrSuakeNodes.count){
                arrSuakeNodes[i].animationPlayer().speed = CGFloat(speed)
            }
        }
    }
    
    func removeFromParentNode(){
        for sNode in arrSuakeNodes{
            sNode.removeFromParentNode()
        }
        suakeHead.removeFromParentNode()
        suakeTail.removeFromParentNode()
        suakeHeadLeft.removeFromParentNode()
        suakeTailLeft.removeFromParentNode()
        suakeHeadRight.removeFromParentNode()
        suakeTailRight.removeFromParentNode()
        suakeMiddle.removeFromParentNode()
        for middle in suakeMiddles{
            middle.removeFromParentNode()
        }
        suakeExpand.removeFromParentNode()
        suakeComplete.removeFromParentNode()
    }
    
    func addAllSuakeNodesToBoard(){
        game.gameView.scene?.rootNode.addChildNode(suakeHead)
        game.gameView.scene?.rootNode.addChildNode(suakeTail)
        game.gameView.scene?.rootNode.addChildNode(suakeHeadLeft)
        game.gameView.scene?.rootNode.addChildNode(suakeTailLeft)
        game.gameView.scene?.rootNode.addChildNode(suakeHeadRight)
        game.gameView.scene?.rootNode.addChildNode(suakeTailRight)
        game.gameView.scene?.rootNode.addChildNode(suakeMiddle)
        for middle in suakeMiddles{
            game.gameView.scene?.rootNode.addChildNode(middle)
        }
        game.gameView.scene?.rootNode.addChildNode(suakeExpand)
        game.gameView.scene?.rootNode.addChildNode(suakeComplete)
        //game.gameView.scene?.rootNode.addChildNode(nodeExp)
    }
    
    func selectWeaponPlaySound(weaponToSelect:Int, pickedUp:Bool){
        if(pickedUp){
            game.mediaManager.playSound(soundType: .pick_weapon)
        }else{
            if(self.selectedWeapon != weaponToSelect){
                game.mediaManager.playSound(soundType: .wp_change)
            }
        }
    }
    
    func selectWeapon(weaponToSelect:Int, pickedUp:Bool, mute:Bool = false){
        var wpChanged:Bool = false
        if(!mute){
            selectWeaponPlaySound(weaponToSelect:weaponToSelect, pickedUp:pickedUp)
        }
        if(self.selectedWeapon != weaponToSelect){
            self.selectedWeapon = weaponToSelect
            wpChanged = true
        }
        var selGunString:String = "(none)"
        var ammoCount:Int = 0
        if(self.selectedWeapon == CollisionCategory.MachineGunCategory){
            selGunString = DbgMsgs.machineGun
            ammoCount = machinegun.ammoCount
            game.imgRailgun.isHidden = true
            game.imgRailgun.alpha = 0
            game.imgShells.isHidden = true
            game.imgShells.alpha = 0
            game.imgRockets.isHidden = true
            game.imgRockets.alpha = 0
            game.imgMachinegun.isHidden = false
            game.imgMachinegun.alpha = 1
        }else if(self.selectedWeapon == CollisionCategory.ShotgunCategory){
            selGunString = DbgMsgs.shotgun
            ammoCount = shotgun.ammoCount
            game.imgMachinegun.isHidden = true
            game.imgMachinegun.alpha = 0
            game.imgRockets.isHidden = true
            game.imgRockets.alpha = 0
            game.imgRailgun.isHidden = true
            game.imgRailgun.alpha = 0
            game.imgShells.isHidden = false
            game.imgShells.alpha = 1
        }else if(self.selectedWeapon == CollisionCategory.RocketLauncherCategory){
            selGunString = DbgMsgs.rocketlauncher
            ammoCount = rocketlauncher.ammoCount
            game.imgMachinegun.isHidden = true
            game.imgMachinegun.alpha = 0
            game.imgRailgun.isHidden = true
            game.imgRailgun.alpha = 0
            game.imgShells.isHidden = true
            game.imgShells.alpha = 0
            game.imgRockets.isHidden = false
            game.imgRockets.alpha = 1
        }else if(self.selectedWeapon == CollisionCategory.RailGunCategory){
            selGunString = DbgMsgs.railgun
            ammoCount = railgun.ammoCount
            game.imgMachinegun.isHidden = true
            game.imgMachinegun.alpha = 0
            game.imgShells.isHidden = true
            game.imgShells.alpha = 0
            game.imgRockets.isHidden = true
            game.imgRockets.alpha = 0
            game.imgRailgun.isHidden = false
            game.imgRailgun.alpha = 1
        }
        game.lblAmmoCount.text = ammoCount.description
        game.lblAmmoCount.isHidden = false
        if(!mute){
            if(wpChanged){
                game.showDbgMsg(dbgMsg: DbgMsgs.weaponSelected + selGunString)
            }
        }
    }
    
    func shoot(){
        if(selectedWeapon == CollisionCategory.MachineGunCategory){
            let gun:WeaponBase = machinegun
            gun.shoot()
        }else if(selectedWeapon == CollisionCategory.ShotgunCategory){
            let gun:WeaponBase = shotgun
            gun.shoot()
        }else if(selectedWeapon == CollisionCategory.RocketLauncherCategory){
            let gun:WeaponBase = rocketlauncher
            gun.shoot()
        }else if(selectedWeapon == CollisionCategory.RailGunCategory){
            let gun:WeaponBase = railgun
            gun.shoot()
            //game.showDbgMsg(dbgMsg: DbgMsgs.railgunFired)
            //game.railgunWP.shots -= 1
            //game.lblAmmoCount.text = game.railgunWP.shots.description
            //game.shotgun.addShotgunShot()
            //game.mediaManager.playSound(soundType: .railgun)
        }
    }
    
    func loadAnimationNamed(_ animationName: String, fromSceneNamed sceneName: String) -> CAAnimation? {
        // Load the DAE using SCNSceneSource in order to be able to retrieve the animation by its identifier
        let url = Bundle.main.url(forResource: sceneName, withExtension: "dae")!
        #if os(OSX)
            let options: [SCNSceneSource.LoadingOption: Any] = [SCNSceneSource.LoadingOption.convertToYUp: true]
        #else
            let options: [SCNSceneSource.LoadingOption: Any] = [:]
        #endif
        let sceneSource = SCNSceneSource(url: url, options: options)
        let animations = extractAnimationsFromSceneSource(sceneSource: sceneSource!)
        return animations
    }
    
    func extractAnimationsFromSceneSource(sceneSource: SCNSceneSource)  -> CAAnimation?  {
        let animationsIDs = sceneSource.identifiersOfEntries(withClass: CAAnimation.self) as [String]
        var animations: [CAAnimation] = []
        for animationID in animationsIDs {
            if let animation = sceneSource.entryWithIdentifier(animationID, withClass: CAAnimation.self) as? CAAnimation {
                return animation
            }else{
                return nil
            }
        }
        return nil
    }
    
    var showMiddle:Bool = false
    var isMiddleVisible:Bool = false
    
    func normal(){
        suakeHead.isHidden = false
        suakeTail.isHidden = false
    }
    
    func middle(){
        self.showMiddle = true
        self.isMiddleVisible = true
        
        suakeHead.position.z += 100
        suakeHead.pos.z += 1
        
        if(suakeMiddles.count > 0){
            suakeMiddles[suakeMiddles.count-1].position.z += 100
            suakeMiddles[suakeMiddles.count-1].isHidden = false
            suakeMiddles[suakeMiddles.count-1].playAnim()
        }else{
            suakeMiddle.isHidden = false
            suakeMiddles.append(suakeMiddle.flattenedClone())
            suakeMiddle.playAnim()
        }
        if(suakeMiddles.count > 1){
            game.gameView.scene?.rootNode.addChildNode(suakeMiddles[suakeMiddles.count-1])
        }
        
        suakeHead.playAnim()
        suakeTail.playAnim()
    }
    
    func grow(){
        growCount += 1
    }
    
    func expand(){
        expanded = true
        suakeTail.isHidden = false
        suakeTail.stopAnim()
        suakeExpand.isHidden = false
        suakeExpand.playAnim()
        suakeHead.playAnim()
    }

    func copyAllNodeElementsFromScene(sceneName:String)->SuakeNode{
        var nodeRet:SuakeNode = SuakeNode()
        let scene1 = SCNScene(named: sceneName)
        var nodeArray3 = scene1?.rootNode.childNodes
        
        var idx:Int = 0
        if let scene1 = scene1 {
            for i in (0..<scene1.rootNode.animationKeys.count) {
                var key:String = scene1.rootNode.animationKeys[i]
                var key2:String = key
                if(idx == 0){
                    if(opponent){
                        key2 = key2 + "Opp"
                    }
                    nodeRet.animPlayer = key2
                    idx += 1
                }
                nodeRet.addAnimationPlayer(scene1.rootNode.animationPlayer(forKey: key)!, forKey: key2)
                nodeRet.animationPlayer(forKey: key2)?.stop()
            }
        }
        
        for childNode1 in nodeArray3! {
            //let childNode2 = scene1?.rootNode.childNode(withName: childNode1.name!, recursively: true)?.clone() as? SCNNode
            //childNode2?.geometry = scene1?.rootNode.childNode(withName: childNode1.name!, recursively: true)?.geometry
            //childNode2?.geometry?.firstMaterial = scene1?.rootNode.childNode(withName: childNode1.name!, recursively: true)?.geometry?.firstMaterial
            //newNode?.bbMax = self.boundingBox.max
            //newNode?.bbMin = self.boundingBox.min
            //newNode?.size = SCNVector3(x: self.bbMax.x * 2, y: self.bbMax.y * 2, z: self.bbMax.z * 2)
            
            var childNode2 = (scene1?.rootNode.childNode(withName: childNode1.name!, recursively: true))!
            //childNode2.geometry = scene1?.rootNode.childNode(withName: childNode1.name!, recursively: true)?.flattenedClone().geometry
            //scene1?.rootNode.childNode(withName: childNode1.name!, recursively: true)
            childNode2.geometry = scene1?.rootNode.childNode(withName: childNode1.name!, recursively: true)?.geometry?.copy() as? SCNGeometry
            
            nodeRet.addChildNode(childNode2)
            //if let childNode2 = childNode2{
            if(childNode2.animationKeys.count > 0){
                for i in (0..<childNode2.animationKeys.count) {
                    var key:String = childNode2.animationKeys[i]
                    var key2:String = key
                    if(opponent){
                        key2 = key2 + "Opp"
                    }
                    nodeRet.addAnimationPlayer(childNode2.animationPlayer(forKey: key)!, forKey: key2)
                    nodeRet.animationPlayer(forKey: key2)?.stop()
                }
            }
            
            //}
            
            /*if(childNode1.morpher != nil || childNode2.name == "COBRA_cobra_skin1" || childNode2.name == "polySurface5"){
             nodeRet.animNode = childNode2
             }*/
        }
        if(sceneName == "game.scnassets/suake/ng/Suake_STRAIGHT_HEAD_1.dae" || sceneName == "game.scnassets/suake/ng/Suake_STRAIGHT_TAIL_1.dae"){
            nodeRet.geometry = scene1?.rootNode.flattenedClone().geometry
            //nodeRet.geometry?.firstMaterial = scene1?.rootNode.flattenedClone().duplicateSCNNode().geometry?.firstMaterial
            //nodeRet.geometry?.firstMaterial = scene1?.rootNode.flattenedClone().geometry?.firstMaterial
        }
        //let newNode = self.clone() as? SuakeNode
        //nodeRet.geometry = nodeArray3![0].geometry
        //newNode?.geometry?.firstMaterial = self.geometry?.firstMaterial
        nodeRet.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        nodeRet.bbMax = nodeRet.boundingBox.max
        nodeRet.bbMin = nodeRet.boundingBox.min
        nodeRet.size = SCNVector3(x: (nodeRet.bbMax.x - nodeRet.bbMin.x) * 100, y: (nodeRet.bbMax.y - nodeRet.bbMin.y) * 100, z: (nodeRet.bbMax.z - nodeRet.bbMin.z) * 100)
        
        nodeRet.pos = SCNVector3(x: 0, y: 0, z: 0)
        nodeRet.oldPos = SCNVector3(x: 0, y: 0, z: 0)
        
        // TODO: Aspect
        nodeRet.position = SCNVector3(x: 0, y: 1.0, z: 0)
        
        if(opponent && (sceneName == "game.scnassets/suake/ng/Suake_STRAIGHT_HEAD_1.dae" || sceneName == "game.scnassets/suake/ng/Suake_STRAIGHT_TAIL_1.dae")){
            //node1.name = node1.name! + "Opp"
            let testShape = SCNBox(width: nodeRet.size.x / scaleFactor * 2, height: nodeRet.size.y / scaleFactor * 5, length: nodeRet.size.z / scaleFactor * 2, chamferRadius: 0.5)
            let nodeShape = SCNPhysicsShape(geometry: testShape, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox]) // geometry: testShape, options: [SCNPhysicsShape.Option.scale: scaleFactor / 5]/* [SCNPhysicsShape.Option.scale: SCNVector3(scaleFactor / 5, scaleFactor / 5, scaleFactor / 5)]*/)
            //let boxBodyShape = SCNPhysicsShape(node: nodeRet /*geometry: nodeRet.flattenedClone().geometry!*/, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
            //let boxBody = SCNPhysicsBody(type: .kinematic, shape: boxBodyShape)
            //nodeRet.physicsBody = boxBody
            nodeRet.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nodeShape)
            nodeRet.physicsBody?.isAffectedByGravity = false
            nodeRet.physicsBody?.categoryBitMask = CollisionCategory.SuakeOpCategory
            nodeRet.physicsBody?.contactTestBitMask = CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.PelletCategory|CollisionCategory.RailShotCategory
        }
        
        return nodeRet
        //return SuakeNode(node: (scene1?.rootNode.duplicateSCNNode())!, opponent: opponent) //nodeRet
    }
    //var nodeExp:SCNNode = SCNNode()
    let scaleFactor:CGFloat = 10.0
    
    func getSuakeNode(opponent:Bool)->SuakeNode{
        var node1:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_STRAIGHT_HEAD_1.dae") //Suake_SEPERATED_STRAIGHT_04_HEAD_1b.dae")//suake_straight_head_moving_NG.dae") //123456.dae") // suake_straight_head_moving_NG.dae") //suake_textx_whole_straight_moving8d.dae") //suake_straight_head_moving.dae") // suake_textx_whole_straight_moving6.dae") //suake_straight_head_moving.dae") // suake_ng_headpart.dae")
        //node1.isHidden = true
        node1.name = "SuakeHead"
        node1.opponent = opponent
        if(opponent){
            node1.name = node1.name! + "Opp"
            /*let nodeShape = SCNPhysicsShape(geometry: node1.geometry!, options: [SCNPhysicsShape.Option.scale: SCNVector3(scaleFactor, scaleFactor, scaleFactor)])
             node1.physicsBody = SCNPhysicsBody(type: .static, shape: nodeShape)
             node1.physicsBody?.isAffectedByGravity = false
             node1.physicsBody?.categoryBitMask = CollisionCategory.SuakeOpCategory
             node1.physicsBody?.contactTestBitMask = CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
             */
            //node1.physicsBody?.collisionBitMask = CollisionCategory.SuakeOpCategory|CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
        }else{
            /*let nodeShape = SCNPhysicsShape(geometry: node1.geometry!, options: [SCNPhysicsShape.Option.scale: SCNVector3(scaleFactor, scaleFactor, scaleFactor)])
             node1.physicsBody = SCNPhysicsBody(type: .static, shape: nodeShape)
             node1.physicsBody?.isAffectedByGravity = false
             node1.physicsBody?.categoryBitMask = CollisionCategory.SuakeCategory
             node1.physicsBody?.contactTestBitMask = CollisionCategory.SuakeCategory|CollisionCategory.SuakeOpCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory*/
            //node1.physicsBody?.collisionBitMask = CollisionCategory.SuakeCategory|CollisionCategory.SuakeOpCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
        }
        
        let node1b:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_STRAIGHT_COMPLETE_1.dae")
        node1b.name = "Complete"
        node1b.isHidden = true
        node1b.opponent = opponent
        suakeComplete = node1b
        
        var node1a:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_STRAIGHT_TAIL_1.dae") //Suake_SEPERATED_STRAIGHT_04_TAIL_1a.dae")//suake_straight_tail_moving_NG.dae") // suake_ng_tailpart.dae")
        node1a.name = "SuakeTail"
        node1a.opponent = opponent
        suakeTail = node1a
        /*if(opponent){
         let nodeShape = SCNPhysicsShape(geometry: suakeTail.geometry!, options: [SCNPhysicsShape.Option.scale: SCNVector3(scaleFactor, scaleFactor, scaleFactor)])
         suakeTail.physicsBody = SCNPhysicsBody(type: .static, shape: nodeShape)
         suakeTail.physicsBody?.isAffectedByGravity = false
         suakeTail.physicsBody?.categoryBitMask = CollisionCategory.SuakeOpCategory
         suakeTail.physicsBody?.contactTestBitMask = CollisionCategory.SuakeOpCategory|CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
         //node1a.physicsBody?.collisionBitMask = CollisionCategory.SuakeOpCategory|CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
         }else{
         let nodeShape = SCNPhysicsShape(geometry: suakeTail.geometry!, options: [SCNPhysicsShape.Option.scale: SCNVector3(scaleFactor, scaleFactor, scaleFactor)])
         suakeTail.physicsBody = SCNPhysicsBody(type: .static, shape: nodeShape)
         suakeTail.physicsBody?.isAffectedByGravity = false
         suakeTail.physicsBody?.categoryBitMask = CollisionCategory.SuakeCategory
         suakeTail.physicsBody?.contactTestBitMask = CollisionCategory.SuakeCategory|CollisionCategory.SuakeOpCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
         //node1a.physicsBody?.collisionBitMask = CollisionCategory.SuakeCategory|CollisionCategory.SuakeOpCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
         }*/
        
        let node2a:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_LEFT_HEAD_2.dae") //Suake_LEFT_Head_1.dae") // suake_ng_headpart_left.dae")
        node2a.name = "BendLeftHead"
        node2a.isHidden = true
        node2a.opponent = opponent
        suakeHeadLeft = node2a
        
        let node2b:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_LEFT_TAIL_2.dae") //Suake_LEFT_Tail_1.dae") // suake_ng_headpart_left.dae")
        node2b.name = "BendLeftTail"
        node2b.isHidden = true
        node2b.opponent = opponent
        suakeTailLeft = node2b
        
        let node2c:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_RIGHT_HEAD_2.dae") //Suake_RIGHT_Head_1.dae") // suake_ng_headpart_left.dae")
        node2c.name = "BendRightHead"
        node2c.isHidden = true
        node2c.opponent = opponent
        suakeHeadRight = node2c
        
        let node2d:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_RIGHT_TAIL_2.dae") //Suake_RIGHT_Tail_1.dae") // suake_ng_headpart_left.dae")
        node2d.name = "BendRightTail"
        node2d.isHidden = true
        node2d.opponent = opponent
        suakeTailRight = node2d
        
        let node3:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_EXTRUDE_STRAIGHT.dae") //suake_straight_middle_extruding_NG.dae") // dae") // TesT_Extrude_With_DynJoints_1h.dae") //TesT_Extrude_With_DynJoints_1c.dae") //TesT_Extrude_With_DynJoints_1a.dae") //1111.dae")
        node3.name = "Expand"
        node3.opponent = opponent
        node3.isHidden = true
        suakeExpand = node3
        
        let node4a:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_MIDDLE_STRAIGHT_MOVING.dae") // suake_straight_middle_moving_NG.dae") //suake_straight_middle_moving_NG_green.dae") //suake_straight_middle_moving_NG.dae") // suake_straight_middle_moving_ORIG.scn") //suake_straight_middle_moving_ORIG.dae") // suake_ng_tailpart.dae")
        node4a.name = "NodeMiddle"
        node4a.opponent = opponent
        node4a.isHidden = true
        suakeMiddle = node4a
        
        if(opponent){
            node1 = initOppSuakeNode(node: node1)
            suakeTail = initOppSuakeNode(node: node1a)
            suakeComplete = initOppSuakeNode(node: node1b)
            suakeHeadLeft = initOppSuakeNode(node: node2a)
            suakeTailLeft = initOppSuakeNode(node: node2b)
            suakeHeadRight = initOppSuakeNode(node: node2c)
            suakeTailRight = initOppSuakeNode(node: node2d)
            suakeExpand = initOppSuakeNode(node: node3)
            suakeMiddle = initOppSuakeNode(node: node4a)
        }
        
        return node1
    }
    /*func getSuakeNode(opponent:Bool)->SuakeNode{
        var node1:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_STRAIGHT_HEAD_1.dae") //Suake_SEPERATED_STRAIGHT_04_HEAD_1b.dae")//suake_straight_head_moving_NG.dae") //123456.dae") // suake_straight_head_moving_NG.dae") //suake_textx_whole_straight_moving8d.dae") //suake_straight_head_moving.dae") // suake_textx_whole_straight_moving6.dae") //suake_straight_head_moving.dae") // suake_ng_headpart.dae")
        //node1.isHidden = true
        /*let scene123 = SCNScene(named: "game.scnassets/suake/ng/Suake_straight_head_2.dae")
        /*var nodeExp*/ var nodeExp2:SCNNode = scene123?.rootNode.childNode(withName: "suake4Export", recursively: true)?.clone() as! SCNNode
        let geo:SCNGeometry = (scene123?.rootNode.childNode(withName: "suake4Export", recursively: true)?.childNodes[0].childNodes[2].childNodes[0].geometry)!
        nodeExp2.childNodes[0].childNodes[2].childNodes[0].geometry = geo.copy() as! SCNGeometry
        nodeExp.addChildNode(nodeExp2)
        //nodeExp.geometry = nodeExp2.geometry?.copy() as! SCNGeometry
        nodeExp.scale.x = scaleFactor
        nodeExp.scale.y = scaleFactor
        nodeExp.scale.z = scaleFactor
        nodeExp.position.x = 5
        nodeExp.position.y = 1
        nodeExp.position.z = 100
        if(opponent){
            /*var bb:SCNBox = SCNBox(mdlMesh: MDLMesh(scnNode: nodeExp))// geo.boundingBox
            //bb.boundingBox = geo.boundingBox
            //node1.name = node1.name! + "Opp"
            let nodeShape = SCNPhysicsShape(geometry: bb, options: [SCNPhysicsShape.Option.scale: SCNVector3(scaleFactor, scaleFactor, scaleFactor)])
            nodeExp.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nodeShape)
            nodeExp.physicsBody?.isAffectedByGravity = false
            nodeExp.physicsBody?.categoryBitMask = CollisionCategory.SuakeOpCategory
            nodeExp.physicsBody?.contactTestBitMask = CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory*/
             /*nodeExp2.childNodes[0].childNodes[2].childNodes[0].physicsBody = SCNPhysicsBody(type: .kinematic, shape: nodeShape)
             nodeExp2.childNodes[0].childNodes[2].childNodes[0].physicsBody?.isAffectedByGravity = false
             nodeExp2.childNodes[0].childNodes[2].childNodes[0].physicsBody?.categoryBitMask = CollisionCategory.SuakeOpCategory
             nodeExp2.childNodes[0].childNodes[2].childNodes[0].physicsBody?.contactTestBitMask = CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
        */
 //node1.physicsBody?.collisionBitMask = CollisionCategory.SuakeOpCategory|CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
        }
        
        
        /*var node1:SuakeNode = SuakeNode(geometry: nodeExp!.geo)
        var nodeArray3 = nodeExp?.childNodes
        
        var idx:Int = 0
        if let nodeExp = nodeExp {
            for i in (0..<nodeExp.animationKeys.count) {
                var key:String = nodeExp.animationKeys[i]
                var key2:String = key
                if(idx == 0){
                    //if(opponent){
                    //    key2 = key2 + "Opp"
                    //}
                    node1.animPlayer = key2
                    idx += 1
                }
                node1.addAnimationPlayer(nodeExp.animationPlayer(forKey: key)!, forKey: key2)
                node1.animationPlayer(forKey: key2)?.stop()
            }
        }
        
        for childNode1 in nodeArray3! {
            node1.childNode(withName: childNode1.name!, recursively: true)?.geometry = childNode1.geometry?.copy() as? SCNGeometry
        }*/
        //var node1234567:SuakeNodeNG = SuakeNodeNG(node: nodeExp!)
        */
        node1.name = "SuakeHead"
        node1.opponent = opponent
        if(opponent){
            //node1.name = node1.name! + "Opp"
            /*let nodeShape = SCNPhysicsShape(geometry: node1.geometry!, options: [SCNPhysicsShape.Option.scale: SCNVector3(scaleFactor, scaleFactor, scaleFactor)])
            node1.physicsBody = SCNPhysicsBody(type: .static, shape: nodeShape)
            node1.physicsBody?.isAffectedByGravity = false
            node1.physicsBody?.categoryBitMask = CollisionCategory.SuakeOpCategory
            node1.physicsBody?.contactTestBitMask = CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
            */
            //node1.physicsBody?.collisionBitMask = CollisionCategory.SuakeOpCategory|CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
        }else{
            /*let nodeShape = SCNPhysicsShape(geometry: node1.geometry!, options: [SCNPhysicsShape.Option.scale: SCNVector3(scaleFactor, scaleFactor, scaleFactor)])
            node1.physicsBody = SCNPhysicsBody(type: .static, shape: nodeShape)
            node1.physicsBody?.isAffectedByGravity = false
            node1.physicsBody?.categoryBitMask = CollisionCategory.SuakeCategory
            node1.physicsBody?.contactTestBitMask = CollisionCategory.SuakeCategory|CollisionCategory.SuakeOpCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory*/
            //node1.physicsBody?.collisionBitMask = CollisionCategory.SuakeCategory|CollisionCategory.SuakeOpCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
        }
        
        let node1b:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_STRAIGHT_COMPLETE_1.dae")
        node1b.name = "Complete"
        node1b.isHidden = true
        node1b.opponent = opponent
        suakeComplete = node1b
        
        var node1a:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_STRAIGHT_TAIL_1.dae") //Suake_SEPERATED_STRAIGHT_04_TAIL_1a.dae")//suake_straight_tail_moving_NG.dae") // suake_ng_tailpart.dae")
        node1a.name = "SuakeTail"
        node1a.opponent = opponent
        suakeTail = node1a
        /*if(opponent){
            let nodeShape = SCNPhysicsShape(geometry: suakeTail.geometry!, options: [SCNPhysicsShape.Option.scale: SCNVector3(scaleFactor, scaleFactor, scaleFactor)])
            suakeTail.physicsBody = SCNPhysicsBody(type: .static, shape: nodeShape)
            suakeTail.physicsBody?.isAffectedByGravity = false
            suakeTail.physicsBody?.categoryBitMask = CollisionCategory.SuakeOpCategory
            suakeTail.physicsBody?.contactTestBitMask = CollisionCategory.SuakeOpCategory|CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
            //node1a.physicsBody?.collisionBitMask = CollisionCategory.SuakeOpCategory|CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
        }else{
            let nodeShape = SCNPhysicsShape(geometry: suakeTail.geometry!, options: [SCNPhysicsShape.Option.scale: SCNVector3(scaleFactor, scaleFactor, scaleFactor)])
            suakeTail.physicsBody = SCNPhysicsBody(type: .static, shape: nodeShape)
            suakeTail.physicsBody?.isAffectedByGravity = false
            suakeTail.physicsBody?.categoryBitMask = CollisionCategory.SuakeCategory
            suakeTail.physicsBody?.contactTestBitMask = CollisionCategory.SuakeCategory|CollisionCategory.SuakeOpCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
            //node1a.physicsBody?.collisionBitMask = CollisionCategory.SuakeCategory|CollisionCategory.SuakeOpCategory|CollisionCategory.RocketCategory|CollisionCategory.BulletCategory
        }*/
        
        let node2a:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_LEFT_HEAD_2.dae") //Suake_LEFT_Head_1.dae") // suake_ng_headpart_left.dae")
        node2a.name = "BendLeftHead"
        node2a.isHidden = true
        node2a.opponent = opponent
        suakeHeadLeft = node2a
        
        let node2b:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_LEFT_TAIL_2.dae") //Suake_LEFT_Tail_1.dae") // suake_ng_headpart_left.dae")
        node2b.name = "BendLeftTail"
        node2b.isHidden = true
        node2b.opponent = opponent
        suakeTailLeft = node2b
        
        let node2c:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_RIGHT_HEAD_2.dae") //Suake_RIGHT_Head_1.dae") // suake_ng_headpart_left.dae")
        node2c.name = "BendRightHead"
        node2c.isHidden = true
        node2c.opponent = opponent
        suakeHeadRight = node2c
        
        let node2d:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_RIGHT_TAIL_2.dae") //Suake_RIGHT_Tail_1.dae") // suake_ng_headpart_left.dae")
        node2d.name = "BendRightTail"
        node2d.isHidden = true
        node2d.opponent = opponent
        suakeTailRight = node2d
        
        let node3:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_EXTRUDE_STRAIGHT.dae") //suake_straight_middle_extruding_NG.dae") // dae") // TesT_Extrude_With_DynJoints_1h.dae") //TesT_Extrude_With_DynJoints_1c.dae") //TesT_Extrude_With_DynJoints_1a.dae") //1111.dae")
        node3.name = "Expand"
        node3.opponent = opponent
        node3.isHidden = true
        suakeExpand = node3
        
        let node4a:SuakeNode = copyAllNodeElementsFromScene(sceneName: "game.scnassets/suake/ng/Suake_MIDDLE_STRAIGHT_MOVING.dae") // suake_straight_middle_moving_NG.dae") //suake_straight_middle_moving_NG_green.dae") //suake_straight_middle_moving_NG.dae") // suake_straight_middle_moving_ORIG.scn") //suake_straight_middle_moving_ORIG.dae") // suake_ng_tailpart.dae")
        node4a.name = "NodeMiddle"
        node4a.opponent = opponent
        node4a.isHidden = true
        suakeMiddle = node4a
        
        if(opponent){
            node1 = initOppSuakeNode(node: node1)
            suakeTail = initOppSuakeNode(node: node1a)
            suakeComplete = initOppSuakeNode(node: node1b)
            suakeHeadLeft = initOppSuakeNode(node: node2a)
            suakeTailLeft = initOppSuakeNode(node: node2b)
            suakeHeadRight = initOppSuakeNode(node: node2c)
            suakeTailRight = initOppSuakeNode(node: node2d)
            suakeExpand = initOppSuakeNode(node: node3)
            suakeMiddle = initOppSuakeNode(node: node4a)
        }
        
        return node1
    }*/
    
    func initOppSuakeNode(node:SuakeNode)->SuakeNode{
        //node.pos.x = 3
        //node.pos.z = 0 //= 10
        node.pos = DbgVars.oppPos
        node.position.x = node.pos.x * moveDist
        node.position.z = node.pos.z * moveDist + moveDist
        node.dir = .DOWN
        node.oldDir = .DOWN
        node.name = node.name! + "Opp"
        node.rotation = SCNVector4Make(0, 1, 0, CGFloat.pi)
        return node
    }
    
    var canceled:Bool = false
    func stopAnim(){
        canceled = true
        playAnim(anim: 0, play: false)
    }
    
    private var _isHidden: Bool = false             // _x -> backingX
    var isHidden: Bool {
        set {
            _isHidden = newValue
            suakeHead.isHidden = _isHidden
            suakeTail.isHidden = _isHidden
        }
        get { return _isHidden }
    }
    
    func togglePause(){
        //game.gameView.isPlaying = !game.gameView.isPlaying
        canceled = !canceled
        if(canceled){
            playAnim(anim: 0, play: false)
        }else{
            if(bend){
                //playAnim(anim: 1, play: true)
            }else{
                
                playAnim(anim: 0, play: true && animsRunning)
                //playAnim(anim: 2, play: true)
            }
        }
    }
    
    func playAnim2(nodeToUse:SuakeNode, play:Bool){
        if(play){
            nodeToUse.playAnim()
        }else{
            nodeToUse.stopAnim()
        }
    }
    
    func playAnim(anim:Int, play:Bool){
        let suakeElement2:SuakeNode = suakeTail
        let suakeElement3:SuakeNode = suakeExpand
        let suakeElement4:SuakeNode = suakeMiddle
        let suakeElement:SuakeNode = suakeHead
        let suakeElement5:SuakeNode = suakeComplete
        
        let suakeElement6:SuakeNode = suakeHeadLeft
        let suakeElement7:SuakeNode = suakeTailLeft
        let suakeElement8:SuakeNode = suakeHeadRight
        let suakeElement9:SuakeNode = suakeTailRight
        
        if(play){
            suakeElement.playAnim()
            suakeElement5.playAnim()
            suakeElement2.playAnim()
            suakeElement4.playAnim()
            for middle in suakeMiddles{
                middle.playAnim()
            }
            suakeElement3.playAnim()
        }else{
            suakeElement.stopAnim()
            suakeElement5.stopAnim()
            suakeElement6.stopAnim()
            suakeElement7.stopAnim()
            //suakeElement8.stopAnim()
            //suakeElement9.stopAnim()
            suakeElement3.stopAnim()
            suakeElement2.stopAnim()
            suakeElement4.stopAnim()
            for middle in suakeMiddles{
                middle.stopAnim()
            }
        }
    }
    
    var bendLeft:Bool = true
    var bend:Bool = false
    var bended:Bool = false
    
    func bendTrigger(newDir:SuakeDir){
        if(newDir == .RIGHT){
            if(suakeHead.dir == .UP){
                bendTrigger(bendLeft: false)
            }else{
                bendTrigger(bendLeft: true)
            }
        }else if(newDir == .LEFT){
            if(suakeHead.dir == .UP){
                bendTrigger(bendLeft: true)
            }else{
                bendTrigger(bendLeft: false)
            }
        }else if(newDir == .DOWN){
            if(suakeHead.dir == .RIGHT){
                bendTrigger(bendLeft: false)
            }else{
                bendTrigger(bendLeft: true)
            }
        }else if(newDir == .UP){
            if(suakeHead.dir == .LEFT){
                bendTrigger(bendLeft: false)
            }else{
                bendTrigger(bendLeft: true)
            }
        }
        suakeHead.oldDir = suakeHead.dir
        suakeHead.dir = newDir
    }
    
    func bendTrigger(bendLeft:Bool){
        self.bendLeft = bendLeft
        self.bended = false
        bend = true
    }
    
    var lookDir = SuakeDir.UP
    func adjustDir(dir:SuakeDir)->SuakeDir{
        var adjustedDir = dir
        if(lookDir == .LEFT){
            if(dir == .LEFT){
                adjustedDir = .DOWN
            }else if(dir == .UP){
                adjustedDir = .LEFT
            }else if(dir == .RIGHT){
                adjustedDir = .UP
            }
            lookDir = adjustedDir
        }else if(lookDir == .RIGHT){
            if(dir == .LEFT){
                adjustedDir = .UP
            }else if(dir == .UP){
                adjustedDir = .RIGHT
            }else if(dir == .RIGHT){
                adjustedDir = .DOWN
            }
            lookDir = adjustedDir
        }else if(lookDir == .DOWN){
            if(dir == .LEFT){
                adjustedDir = .RIGHT
            }else if(dir == .UP){
                adjustedDir = .DOWN
            }else if(dir == .RIGHT){
                adjustedDir = .LEFT
            }
            lookDir = adjustedDir
        }else{
            lookDir = dir
        }
        return adjustedDir
    }
    
    func setLookAtConstraint(nodeToUse:SCNNode) {
        let lookConst:SCNLookAtConstraint = SCNLookAtConstraint(target: nodeToUse)
        lookConst.isGimbalLockEnabled = true
        self.game.cameraNode.constraints = [lookConst]
    }

    func movePartsPos(step:CGFloat, x:Bool){
        if(!x){
            self.suakeTail.pos.z += step
            self.suakeTailLeft.pos.z += step
            self.suakeTailRight.pos.z += step
            self.suakeMiddle.pos.z += step
            for middle in self.suakeMiddles{
                middle.pos.z += step
            }
            self.suakeHead.pos.z += step
            self.suakeHeadLeft.pos.z += step
            self.suakeHeadRight.pos.z += step
            self.suakeComplete.pos.z += step
        }else{
            self.suakeTail.pos.x += step
            self.suakeTailLeft.pos.x += step
            self.suakeTailRight.pos.x += step
            self.suakeMiddle.pos.x += step
            for middle in self.suakeMiddles{
                middle.pos.x += step
            }
            self.suakeHead.pos.x += step
            self.suakeHeadLeft.pos.x += step
            self.suakeHeadRight.pos.x += step
            self.suakeComplete.pos.x += step
        }
    }
    
    func getMovePartsPosStep(val:CGFloat)->CGFloat{
        var step:CGFloat = 1.0
        if(val < 0){
            step = -1.0
        }
        return step
    }
    
    func moveParts(val:CGFloat, x:Bool){
        let step:CGFloat = getMovePartsPosStep(val: val)
        movePartsPos(step: step, x: x)
        game.arrows.showHideHelperArrows()
        if(!x){
            self.suakeComplete.position.z += val
            self.suakeHead.position.z += val
            self.suakeTail.position.z += val
            self.suakeTailLeft.position.z += val
            self.suakeTailRight.position.z += val
            self.suakeMiddle.position.z += val
            for middle in self.suakeMiddles{
                middle.position.z += val
            }
            self.suakeHeadLeft.position.z += val
            self.suakeHeadRight.position.z += val
            self.suakeExpand.position.z += val
            //game.rocketlauncher.gNodeFP.position.z += val
        }else{
            self.suakeComplete.position.x += val
            self.suakeHead.position.x += val
            self.suakeTail.position.x += val
            self.suakeTailLeft.position.x += val
            self.suakeTailRight.position.x += val
            self.suakeMiddle.position.x += val
            for middle in self.suakeMiddles{
                middle.position.x += val
            }
            self.suakeHeadLeft.position.x += val
            self.suakeHeadRight.position.x += val
            self.suakeExpand.position.x += val
        }
        moveSuake(dir: suakeHead.dir)
    }
    
    func dbgStopPlaying(){
        self.canceled = true
        self.game.setIsPlaying(false)
        self.game.gameView.isPlaying = false
        stopAnim()
    }
    
    func startAnim(){
        bend = false
        game.cameraNode.constraints = nil
        
        animsRunning = true
        playAnim(anim: 0, play: false)
        suakeHeadLeft.stopAnim()
        suakeTailLeft.stopAnim()
        canceled = false
        
        self.suakeExpand.isHidden = true
        
        let chainEventBlock69: SCNAnimationEventBlock = { animation, animatedObject, playingBackwards in
            if(self.opponent){
                self.suakeHead.oldDir = self.suakeHead.dir
                self.suakeHead.dir = self.aiCalcNextOpponentSuakeDir()
                if(self.suakeHead.oldDir != self.suakeHead.dir){
                    self.bend = true
                    self.bendLeft = true
                    self.bended = false
                    //self.bendTrigger(newDir: self.suakeHead.dir)
                }else{
                    
                }
            }
            let goodyAhead:Bool = self.moveAndCheck4GoodyAtNextPosNG(suakeHeadNode: self.suakeHead)
            if(goodyAhead){
                self.grow()
            }
            if(self.game.gameStarted && !self.canceled && !self.bend && !self.porting){
                if(self.suakeHead.dir == .UP){
                    self.moveOrGrow(pos: 1.0, x: false)
                    if(!self.opponent){
                        //self.game.rocketlauncher.moveAnim()
                    }
                }else if(self.suakeHead.dir == .LEFT){
                    self.moveOrGrow(pos: 1.0, x: true)
                }else if(self.suakeHead.dir == .DOWN){
                    self.moveOrGrow(pos: -1.0, x: false)
                }else if(self.suakeHead.dir == .RIGHT){
                    self.moveOrGrow(pos: -1.0, x: true)
                }
                
                if(!self.opponent){
                    self.animCameraNLights()
                }
                self.game.drawMapOverlay()
            }else if(self.bend && !self.canceled){
                if(!self.opponent){
                    self.game.drawMapOverlay()
                }
                self.canceled = true
                self.bended = false
                
                self.suakeHead.isHidden = true
                self.suakeTail.isHidden = true
                
                if(self.bendLeft){
                    self.suakeHeadLeft.isHidden = false
                    self.suakeTailLeft.isHidden = false
                }else{
                    self.suakeHeadRight.isHidden = false
                    self.suakeTailRight.isHidden = false
                }
                
                if(self.suakeHead.oldDir == .UP){
                    self.moveParts(val: self.moveDist, x: false)
                }else if(self.suakeHead.oldDir == .LEFT){
                    self.moveParts(val: self.moveDist, x: true)
                }else if(self.suakeHead.oldDir == .DOWN){
                    self.moveParts(val: self.moveDist * -1, x: false)
                }else if(self.suakeHead.oldDir == .RIGHT){
                    self.moveParts(val: self.moveDist * -1, x: true)
                }
                
                if(self.suakeHead.oldDir == .UP){
                    if(self.bendLeft){
                    }else{
                    }
                }else if(self.suakeHead.oldDir == .LEFT){
                    if(self.bendLeft){
                        self.suakeHead.rotation = SCNVector4Make(0, 1, 0, CGFloat.pi)
                        self.suakeTail.rotation = SCNVector4Make(0, 1, 0, CGFloat.pi)
                    }else{
                        self.suakeHeadRight.rotation = SCNVector4Make(0, 1, 0, 1.5708)
                        self.suakeTailRight.rotation = SCNVector4Make(0, 1, 0, 1.5708)
                        self.suakeHead.rotation = SCNVector4Make(0, 1, 0, CGFloat.pi)
                        self.suakeTail.rotation = SCNVector4Make(0, 1, 0, CGFloat.pi)
                    }
                }else if(self.suakeHead.oldDir == .DOWN){
                    if(self.bendLeft){
                        self.suakeHeadLeft.rotation = SCNVector4Make(0, 1, 0, 1.5708 * 2)
                        self.suakeTailLeft.rotation = SCNVector4Make(0, 1, 0, 1.5708 * 2)
                        self.suakeHead.rotation = SCNVector4Make(0, 1, 0, CGFloat.pi * 1.5)
                        self.suakeTail.rotation = SCNVector4Make(0, 1, 0, CGFloat.pi * 1.5)
                    }else{
                        self.suakeHeadRight.rotation = SCNVector4Make(0, 1, 0, 1.5708 * 2)
                        self.suakeTailRight.rotation = SCNVector4Make(0, 1, 0, 1.5708 * 2)
                    }
                }else if(self.suakeHead.oldDir == .RIGHT){
                    if(self.bendLeft){
                        self.suakeHeadLeft.rotation = SCNVector4Make(0, 1, 0, 1.5708 * 3)
                        self.suakeTailLeft.rotation = SCNVector4Make(0, 1, 0, 1.5708 * 3)
                        self.suakeHead.rotation = SCNVector4Make(0, 1, 0, CGFloat.pi * 2)
                        self.suakeTail.rotation = SCNVector4Make(0, 1, 0, CGFloat.pi * 2)
                    }else{
                        self.suakeHeadRight.rotation = SCNVector4Make(0, 1, 0, 1.5708 * 3)
                        self.suakeTailRight.rotation = SCNVector4Make(0, 1, 0, 1.5708 * 3)
                    }
                }
                
                if(self.bendLeft){
                    self.suakeHeadLeft.animation().repeatCount = 1
                    self.suakeTailLeft.animation().repeatCount = 1
                    self.suakeHeadLeft.animation().isAppliedOnCompletion = true
                    self.suakeHeadLeft.animation().isRemovedOnCompletion = false
                    self.suakeTailLeft.animation().isAppliedOnCompletion = true
                    self.suakeTailLeft.animation().isRemovedOnCompletion = false/**/
                    self.suakeHeadLeft.stopAnim()
                    self.suakeTailLeft.stopAnim()
                }else{
                    self.suakeHeadRight.animation().repeatCount = 1
                    self.suakeTailRight.animation().repeatCount = 1
                    self.suakeHeadRight.animation().isAppliedOnCompletion = true
                    self.suakeHeadRight.animation().isRemovedOnCompletion = false
                    self.suakeTailRight.animation().isAppliedOnCompletion = true
                    self.suakeTailRight.animation().isRemovedOnCompletion = false/**/
                    self.suakeHeadRight.stopAnim()
                    self.suakeTailRight.stopAnim()
                }
                
                self.game.cameraNode.constraints = nil
                
                let chainEventKim2: SCNAnimationEventBlock = { animation, animatedObject, playingBackwards in
                    if(self.opponent){
                        var i = -1
                        i /= -1
                    }
                    if(!self.bended && self.game.gameStarted){
                        self.bended = true
                        self.canceled = true
                        if(self.suakeHead.dir == .UP){
                            self.movePartsPos(step: self.getMovePartsPosStep(val: self.moveDist), x: false)
                        }else if(self.suakeHead.dir == .LEFT){
                            self.movePartsPos(step: self.getMovePartsPosStep(val: self.moveDist), x: true)
                        }else if(self.suakeHead.dir == .DOWN){
                            self.movePartsPos(step: self.getMovePartsPosStep(val: self.moveDist * -1), x: false)
                        }else if(self.suakeHead.dir == .RIGHT){
                            self.movePartsPos(step: self.getMovePartsPosStep(val: self.moveDist * -1), x: true)
                        }
                        if(self.suakeHead.dir == .LEFT){
                            if(self.bendLeft){
                                self.suakeHeadLeft.rotation = SCNVector4Make(0, 1, 0, 1.5708)
                                self.suakeTailLeft.rotation = SCNVector4Make(0, 1, 0, 1.5708)
                                
                                self.suakeHead.rotation = SCNVector4Make(0, 1, 0, 1.5708)
                                self.suakeTail.rotation = SCNVector4Make(0, 1, 0, 1.5708)
                                
                                self.adjustAllSuakeNodesPos(x: self.moveDist, z: self.moveDist)
                                
                                self.suakeHeadLeft.isHidden = true
                                self.suakeTailLeft.isHidden = true
                            }else{
                                self.suakeHead.rotation = SCNVector4Make(0, 1, 0, 1.5708)
                                self.suakeTail.rotation = SCNVector4Make(0, 1, 0, 1.5708)
                                
                                self.adjustAllSuakeNodesPos(x: self.moveDist, z: self.moveDist * -1)
                                
                                self.suakeHeadRight.isHidden = true
                                self.suakeTailRight.isHidden = true
                            }
                        }else if(self.suakeHead.dir == .UP){
                            if(self.bendLeft){
                                self.suakeHeadLeft.rotation = SCNVector4Make(0, 0, 0, 1.5708)
                                self.suakeTailLeft.rotation = SCNVector4Make(0, 0, 0, 1.5708)
                                
                                self.adjustAllSuakeNodesPos(x: self.moveDist * -1, z: self.moveDist)
                                
                                self.suakeHeadLeft.isHidden = true
                                self.suakeTailLeft.isHidden = true
                            }else{
                                self.suakeHeadRight.rotation = SCNVector4Make(0, 0, 0, 1.5708)
                                self.suakeTailRight.rotation = SCNVector4Make(0, 0, 0, 1.5708)
                                
                                self.suakeHead.rotation = SCNVector4Make(0, 0, 0, 1.5708)
                                self.suakeTail.rotation = SCNVector4Make(0, 0, 0, 1.5708)
                                
                                self.adjustAllSuakeNodesPos(x: self.moveDist, z: self.moveDist)
                                
                                self.suakeHeadRight.isHidden = true
                                self.suakeTailRight.isHidden = true
                            }
                        }else if(self.suakeHead.dir == .DOWN){
                            if(self.bendLeft){
                                self.suakeHeadLeft.rotation = SCNVector4Make(0, 2, 0, 1.5708)
                                self.suakeTailLeft.rotation = SCNVector4Make(0, 2, 0, 1.5708)
                                
                                self.adjustAllSuakeNodesPos(x: self.moveDist, z: self.moveDist * -1)
                                
                                self.suakeHeadLeft.isHidden = true
                                self.suakeTailLeft.isHidden = true
                            }else{
                                self.suakeHead.rotation = SCNVector4Make(0, 1, 0, CGFloat.pi)
                                self.suakeTail.rotation = SCNVector4Make(0, 1, 0, CGFloat.pi)
                                
                                self.adjustAllSuakeNodesPos(x: self.moveDist * -1, z: self.moveDist * -1)
                                self.suakeHeadRight.isHidden = true
                                self.suakeTailRight.isHidden = true
                            }
                        }else if(self.suakeHead.dir == .RIGHT){
                            if(self.bendLeft){
                                self.suakeHeadLeft.rotation = SCNVector4Make(0, 2, 0, 1.5708)
                                self.suakeTailLeft.rotation = SCNVector4Make(0, 2, 0, 1.5708)
                                
                                self.adjustAllSuakeNodesPos(x: self.moveDist * -1, z: self.moveDist * -1)
                                
                                self.suakeHeadLeft.isHidden = true
                                self.suakeTailLeft.isHidden = true
                            }else{
                                self.suakeHead.rotation = SCNVector4Make(0, -1, 0, 1.5708)
                                self.suakeTail.rotation = SCNVector4Make(0, -1, 0, 1.5708)
                                
                                self.adjustAllSuakeNodesPos(x: self.moveDist * -1, z: self.moveDist)
                                
                                self.suakeHeadRight.isHidden = true
                                self.suakeTailRight.isHidden = true
                            }
                        }
                        self.suakeHead.oldDir = self.suakeHead.dir
                        self.suakeHead.isHidden = false
                        self.suakeTail.isHidden = false

                        self.bend = false
                        self.bended = true
                        self.canceled = false
 
                        self.playAnim(anim: 0, play: true)
                        if(!self.opponent){
                            self.animCameraNLights()
                            self.game.drawMapOverlay()
                        }
                    }
                }
                
                if(self.suakeHeadLeft.animation().animationEvents == nil || self.suakeHeadLeft.animation().animationEvents?.count == 0) {
                    self.suakeHeadLeft.animation().animationEvents = [SCNAnimationEvent(keyTime: 1.0, block: chainEventKim2)]
                }
                
                if(self.suakeHeadRight.animation().animationEvents == nil || self.suakeHeadRight.animation().animationEvents?.count == 0) {
                    self.suakeHeadRight.animation().animationEvents = [SCNAnimationEvent(keyTime: 1.0, block: chainEventKim2)]
                }
                
                // TODO Tmp solution
                if(self.bendLeft){
                    self.suakeHeadLeft.playAnim()
                    self.suakeTailLeft.playAnim()
                }else{
                    self.suakeHeadRight.playAnim()
                    self.suakeTailRight.playAnim()
                }
                if(!self.opponent){
                    self.animCameraNLights()
                }else{
                    self.canceled = false
                }
                self.game.drawMapOverlay()
                self.bend = false
            }
        }
        
        if(self.suakeHead.animation().animationEvents == nil || self.suakeHead.animation().animationEvents?.count == 0) {
            self.suakeHead.animation().animationEvents = [SCNAnimationEvent(keyTime: 1.0, block: chainEventBlock69)]
        }
        
        tmp = self.suakeHead.presentation.position.z
        playAnim(anim: 0, play: true)
        if(!opponent){
            //self.game.rocketlauncher.moveAnim()
        }
        self.animCameraNLights()
        self.game.drawMapOverlay()
    }
    
    func moveOrGrow(pos:CGFloat, x:Bool){
        self.playAnim(anim: 0, play: false)
        self.playAnim(anim: 0, play: true)
        if(self.growCount > 0){
            self.moveParts(val: self.moveDist * pos, x: x)
            if(!self.canceled){
                self.suakeTail.stopAnim()
                self.suakeExpand.isHidden = false
                self.suakeExpand.stopAnim()
                self.suakeExpand.playAnim()
                self.growCount -= 1
                self.expanded = true
            }else{
                return
            }
        }else{
            if(self.expanded){
                self.expanded = false
                if(x){
                    self.suakeHead.pos.x += pos
                    self.suakeHead.position.x += pos * self.moveDist
                }else{
                    self.suakeHead.pos.z += pos
                    self.suakeHead.position.z += pos * self.moveDist
                }
                self.suakeExpand.isHidden = true
                self.suakeMiddles.append(self.suakeMiddle.duplicateSuakeNode())
                self.suakeMiddles.last?.isHidden = false
                self.suakeMiddles.last?.pos = self.suakeMiddle.pos
                self.suakeMiddles.last?.position = self.suakeMiddle.position
                self.arrSuakeNodes.append(self.suakeMiddles.last!)
                let lastPos = CGFloat(self.suakeMiddles.count - 1)
                if(lastPos > 0){
                    if(x){
                        self.suakeMiddles.last?.position.x += lastPos * pos * self.moveDist
                        self.suakeMiddles.last?.pos.x += lastPos * pos
                    }else{
                        self.suakeMiddles.last?.position.z += lastPos * pos * self.moveDist
                        self.suakeMiddles.last?.pos.z += lastPos * pos
                    }
                }
                self.suakeMiddles.last?.name = "SuakeMIDDLE: " + lastPos.description
                self.game.gameView.scene?.rootNode.addChildNode(self.suakeMiddles.last!)
            }else{
                self.moveParts(val: self.moveDist * pos, x: x)
            }
        }
    }
    
    func adjustAllSuakeNodesPos(x:CGFloat, z:CGFloat){
        adjustSuakeNodesPos(suakeNode: suakeHead, x: x, z: z)
        adjustSuakeNodesPos(suakeNode: suakeTail, x: x, z: z)
        adjustSuakeNodesPos(suakeNode: suakeHeadLeft, x: x, z: z)
        adjustSuakeNodesPos(suakeNode: suakeTailLeft, x: x, z: z)
        adjustSuakeNodesPos(suakeNode: suakeHeadRight, x: x, z: z)
        adjustSuakeNodesPos(suakeNode: suakeTailRight, x: x, z: z)
    }
    
    func setSuakeNodesPos(suakeNode:SCNNode, x:CGFloat, y:CGFloat, z:CGFloat){
        suakeNode.position.x = x //suakeHead.position.x - moveDist
        suakeNode.position.y = y //game.camPosOrig.y
        suakeNode.position.z = z //suakeHead.position.z - game.camPosOrig.z - halfDist
    }
    
    func adjustSuakeNodesPos(suakeNode:SCNNode, x:CGFloat, z:CGFloat){
        suakeNode.position.x += x
        suakeNode.position.z += z
    }
    
    var cnt:Int = 0
    var tmp:CGFloat = 0
    
    func animCameraNLights(){
        if(!opponent){
            let halfDist = (moveDist / 2)
            SCNTransaction.begin()
            let linear = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            SCNTransaction.animationTimingFunction = linear
            SCNTransaction.animationDuration = 1
            if(suakeHead.dir == .UP){
                if(suakeHead.oldDir == .UP){
                    game.cameraNode.position.z += moveDist
                    game.cameraNodeFP.position.z += moveDist
                    game.lightNode.position.z += moveDist
                }else if(suakeHead.oldDir == .RIGHT){
                    game.cameraNode.transform = SCNMatrix4MakeRotation(CGFloat(Double.pi) * 1.0, 0.0, -1.0, 0.0)
                    //game.cameraNode.position.x = suakeHead.position.x - moveDist
                    //game.cameraNode.position.y = game.camPosOrig.y
                    //game.cameraNode.position.z = suakeHead.position.z + game.camPosOrig.z + halfDist
                    setSuakeNodesPos(suakeNode: game.cameraNode, x: suakeHead.position.x - moveDist, y: game.camPosOrig.y, z: suakeHead.position.z + game.camPosOrig.z + halfDist)
                    adjustSuakeNodesPos(suakeNode: game.lightNode, x: -moveDist, z: moveDist)
                    //game.lightNode.position.x = suakeHead.position.x - moveDist
                    //game.lightNode.position.z = suakeHead.position.z + moveDist
                    SCNTransaction.animationDuration = 2
                }else if(suakeHead.oldDir == .LEFT){
                    game.cameraNode.transform = SCNMatrix4MakeRotation(CGFloat(Double.pi) * 1.0, 0.0, -1.0, 0.0)
                    //game.cameraNode.position.x = suakeHead.position.x + moveDist
                    //game.cameraNode.position.y = game.camPosOrig.y
                    //game.cameraNode.position.z = suakeHead.position.z + game.camPosOrig.z + halfDist
                    setSuakeNodesPos(suakeNode: game.cameraNode, x: suakeHead.position.x + moveDist, y: game.camPosOrig.y, z: suakeHead.position.z + game.camPosOrig.z + halfDist)
                    adjustSuakeNodesPos(suakeNode: game.lightNode, x: moveDist, z: moveDist)
                    //game.lightNode.position.x = suakeHead.position.x + moveDist
                    //game.lightNode.position.z = suakeHead.position.z + moveDist
                    SCNTransaction.animationDuration = 2
                }
            }else if(suakeHead.dir == .DOWN){
                if(suakeHead.oldDir == .LEFT){
                    game.cameraNode.transform = SCNMatrix4MakeRotation(CGFloat(Double.pi) * 0.0, 0.0, -1.0, 0.0)
                    //game.cameraNode.position.x = suakeHead.position.x + moveDist
                    //game.cameraNode.position.y = game.camPosOrig.y
                    //game.cameraNode.position.z = suakeHead.position.z - game.camPosOrig.z - halfDist
                    setSuakeNodesPos(suakeNode: game.cameraNode, x: suakeHead.position.x + moveDist, y: game.camPosOrig.y, z: suakeHead.position.z - game.camPosOrig.z - halfDist)
                    adjustSuakeNodesPos(suakeNode: game.lightNode, x: moveDist, z: -moveDist)
                    //game.lightNode.position.x = suakeHead.position.x + moveDist
                    //game.lightNode.position.z = suakeHead.position.z - moveDist
                    SCNTransaction.animationDuration = 2
                }else if(suakeHead.oldDir == .RIGHT){
                    game.cameraNode.transform = SCNMatrix4MakeRotation(CGFloat(Double.pi) * 0.0, 0.0, -1.0, 0.0)
                    //game.cameraNode.position.x = suakeHead.position.x - moveDist
                    //game.cameraNode.position.y = game.camPosOrig.y
                    //game.cameraNode.position.z = suakeHead.position.z - game.camPosOrig.z - halfDist
                    setSuakeNodesPos(suakeNode: game.cameraNode, x: suakeHead.position.x - moveDist, y: game.camPosOrig.y, z: suakeHead.position.z - game.camPosOrig.z - halfDist)
                    adjustSuakeNodesPos(suakeNode: game.lightNode, x: -moveDist, z: -moveDist)
                    //game.lightNode.position.x = suakeHead.position.x - moveDist
                    //game.lightNode.position.z = suakeHead.position.z - moveDist
                    SCNTransaction.animationDuration = 2
                }else if(suakeHead.oldDir == .DOWN){
                    game.cameraNode.position.z -= moveDist
                    game.lightNode.position.z -= moveDist
                }
            }else if(suakeHead.dir == .RIGHT){
                if(suakeHead.oldDir == .UP){
                    game.cameraNode.transform = SCNMatrix4MakeRotation(CGFloat(Double.pi) * 1.5, 0.0, -1.0, 0.0)
                    //game.cameraNode.position.x = suakeHead.position.x - game.camPosOrig.z - halfDist
                    //game.cameraNode.position.y = game.camPosOrig.y
                    //game.cameraNode.position.z = suakeHead.position.z + moveDist
                    setSuakeNodesPos(suakeNode: game.cameraNode, x: suakeHead.position.x - game.camPosOrig.z - halfDist, y: game.camPosOrig.y, z: suakeHead.position.z + moveDist)
                    adjustSuakeNodesPos(suakeNode: game.lightNode, x: -moveDist, z: moveDist)
                    //game.lightNode.position.x = suakeHead.position.x - moveDist
                    //game.lightNode.position.z = suakeHead.position.z + moveDist
                    SCNTransaction.animationDuration = 2
                }else if(suakeHead.oldDir == .RIGHT){
                    game.cameraNode.position.x -= moveDist
                    game.cameraNode.constraints = nil
                    game.lightNode.position.x -= moveDist
                }else if(suakeHead.oldDir == .DOWN){
                    game.cameraNode.transform = SCNMatrix4MakeRotation(CGFloat(Double.pi) * 1.5, 0.0, -1.0, 0.0)
                    //game.cameraNode.position.x = suakeHead.position.x - game.camPosOrig.z - halfDist
                    //game.cameraNode.position.y = game.camPosOrig.y
                    //game.cameraNode.position.z = suakeHead.position.z - moveDist
                    setSuakeNodesPos(suakeNode: game.cameraNode, x: suakeHead.position.x - game.camPosOrig.z - halfDist, y: game.camPosOrig.y, z: suakeHead.position.z - moveDist)
                    adjustSuakeNodesPos(suakeNode: game.lightNode, x: -moveDist, z: -moveDist)
                    //game.lightNode.position.x = suakeHead.position.x - moveDist
                    //game.lightNode.position.z = suakeHead.position.z - moveDist
                    SCNTransaction.animationDuration = 2
                }
            }else if(suakeHead.dir == .LEFT){
                if(suakeHead.oldDir == .UP){
                    game.cameraNode.transform = SCNMatrix4MakeRotation(CGFloat(Double.pi) * 0.5, 0.0, -1.0, 0.0)
                    //game.cameraNode.position.x = suakeHead.position.x + game.camPosOrig.z + halfDist
                    //game.cameraNode.position.y = game.camPosOrig.y
                    //game.cameraNode.position.z = suakeHead.position.z + moveDist
                    setSuakeNodesPos(suakeNode: game.cameraNode, x: suakeHead.position.x + game.camPosOrig.z + halfDist, y: game.camPosOrig.y, z: suakeHead.position.z + moveDist)
                    adjustSuakeNodesPos(suakeNode: game.lightNode, x: moveDist, z: moveDist)
                    //game.lightNode.position.x = suakeHead.position.x + /*game.camPosOrig.z + */ moveDist
                    //game.lightNode.position.z = suakeHead.position.z + moveDist
                    SCNTransaction.animationDuration = 2
                }else if(suakeHead.oldDir == .LEFT){
                    game.cameraNode.position.x += moveDist
                    game.cameraNode.constraints = nil
                    game.lightNode.position.x += moveDist
                }else if(suakeHead.oldDir == .DOWN){
                    let tmpPos:SCNVector3 = game.cameraNode.position
                    game.cameraNode.transform = SCNMatrix4MakeRotation(CGFloat(Double.pi) * 0.5, 0.0, -1.0, 0.0)
                    //game.cameraNode.position.x = suakeHead.position.x + game.camPosOrig.z + halfDist
                    //game.cameraNode.position.y = game.camPosOrig.y
                    //game.cameraNode.position.z = suakeHead.position.z - game.suake.moveDist
                    //game.lightNode.position.x = suakeHead.position.x + moveDist
                    //game.lightNode.position.z = suakeHead.position.z - moveDist
                    setSuakeNodesPos(suakeNode: game.cameraNode, x: suakeHead.position.x + game.camPosOrig.z + halfDist, y: game.camPosOrig.y, z: suakeHead.position.z - moveDist)
                    adjustSuakeNodesPos(suakeNode: game.lightNode, x: moveDist, z: -moveDist)
                    SCNTransaction.animationDuration = 2
                }
            }
            SCNTransaction.commit()
        }
    }
    
    init(_gameBoard: GameViewController, opponent: Bool){
        self.opponent = opponent
        game = _gameBoard
        super.init()
        
        machinegun = Machinegun(_game: game)
        shotgun = Shotgun(_game: game)
        rocketlauncher = Rocketlauncher(_game: game)
        railgun = RailgunNG(_game: game)
        
        if(opponent){
            suakeHead = self.getSuakeNode(opponent: opponent)
        }else{
            suakeHead = self.getSuakeNode(opponent: opponent)
        }
        arrSuakeNodes = [SuakeNode]()
        arrSuakeNodes.append(suakeHead)
        arrSuakeNodes.append(suakeTail)
        addAllSuakeNodesToBoard()
    }
    
    convenience init(_gameBoard: GameViewController){
        self.init(_gameBoard: _gameBoard, opponent: false)
    }
    
    func key2SuakeDir(keyCode:KeyCode)->SuakeDir{
        var suakeDir = SuakeDir.UNDEF
        switch keyCode {
        case KeyCode.KEY_LEFT:
            suakeDir = SuakeDir.LEFT
        case KeyCode.KEY_RIGHT:
            suakeDir = SuakeDir.RIGHT
        case KeyCode.KEY_DOWN:
            suakeDir = SuakeDir.DOWN
        case KeyCode.KEY_UP:
            suakeDir = SuakeDir.UP
        default:
            suakeDir = SuakeDir.UNDEF
        }
        return suakeDir
    }
    
    func key2SuakeDirNG(keyCode:KeyboardDirection)->SuakeDir{
        var suakeDir = SuakeDir.UNDEF
        switch keyCode {
        case KeyboardDirection.KEY_LEFT:
            suakeDir = SuakeDir.LEFT
        case KeyboardDirection.KEY_RIGHT:
            suakeDir = SuakeDir.RIGHT
        case KeyboardDirection.KEY_DOWN:
            suakeDir = SuakeDir.DOWN
        case KeyboardDirection.KEY_UP:
            suakeDir = SuakeDir.UP
        default:
            suakeDir = SuakeDir.UNDEF
        }
        return suakeDir
    }
    
    /*func appendSuakeNodeInt(){
        var suakeNode2 = getSuakeNode(opponent: opponent)
        
        suakeNode2.nodePos = arrSuakeNodes.count
        suakeNode2.pos = arrSuakeNodes[arrSuakeNodes.count - 1].pos
        suakeNode2.oldPos = arrSuakeNodes[arrSuakeNodes.count - 1].oldPos
        suakeNode2.dir = arrSuakeNodes[arrSuakeNodes.count - 1].oldDir
        suakeNode2.oldDir = arrSuakeNodes[arrSuakeNodes.count - 1].oldDir
        
        suakeNode2.position = arrSuakeNodes[arrSuakeNodes.count - 1].oldPosition
        suakeNode2.oldPosition = arrSuakeNodes[arrSuakeNodes.count - 1].oldPosition
        
        if(opponent){
            /*let suakeHeadShape2 = SCNPhysicsShape(geometry: suakeNode2.geometry!, options: [SCNPhysicsShape.Option.scale: SCNVector3(25, 25, 25)])
            suakeNode2.physicsBody = SCNPhysicsBody(type: .kinematic, shape: suakeHeadShape2)
            suakeNode2.physicsBody?.isAffectedByGravity = true
            suakeNode2.physicsBody?.categoryBitMask = CollisionCategory.SuakeOpCategory*/
        }else{
            let suakeHeadShape2 = SCNPhysicsShape(geometry: suakeNode2.geometry!, options: nil)
            suakeNode2.physicsBody = SCNPhysicsBody(type: .kinematic, shape: suakeHeadShape2)
            suakeNode2.physicsBody?.isAffectedByGravity = true
            suakeNode2.physicsBody?.categoryBitMask = CollisionCategory.SuakeCategory
        }
        
        score += 100
        if(!opponent){
            //game.lbl.text = "Score: " + String(score)
        }
        //arrSuakeNodes.append(suakeNode2)
        //game.gameView.scene?.rootNode.addChildNode(suakeNode2)
    }
    
    func appendSuakeNode(){
        let when = DispatchTime.now() + (game.moveDelay * 0.5)
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.appendSuakeNodeInt()
        }
    }*/
    
    func aiCalcNextOpponentSuakeDir()->SuakeDir{
        var dirRet = SuakeDir.DOWN
        if(game.goodyNode.pos.z < self.suakeHead.pos.z - 1){
            dirRet = SuakeDir.DOWN
        }else if(game.goodyNode.pos.z > self.suakeHead.pos.z + 1){
            dirRet = SuakeDir.UP
        }else{
            if(game.goodyNode.pos.x < self.suakeHead.pos.x - 1){
                dirRet = SuakeDir.RIGHT
            }else if(game.goodyNode.pos.x > self.suakeHead.pos.x + 1){
                dirRet = SuakeDir.LEFT
            }
        }
        return dirRet
    }
    
    func checkNextField()->SuakeFields{
        var nextField:SuakeFields = SuakeFields.empty
        if((suakeHead.pos.x > (game.wallFields / 2)) ||
            (suakeHead.pos.x < (game.wallFields / 2 * -1)) ||
            (suakeHead.pos.z > (game.wallFields / 2)) ||
            (suakeHead.pos.z < (game.wallFields / 2 * -1))){
            nextField.insert(SuakeFields.wall)
            return nextField
        }
        if(checkNextFieldInt(suakeHeadNode: suakeHead, fieldToCheck: game.goodyNode)){
            nextField.insert(SuakeFields.goody)
        }
        if(opponent){
            for i in (0..<arrSuakeNodes.count){
                if(game.suake.suakeHead.pos.x == arrSuakeNodes[i].pos.x && game.suake.suakeHead.pos.z == arrSuakeNodes[i].pos.z){
                    nextField.insert(SuakeFields.opp_suake)
                    break
                }
            }
        }else{
            for i in (0..<arrSuakeNodes.count){
                if(game.suakeOpp.suakeHead.pos.x == arrSuakeNodes[i].pos.x && game.suakeOpp.suakeHead.pos.z == arrSuakeNodes[i].pos.z){
                    nextField.insert(SuakeFields.opp_suake)
                    break
                }
            }
        }
        
        if(game.fireNode.show && (suakeHead.pos.x == game.fireNode.pos.x && suakeHead.pos.z == game.fireNode.pos.z)){
            nextField.insert(SuakeFields.fire)
            CameraHelper.showHitAnim(game: game)
        }
        
        if(!opponent && suakeHead.pos.x == game.machinegunWP.pos.x && suakeHead.pos.z == game.machinegunWP.pos.z){
            nextField.insert(SuakeFields.machinegun)
            machinegun.ammoCount += game.machinegunWP.shotsPerPickup
            //game.machinegunWP.shots += game.machinegunWP.shotsPerPickup
            selectWeapon(weaponToSelect: CollisionCategory.MachineGunCategory, pickedUp: true)
            game.machinegunWP.posOnBoard(pos: SCNVector3(x: game.machinegunWP.pos.x + 2, y: game.machinegunWP.pos.y, z: game.machinegunWP.pos.z))
        }
        
        if(!opponent && suakeHead.pos.x == game.rocketlauncherWP.pos.x && suakeHead.pos.z == game.rocketlauncherWP.pos.z){
            nextField.insert(SuakeFields.rocketlauncher)
            //game.rocketlauncherWP.shots += game.rocketlauncherWP.shotsPerPickup
            selectWeapon(weaponToSelect: CollisionCategory.RocketLauncherCategory, pickedUp: true)
            game.rocketlauncherWP.posOnBoard(pos: SCNVector3(x: game.rocketlauncherWP.pos.x + 2, y: game.rocketlauncherWP.pos.y, z: game.rocketlauncherWP.pos.z))
        }
        
        if(!opponent && suakeHead.pos.x == game.shotgunWP.pos.x && suakeHead.pos.z == game.shotgunWP.pos.z){
            nextField.insert(SuakeFields.shotgun)
            shotgun.ammoCount += game.shotgunWP.shotsPerPickup
            selectWeapon(weaponToSelect: CollisionCategory.ShotgunCategory, pickedUp: true)
            game.shotgunWP.posOnBoard(pos: SCNVector3(x: game.shotgunWP.pos.x + 2, y: game.shotgunWP.pos.y, z: game.shotgunWP.pos.z))
        }
        
        if(!opponent && suakeHead.pos.x == game.railgunWP.pos.x && suakeHead.pos.z == game.railgunWP.pos.z){
            nextField.insert(SuakeFields.railgun)
            railgun.ammoCount += game.railgunWP.shotsPerPickup
            selectWeapon(weaponToSelect: CollisionCategory.RailGunCategory, pickedUp: true)
            game.railgunWP.posOnBoard(pos: SCNVector3(x: game.railgunWP.pos.x + 2, y: game.railgunWP.pos.y, z: game.railgunWP.pos.z))
        }
        
        for i in (0..<game.allPortalGroups.count){
            if(suakeHead.pos.x == game.allPortalGroups[i].portalIn.pos.x && suakeHead.pos.z == game.allPortalGroups[i].portalIn.pos.z){
                nextField.insert(SuakeFields.portal)
                if(!opponent){
                    game.mediaManager.playSound(soundType: .telein)
                    var suakeNodeToBeam:SuakeNode = suakeHead // (contact.nodeB as! SuakeNode)
                    beamNode(suakeNodeToBeam: suakeNodeToBeam, outPortal: game.allPortalGroups[i].portalOut)
                }
                break
            }
        }
        return nextField
    }
    
    let offset:CGFloat = -150
    
    func beamNode(suakeNodeToBeam:SuakeNode, outPortal:Portal){
        if(suakeNodeToBeam.beamed){
            suakeNodeToBeam.beamed = false
            stopAnim()
            if(suakeNodeToBeam.isEqual(to: suakeHead)){
                //game.gameView.overlaySKScene?.isHidden = true
                game.gameView.backgroundColor = NSColor.black
                suakeNodeToBeam.pos.x = outPortal.pos.x
                suakeNodeToBeam.pos.z = outPortal.pos.z
                if(!suakeMiddle.isHidden){
                    suakeNodeToBeam.pos.z += 1
                }
                if(suakeMiddles.count > 0){
                    suakeNodeToBeam.pos.z += CGFloat(suakeMiddles.count)
                }
                suakeNodeToBeam.position.x = suakeNodeToBeam.pos.x * 100 //- 50
                suakeNodeToBeam.position.z = suakeNodeToBeam.pos.z * 100 // + 100
                
                game.enterWH(outPortal:outPortal)
            }else{
                reposParts(node: suakeNodeToBeam, newPos: outPortal.pos)
                reposAllParts(newPos: outPortal.pos)
                
                game.cameraNode.position.x = suakeNodeToBeam.pos.x * 100//- 50
                game.cameraNode.position.z = suakeNodeToBeam.pos.z * 100 /*+ 100*/ //- 190
                if(game.suake.suakeHead.dir == .LEFT){
                    game.cameraNode.position.x -= 190
                }else if(game.suake.suakeHead.dir == .RIGHT){
                    game.cameraNode.position.x += 190
                }else if(game.suake.suakeHead.dir == .UP){
                    game.cameraNode.position.z -= 190
                }else if(game.suake.suakeHead.dir == .DOWN){
                    game.cameraNode.position.z += 190
                }
                game.cameraNode.position.y = 45
                
                game.cameraNodeFP.position = suakeHead.presentation.position
                game.cameraNodeFP.position.z += suakeHead.size.z / 10
                
                suakeNodeToBeam.beamed = true
                startAnim()
            }
        }
    }
    
    func reposAllParts(newPos:SCNVector3){
        reposParts(node: suakeHeadRight, newPos: newPos)
        reposParts(node: suakeTailRight, newPos: newPos)
        reposParts(node: suakeHeadLeft, newPos: newPos)
        reposParts(node: suakeTailLeft, newPos: newPos)
        reposParts(node: suakeExpand, newPos: newPos)
        reposParts(node: suakeMiddle, newPos: newPos)
        for middle in suakeMiddles{
            reposParts(node: middle, newPos: newPos)
        }
        game.lightNode.position.x = newPos.x * 100 //- 50
        game.lightNode.position.z = newPos.z * 100 /*+ 100*/
    }
    
    func reposParts(node:SuakeNode, newPos:SCNVector3){
        node.pos.x = newPos.x
        node.pos.z = newPos.z
        node.position.x = node.pos.x * 100 //- 50
        node.position.z = node.pos.z * 100 /*+ 100*/
    }
    
    func checkNextFieldInt(suakeHeadNode:SuakeNode, fieldToCheck:BaseSuakeNode)->Bool{
        var fieldHit:Bool = false
        if(suakeHeadNode.dir == .DOWN){
            if(fieldToCheck.pos.x == suakeHeadNode.pos.x && fieldToCheck.pos.z == suakeHeadNode.pos.z){
                fieldHit = true
            }
        }else if(suakeHeadNode.dir == .UP){
            if(fieldToCheck.pos.x == suakeHeadNode.pos.x && fieldToCheck.pos.z == suakeHeadNode.pos.z){
                fieldHit = true
            }
        }else if(suakeHeadNode.dir == .LEFT){
            if(fieldToCheck.pos.z == suakeHeadNode.pos.z && fieldToCheck.pos.x == suakeHeadNode.pos.x){
                fieldHit = true
            }
        }else if(suakeHeadNode.dir == .RIGHT){
            if(fieldToCheck.pos.z == suakeHeadNode.pos.z && fieldToCheck.pos.x == suakeHeadNode.pos.x){
                fieldHit = true
            }
        }
        return fieldHit
    }
    
    func calcNextDir4KI()->SuakeDir{
        var dirRet = SuakeDir.UP
        let opHead:SuakeNode = suakeHead
        
        if(game.goodyNode.pos.x == opHead.pos.x){
            if(game.goodyNode.pos.z == opHead.pos.z){
                dirRet = SuakeDir.UP
            }else if(game.goodyNode.pos.z < opHead.pos.z){
                dirRet = SuakeDir.DOWN
            }else if(game.goodyNode.pos.z > opHead.pos.z){
                dirRet = SuakeDir.UP
            }
        }else if(game.goodyNode.pos.x < opHead.pos.x){
            dirRet = SuakeDir.RIGHT
        }else if(game.goodyNode.pos.x > opHead.pos.x){
            dirRet = SuakeDir.LEFT
        }
        return dirRet
    }
    
    func moveSuake(){
        if(opponent){
            if(game.kiOn){
                moveSuake(dir:calcNextDir4KI())
            }else{
                moveSuake(dir:opPath[opStep])
                if(opStep >= opPath.count - 1){
                    opStep = 0
                }else{
                    opStep += 1
                }
            }
        }else{
            moveSuake(dir: suakeHead.dir)
        }
    }
    
    func setHealth(health:Int){
        if(health <= 0){
            self.health = 0
        }else{
            self.health = health
        }
        if(!opponent){
            game.lblHealth.text = "Health: " + self.health.description + "%"
        }else{
            game.showDbgMsg(dbgMsg: "SuakeOpp: Opponent health: " + self.health.description + "%")
        }
        if(self.health == 0){
            game.gameOver(didYouDie: !opponent)
        }
    }
    
    func moveSuake(dir:SuakeDir){
        for i in (0..<arrSuakeNodes.count).reversed(){
            if(i > 0){
                arrSuakeNodes[i].dir = arrSuakeNodes[i - 1].dir
            }else{
                suakeHead.dir = dir
                let goodyAhead:Bool = moveAndCheck4GoodyAtNextPos(suakeHeadNode: suakeHead)
                if(goodyAhead){
                    self.score += 9
                    self.game.goodyNode.newGoodyPos()
                    game.arrows.showHideHelperArrows()
                    let when = DispatchTime.now() + (self.game.moveDelay * 0.0)
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.game.mediaManager.playSound(soundType: .pick_goody)
                        if(!self.opponent){
                            self.game.setScore(score: self.score)
                        }
                        self.game.goodyNode.posGoody()
                        self.game.showDbgMsg(dbgMsg: DbgMsgs.goodyHit)
                    }
                }
                var nextField:SuakeFields = checkNextField()
                
                if(nextField.contains(SuakeFields.opp_suake)){
                    game.gameOver(didYouDie: !opponent)
                    return
                }
                if(nextField.contains(SuakeFields.goody)){
                    self.game.goodyNode.newGoodyPos()
                    self.game.goodyNode.posGoody()
                    let when = DispatchTime.now() + (self.game.moveDelay * 0.0)
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.game.mediaManager.playSound(soundType: .pick_goody)
                        self.game.showDbgMsg(dbgMsg: DbgMsgs.goodyHit)
                        self.score += 9
                        if(!self.opponent){
                            self.game.setScore(score: self.score)
                        }
                    }
                    if(!opponent){
                        self.game.arrows.showHideHelperArrows()
                    }
                }else if(nextField.contains(SuakeFields.wall)){
                    game.gameOver(didYouDie: !opponent)
                    return
                }
            }
            arrSuakeNodes[i].oldPosition = arrSuakeNodes[i].presentation.position
            arrSuakeNodes[i].oldPos = arrSuakeNodes[i].pos
        }
    }
    
    func moveAndCheck4GoodyAtNextPos(suakeHeadNode:SuakeNode)->Bool{
        var isGoodyAhead:Bool = false
        if(suakeHeadNode.dir == .DOWN){
            if(game.goodyNode.pos.x == suakeHeadNode.pos.x && game.goodyNode.pos.z == suakeHeadNode.pos.z){
                isGoodyAhead = true
            }
        }else if(suakeHeadNode.dir == .UP){
            if(game.goodyNode.pos.x == suakeHeadNode.pos.x && game.goodyNode.pos.z == suakeHeadNode.pos.z){
                isGoodyAhead = true
            }
        }else if(suakeHeadNode.dir == .LEFT){
            if(game.goodyNode.pos.z == suakeHeadNode.pos.z && game.goodyNode.pos.x == suakeHeadNode.pos.x + 1){
                isGoodyAhead = true
            }
        }else if(suakeHeadNode.dir == .RIGHT){
            if(game.goodyNode.pos.z == suakeHeadNode.pos.z && game.goodyNode.pos.x == suakeHeadNode.pos.x - 1){
                isGoodyAhead = true
            }
        }
        //game.showHideHelperArrows()
        return isGoodyAhead
    }
    
    func moveAndCheck4GoodyAtNextPosNG(suakeHeadNode:SuakeNode)->Bool{
        var isGoodyAhead:Bool = false
        if(suakeHeadNode.dir == .DOWN){
            if(game.goodyNode.pos.x == suakeHeadNode.pos.x && game.goodyNode.pos.z == suakeHeadNode.pos.z - 1){
                isGoodyAhead = true
            }
        }else if(suakeHeadNode.dir == .UP){
            if(game.goodyNode.pos.x == suakeHeadNode.pos.x && game.goodyNode.pos.z == suakeHeadNode.pos.z + 1){
                isGoodyAhead = true
            }
        }else if(suakeHeadNode.dir == .LEFT){
            if(game.goodyNode.pos.z == suakeHeadNode.pos.z && game.goodyNode.pos.x == suakeHeadNode.pos.x + 1){
                isGoodyAhead = true
            }
        }else if(suakeHeadNode.dir == .RIGHT){
            if(game.goodyNode.pos.z == suakeHeadNode.pos.z && game.goodyNode.pos.x == suakeHeadNode.pos.x - 1){
                isGoodyAhead = true
            }
        }
        //game.showHideHelperArrows()
        return isGoodyAhead
    }
}
