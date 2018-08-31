/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This class manages most of the game logic.
*/

//import simd
import SceneKit
import SpriteKit
//import QuartzCore
import AVFoundation
import GameController
import SceneKit.ModelIO

// Collision bit masks
let BitmaskCollision        = Int(1 << 2)
let BitmaskCollectable      = Int(1 << 3)
let BitmaskEnemy            = Int(1 << 4)
let BitmaskSuperCollectable = Int(1 << 5)
let BitmaskWater            = Int(1 << 6)

#if os(iOS) || os(tvOS)
    typealias ViewController = UIViewController
#elseif os(OSX)
    typealias ViewController = NSViewController
#endif

/*extension SKView {
    override open func resetCursorRects() {
        if let image = NSImage.init(named: "ch_1a.png") {
            let spot = NSPoint(x: 0, y: 0)
            let customCursor = NSCursor(image: image, hotSpot: spot)
            addCursorRect(visibleRect, cursor:customCursor)
        }
    }
}*/

class GameViewController: ViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate, MoveCrosshairDelegate {
   
    // Game view
    var gameView: GameView {
        return view as! GameView
    }
    
    
    var menuShowing:Bool = false
    var menuSetupShowing:Bool = false
    var menuCreditsShowing:Bool = false
    var menuPos:Int = 0
    var cheatSheetShowing:Bool = false
    
    var mapOverlay:MapOverlay!
    var mapShapeNode:SKShapeNode!
    
    public var scene:SCNScene!
    
    var cameraNodeWormHole:SCNNode!
    var starsParticeSystem:SCNParticleSystem!
    
    var sk:SKScene!
    var skMenu:SKScene!
    var skSetup:SKScene!
    var skCheatSheet:SKScene!
    var skCredits:CreditsSkScene!
    
    var mo:MapOverlay!
    var suake:Suake!
    var suakeOpp:Suake!
    var cameraNode:SCNNode!
    var cameraNodeFP:SCNNode!
    
    var floorNode:SCNNode!
    var fireNode:FireNode!
    
    let camY:CGFloat = 45
    let camZ:CGFloat = -190
    
    var lightNode:SCNNode!
    var lightPos:SCNVector3 = SCNVector3(x: 0, y: 15, z: 10)
    
    var goodyLightNode:SCNNode!
    var goodyLightPos:SCNVector3 = SCNVector3(x: 0, y: 15, z: 30)
    
    var ambientLightNode:SCNNode!
    
    var camPosOrig:SCNVector3 = SCNVector3(x:0, y: 45, z: -190)
    var camPos:SCNVector3 = SCNVector3(x:0, y: 45, z: -190)
    
    
    //var portal1:PortalGroup!
    var allPortalGroups:[PortalGroup] = [PortalGroup]()
    // Left border
    //var portal2:PortalGroup!
    // Right border
    //var portal3:PortalGroup!
    
    #if os(OSX)
    internal var lastMousePosition = float2(0)
    #elseif os(iOS)
    internal var padTouch: UITouch?
    internal var panningTouch: UITouch?
    #endif
    
    public var goodyNode:GoodyNode!
    let gameWindowSize:CGSize = CGSize(width: 1300, height: 780)
    let moveDelay:CFTimeInterval = 1.0
    var kiOn:Bool = false
    var kiDied:Bool = true
    var mediaManager:MediaManager!
    
    //public var score:Int = 0
    
    public var ch:Crosshair = Crosshair()
    public var arrows:Arrows = Arrows()
    //public var rocketlauncher:Rocketlauncher!
    //public var shotgun:Shotgun!
    public var machinegunWP:MachinegunPickup!
    public var shotgunWP:ShotgunPickup!
    public var rocketlauncherWP:RocketlauncherPickup!
    public var railgunWP:RailgunPickup!
    
    
    var lblGameOver:SKLabelNode!
    var lblWinOrLoose:SKLabelNode!
    var lblHealth:SKLabelNode!
    var lblPause:SKLabelNode!
    var lbl:SKLabelNode!
    var lblAmmoCount:SKLabelNode!
    var lblDbg:SKLabelNode!
    var lblLog:SKLabelNode!
    var img:SKSpriteNode!
    var imgRG:SKSpriteNode!
    var imgBlood:SKSpriteNode!
    var imgBloodDie:SKSpriteNode!
    var imgRockets:SKSpriteNode!
    var imgShells:SKSpriteNode!
    var imgRailgun:SKSpriteNode!
    var imgMachinegun:SKSpriteNode!
    var imgBlackout:SKSpriteNode!
    
    
    var lblInd:SKLabelNode!
    var lblSinglePlayer:SKLabelNode!
    var lblSinglePlayerBG:SKLabelNode!
    var lblMultiPlayer:SKLabelNode!
    var lblMultiPlayerBG:SKLabelNode!
    var lblSettings:SKLabelNode!
    var lblSettingsBG:SKLabelNode!
    var lblCredits:SKLabelNode!
    var lblCreditsBG:SKLabelNode!
    var lblExit:SKLabelNode!
    var lblExitBG:SKLabelNode!
    
    var lblSetupControls:SKLabelNode!
    var lblSetupControlsBG:SKLabelNode!
    var lblSetupDisplay:SKLabelNode!
    var lblSetupDisplayBG:SKLabelNode!
    var lblSetupMisc:SKLabelNode!
    var lblSetupMiscBG:SKLabelNode!
    
    var lblStartCounter:SKLabelNode!
    
    public let wallBottom:CGFloat = 8.0
    public let wallFields:CGFloat = 76.0
    public let margin:CGFloat = 5.0
    
    // Game states
    private var gameIsComplete = false
    private var lockCamera = false
    public var fpv:Bool = false
    
    // Game controls
    internal var controllerDPad: GCControllerDirectionPad?
    internal var controllerStoredDirection = float2(0.0) // left/right up/down
    var sizeOfScnView:CGSize!
    
    // MARK: Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        mediaManager = MediaManager(_game: self)
    }
    
    /*public func yourMethod(notification: NSNotification?) {
        //skCredits.setupScrollView()
        //skCredits.onScroll
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NotificationCenter.default.addObserver(self, selector: "yourMethod:", name: NSNotification.Name.NSApplicationDidFinishLaunching, object: nil)
        
        let sizeScnView = CGSize(width: gameWindowSize.width, height: gameWindowSize.height)
        sizeOfScnView = sizeScnView
        let centerView = CGPoint(x: self.view.frame.midX - sizeScnView.width/2, y: self.view.frame.midY - sizeScnView.height/2)
        gameView.chMove = self
        gameView.frame = CGRect(origin: centerView, size: sizeScnView)
        gameView.frame.size = CGSize(width: gameWindowSize.width, height: gameWindowSize.height)
        
        /*if let screen = NSScreen.main() {
            window.setFrame(screen.visibleFrame, display: true, animate: true)
        }*/
        
        scene = SCNScene(named: "game.scnassets/_gamescene.scn")!
        
        //sceneWormHole = SCNScene()
        cameraNodeWormHole = SCNNode()
        cameraNodeWormHole.name = "CamWormHole"
        var mdl:MDLCamera = MDLCamera() //scnNode: cameraNodeWormHole)
        mdl.barrelDistortion = 0.5
        mdl.fisheyeDistortion = 0.2
        cameraNodeWormHole.camera = SCNCamera(mdlCamera: mdl)
        //cameraNodeWormHole.camera?.xFov = 55
        //cameraNodeWormHole.camera?.yFov = 55
        cameraNodeWormHole.position = SCNVector3Make(0, 0, 14)
        scene.rootNode.addChildNode(cameraNodeWormHole)
        //sceneWormHole.rootNode.addChildNode(cameraNodeWormHole)
        starsParticeSystem = SCNParticleSystem(named: "Stars", inDirectory: nil)!
        //sceneWormHole.rootNode.addParticleSystem(starsParticeSystem)
        //scene.rootNode.addParticleSystem(starsParticeSystem)
        //gameView.backgroundColor = NSColor.black
        
        // *** Add CONTACT DELEGATE for FLOOR ***
        floorNode = scene.rootNode.childNode(withName: "floor", recursively: true)!
        let floorNodeShape = SCNPhysicsShape(geometry: (floorNode.geometry)!, options: nil)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: floorNodeShape)
        floorNode.physicsBody?.isAffectedByGravity = false
        floorNode.physicsBody?.categoryBitMask = CollisionCategory.FloorCategory
        floorNode.physicsBody?.contactTestBitMask = CollisionCategory.FloorCategory|CollisionCategory.RocketCategory
        floorNode.geometry?.boundingBox.max.x = 120
        floorNode.geometry?.boundingBox.min.x = -120
        scene.physicsWorld.contactDelegate = self
        //scene.physicsWorld.timeStep = 1/300
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        cameraNode.camera?.zFar = 4600.0
        //cameraNode.removeFromParentNode()
        
        cameraNodeFP = SCNNode()
        cameraNodeFP.camera = SCNCamera()
        cameraNodeFP.camera?.name = "FPCamera"
        cameraNodeFP.camera?.zFar = 1200.0
        scene.rootNode.addChildNode(cameraNodeFP!)
        
        cameraNewHandle.camera = SCNCamera()
        cameraNewHandle.camera?.name = "NewCamera"
        cameraNewHandle.camera?.zFar = 1200.0
        scene.rootNode.addChildNode(cameraNewHandle)
        
        // create and add a light to the scene
        lightNode = SCNNode()
        var light:SCNLight = SCNLight()
        light.type = .omni
        light.intensity = 2000
        light.color = NSColor.red
        light.shadowRadius = 3
        lightNode.light = light
        //scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.intensity = 2000
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        goodyLightNode = SCNNode()
        var light2:SCNLight = SCNLight()
        light2.type = .omni
        light2.intensity = 1000
        light2.color = NSColor.green
        light2.shadowRadius = 3
        goodyLightNode.light = light2
        
        //scene.rootNode.addChildNode(goodyLightNode
        self.gameView.scene = scene
        
        let wallFact:WallFactory = WallFactory(game: self)
        if(DbgVars.showWalls){
            wallFact.createWall()
        }
        
        initHUD()
        
        restartGame()
        
        fireNode = FireNode(game: self, show: DbgVars.showFire)
        scene.rootNode.addChildNode(fireNode)
        
        /*var wtrFall:Waterfall = Waterfall(_gameBoard: self)
        wtrFall.name = "WaterFall"
        //wtrFall.rotation.w = CGFloat.pi
        //wtrFall.rotation.y = 1.0
        wtrFall.rotation = SCNVector4Make(0, 1, 0, CGFloat.pi)
        //wtrFall.transform = SCNMatrix4MakeRotation(CGFloat(Double.pi) * 1.0, 0.0, 1, 0.0)
        wtrFall.placeOnBoard(pos: SCNVector3(x: 2, y: 0.6, z: 8))*/
        
        self.gameView.allowsCameraControl = true //false
        self.gameView.showsStatistics = true
        self.gameView.pointOfView = cameraNode // cameraNewHandle
        self.gameView.isPlaying = true
        self.gameView.loops = true
        
        // Various setup
        //setupCamera()
        /*setupSounds()
        
        // Configure particle systems
        collectFlowerParticleSystem = SCNParticleSystem(named: "collect.scnp", inDirectory: nil)
        collectFlowerParticleSystem.loops = false
        confettiParticleSystem = SCNParticleSystem(named: "confetti.scnp", inDirectory: nil)
        
        // Add the character to the scene.
        scene.rootNode.addChildNode(character.node)
        
        let startPosition = scene.rootNode.childNode(withName: "startingPoint", recursively: true)!
        character.node.transform = startPosition.transform
        
        // Retrieve various game elements in one traversal
        var collisionNodes = [SCNNode]()
        scene.rootNode.enumerateChildNodes { (node, _) in
            switch node.name {
            case .some("flame"):
                node.physicsBody!.categoryBitMask = BitmaskEnemy
                self.flames.append(node)
                
            case .some("enemy"):
                self.enemies.append(node)
                
            case let .some(s) where s.range(of: "collision") != nil:
                collisionNodes.append(node)
                
            default:
                break
            }
        }
        
        for node in collisionNodes {
            node.isHidden = false
            setupCollisionNode(node)
        }*/
        
        // Setup delegates
        scene.physicsWorld.contactDelegate = self
        gameView.debugOptions.insert(.showPhysicsShapes)
        gameView.debugOptions.insert(.showBoundingBoxes)
        gameView.debugOptions.insert(.showConstraints)
        gameView.delegate = self
        
        //setupAutomaticCameraPositions()
        setupGameControllers()
        self.gameView.showsStatistics = true
        
        skCredits = CreditsSkScene(game: self)
        if(DbgVars.autoStart){
            StartCountAnim.showStartCountAnim(game: self){
                self.startGame()
            }
        }
    }
    
    func gameOver(){
        gameOver(didYouDie: !kiDied)
    }
    
    func gameOver(didYouDie:Bool){
        suake.stopAnim()
        suakeOpp.stopAnim()
        CameraHelper.showDieAnim(game: self, didYouDie: didYouDie)
        if(didYouDie){
            showDbgMsg(dbgMsg: DbgMsgs.youDied)
        }else{
            showDbgMsg(dbgMsg: DbgMsgs.oppDied)
        }
        showDbgMsg(dbgMsg: DbgMsgs.gameOver)
    }
    
    func enterWH(outPortal:Portal){
        toggleWH(outPortal:outPortal)
        mediaManager.playSound(soundType: .telein)
    }
    
    var whShowing:Bool = false
    func toggleWH(outPortal:Portal){
        whShowing = !whShowing
        if(!whShowing){
            suake.canceled = true
            //suake.togglePause()
            //setIsPlaying(false)
            suake.suakeHead.isPaused = true
            suake.suakeTail.isPaused = true
            suake.suakeHead.stopAnim()
            suake.suakeTail.stopAnim()
            suake.stopAnim()
        }
        floorNode.isHidden = whShowing
        fireNode.isHidden = whShowing || !DbgVars.showFire
        goodyNode.isHidden = whShowing
        goodyLightNode.isHidden = whShowing
        ambientLightNode.isHidden = whShowing
        
        //rocketlauncher.isHidden = whShowing
        for i in (0..<allPortalGroups.count){
            allPortalGroups[i].isHidden = whShowing
        }
        suake.isHidden = whShowing
        suakeOpp.isHidden = whShowing
        if(whShowing){
            scene.background.contents = NSColor.black
            scene.rootNode.addParticleSystem(starsParticeSystem)
            gameView.backgroundColor = NSColor.black
            gameView.pointOfView = cameraNodeWormHole
            let when = DispatchTime.now() + (moveDelay * 0.9)
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.suake.suakeHead.beamed = true
                self.toggleWH(outPortal:outPortal)
                self.cameraNode.position.x += self.suake.offset
                self.lightNode.position.x += self.suake.offset
                self.suake.beamNode(suakeNodeToBeam: self.suake.suakeTail, outPortal:outPortal)
            }
        }else{
            scene.background.contents = NSImage.init(named: "1513278-galaxy-wallpaper.jpg")
            gameView.pointOfView = cameraNode
            scene.rootNode.removeParticleSystem(starsParticeSystem)
        }
    }
    
    func setIsPlaying(_ isPlaying:Bool){
        gameView.isPlaying = isPlaying //!game.gameView.isPlaying
        if(gameView.isPlaying){
            showDbgMsg(dbgMsg: DbgMsgs.gameIsPlaying)
        }else{
            showDbgMsg(dbgMsg: DbgMsgs.gameIsNotPlaying)
        }
    }
    
    func toggleIsPlaying(){
        setIsPlaying(!gameView.isPlaying)
    }
    /*if(menuPos == 0){
     lblMultiPlayerBG.fontColor = NSColor.black
     lblSinglePlayerBG.fontColor = NSColor.yellow
     }else if(menuPos == 1){
     lblSettingsBG.fontColor = NSColor.black
     lblMultiPlayerBG.fontColor = NSColor.yellow
     }else if(menuPos == 2){
     lblCreditsBG.fontColor = NSColor.black
     lblSettingsBG.fontColor = NSColor.yellow
     }else if(menuPos == 3){
     lblExitBG.fontColor = NSColor.black
     lblCreditsBG.fontColor = NSColor.yellow
     }*/
    override func mouseMoved(with event: NSEvent){
        if(menuSetupShowing){
            let location = event.location(in: skSetup)
            let node = skSetup.atPoint(location)
            if(node == lblSetupControls){
                lblSetupControlsBG.isHidden = false
            }else{
                lblSetupControlsBG.isHidden = true
            }
            if(node == lblSetupDisplay){
                lblSetupDisplayBG.isHidden = false
            }else{
                lblSetupDisplayBG.isHidden = true
            }
            if(node == lblSetupMisc){
                lblSetupMiscBG.isHidden = false
            }else{
                lblSetupMiscBG.isHidden = true
            }
        }else if(menuShowing){
            let location = event.location(in: skMenu)
            let node = skMenu.atPoint(location)
            if(node == lblSinglePlayer){
                lblSinglePlayerBG.isHidden = false
            }else{
                lblSinglePlayerBG.isHidden = true
            }
            if(node == lblMultiPlayer){
                lblMultiPlayerBG.isHidden = false
            }else{
                lblMultiPlayerBG.isHidden = true
            }
            if(node == lblCredits){
                lblCreditsBG.isHidden = false
            }else{
                lblCreditsBG.isHidden = true
            }
            if(node == lblSettings){
                lblSettingsBG.isHidden = false
            }else{
                lblSettingsBG.isHidden = true
            }
            if(node == lblExit){
                lblExitBG.isHidden = false
            }else{
                lblExitBG.isHidden = true
            }
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        if(!ch.imgCrosshair.isHidden){
            //NSCursor.hide()
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        //if(!ch.imgCrosshair.isHidden){
            NSCursor.unhide()
        //}
    }
    
    func drawMapOverlay(){
        if(DbgVars.showMap){
            if(mapShapeNode != nil){
                mapShapeNode.removeFromParent()
            }
            mapShapeNode = mapOverlay.getMap()
            sk.addChild(mapShapeNode)
        }
    }
    
    func initHUD(){
        sk = SKScene(fileNamed: "game.scnassets/overlays/HUD")!
        skMenu = SKScene(fileNamed: "game.scnassets/overlays/Menu")!
        skSetup = SetupSkScene(game: self) // SKScene(fileNamed: "game.scnassets/overlays/Setup")!
        skCheatSheet = SKScene(fileNamed: "game.scnassets/overlays/CheatSheet")!
        //skCredits = CreditsSkScene(game: self) //SKScene(fileNamed: "game.scnassets/overlays/Credits")!
        
        mapOverlay = MapOverlay(gameBoard: self)
        
        arrows = Arrows(_game: self)
        
        
        
        imgBlood = (sk.childNode(withName: "imgBlood") as! SKSpriteNode)
        //imgBlood.texture = SKTexture(imageNamed: "art.scnassets/railgunimg.png")//rocketlauncher_ico.png")
        //imgBlood.size = CGSize(width: 150, height: 56)
        imgBlood.alpha = 0
        imgBlood.size = sizeOfScnView
        
        imgBloodDie = (sk.childNode(withName: "imgBloodDie") as! SKSpriteNode)
        imgBloodDie.alpha = 0
        imgBloodDie.size = sizeOfScnView
        
        imgBlackout = (sk.childNode(withName: "imgBlackout") as! SKSpriteNode)
        imgBlackout.alpha = 0
        imgBlackout.size = sizeOfScnView
        /*
        img = (sk.childNode(withName: "imgRockets") as! SKSpriteNode)
        img.texture = SKTexture(imageNamed: "art.scnassets/railgunimg.png")//rocketlauncher_ico.png")
        img.size = CGSize(width: 150, height: 56)
        img.alpha = 0
        
        /*imgRG = (sk.childNode(withName: "imgRockets") as! SKSpriteNode)
         imgRG.texture = SKTexture(imageNamed: "art.scnassets/rocketlauncher_ico.png")
         imgRG.alpha = 0*/
        */
        ch = Crosshair(_game: self)
        ch.hideCh(newVal: !DbgVars.showCh)
        
        lbl = sk.childNode(withName: "lblScore") as! SKLabelNode
        lbl.position = CGPoint(x: (gameWindowSize.width / 2) - (lbl.frame.width / 2) - 10, y: (gameWindowSize.height / 2) - 40) // UPPER RIGHT
        
        lblHealth = sk.childNode(withName: "lblHealth") as! SKLabelNode
        lblHealth.position = CGPoint(x: (gameWindowSize.width / -2) + 10 /*(lblHealth.frame.width / 2) + 10*/, y: (gameWindowSize.height / 2) - 40) // UPPER RIGHT
        
        lblAmmoCount = sk.childNode(withName: "lblRockets") as! SKLabelNode
        lblAmmoCount.isHidden = true
        
        imgRockets = (sk.childNode(withName: "imgRockets") as! SKSpriteNode)
        imgRockets.alpha = 0
        
        imgShells = (sk.childNode(withName: "imgShells") as! SKSpriteNode)
        imgShells.alpha = 0
        
        imgRailgun = (sk.childNode(withName: "imgRailgun") as! SKSpriteNode)
        imgRailgun.alpha = 0
        
        imgMachinegun = (sk.childNode(withName: "imgMachinegun") as! SKSpriteNode)
        imgMachinegun.alpha = 0
        
        lblDbg = sk.childNode(withName: "lblDebug") as! SKLabelNode
        lblDbg.position = CGPoint(x: (gameWindowSize.width / -2) + 10, y: (gameWindowSize.height / 2) - 70) // UPPER LEFT
        
        lblLog = sk.childNode(withName: "lblLog") as! SKLabelNode
        lblLog.position = CGPoint(x: (gameWindowSize.width / -2) + 10, y: (gameWindowSize.height / 2) - 85) // UPPER LEFT
        
        lblGameOver = sk.childNode(withName: "lblGameOver") as! SKLabelNode
        lblWinOrLoose = sk.childNode(withName: "lblWinOrLoose") as! SKLabelNode
        lblPause = sk.childNode(withName: "lblPause") as! SKLabelNode
        
        lblAmmoCount.isHidden = true
        lblGameOver.isHidden = true
        lblWinOrLoose.isHidden = true
        lblPause.isHidden = true
        
        lblInd = skMenu.childNode(withName: "lblIndicator") as! SKLabelNode
        
        lblSinglePlayer = skMenu.childNode(withName: "lblSinglePlayer") as! SKLabelNode
        lblSinglePlayerBG = skMenu.childNode(withName: "lblSinglePlayerBG") as! SKLabelNode
        lblSinglePlayerBG.isHidden = false
        //lblSinglePlayerBG.fontColor = NSColor.yellow
        
        lblMultiPlayer = skMenu.childNode(withName: "lblMultiPlayer") as! SKLabelNode
        lblMultiPlayerBG = skMenu.childNode(withName: "lblMultiPlayerBG") as! SKLabelNode
        lblMultiPlayerBG.isHidden = true
        
        lblSettings = skMenu.childNode(withName: "lblSetup") as! SKLabelNode
        lblSettingsBG = skMenu.childNode(withName: "lblSetupBG") as! SKLabelNode
        lblSettingsBG.isHidden = true
        
        lblCredits = skMenu.childNode(withName: "lblCredits") as! SKLabelNode
        lblCreditsBG = skMenu.childNode(withName: "lblCreditsBG") as! SKLabelNode
        lblCreditsBG.isHidden = true
        
        lblExit = skMenu.childNode(withName: "lblExit") as! SKLabelNode
        lblExitBG = skMenu.childNode(withName: "lblExitBG") as! SKLabelNode
        lblExitBG.isHidden = true
        
        lblSetupControls = skSetup.childNode(withName: "lblSetupControls") as! SKLabelNode
        lblSetupControlsBG = skSetup.childNode(withName: "lblSetupControlsBG") as! SKLabelNode
        lblSetupControlsBG.isHidden = true
        
        lblSetupDisplay = skSetup.childNode(withName: "lblSetupDisplay") as! SKLabelNode
        lblSetupDisplayBG = skSetup.childNode(withName: "lblSetupDisplayBG") as! SKLabelNode
        lblSetupDisplayBG.isHidden = true
        
        lblSetupMisc = skSetup.childNode(withName: "lblSetupMisc") as! SKLabelNode
        lblSetupMiscBG = skSetup.childNode(withName: "lblSetupMiscBG") as! SKLabelNode
        lblSetupMiscBG.isHidden = true
        
        lblStartCounter = sk.childNode(withName: "lblStartCounter") as! SKLabelNode
        
        gameView.overlaySKScene = sk
        gameView.overlaySKScene?.isPaused = false
    }
    
    // DBG Show and fade out
    var newDbgMsg = ""
    var oldCanceled = false
    //let showTime:TimeInterval = 0.3
    let lblAlpha:String = "alpha"
    let fadeOutTime:TimeInterval = 0.7
    
    var logLines:Int = 0
    var maxLogLines:Int = 43
    func showDbgMsg(dbgMsg:String){
        newDbgMsg = dbgMsg
        lblDbg.text = newDbgMsg
        
        if(showAllDebug){
            lblDbg.isHidden = false
            lblDbg.removeAction(forKey: lblAlpha)
            lblDbg.alpha = 1.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + DbgVars.msgShowTime, execute: {
                let fadeAway = SKAction.fadeAlpha(to: 0, duration: self.fadeOutTime)
                self.lblDbg.run(fadeAway, withKey: self.lblAlpha)
            })
        }
        var txtLog:String = lblLog.text!
        if(logLines > maxLogLines){
            txtLog = txtLog.substring(from: (txtLog.index(after: (txtLog.index(of: "\n"))!)))
        }
        
        lblLog.text = txtLog + logLines.description + ": " + newDbgMsg + "\n"
        logLines += 1
    }
    
    func keyPressed(with event: NSEvent){
        var daKeyCode:UInt16
        var flags:NSEvent.ModifierFlags = NSEvent.ModifierFlags()
        daKeyCode = event.keyCode
        flags = event.modifierFlags
        print("keyPressed: %d", daKeyCode)
    }
    
    // MARK: Managing the Camera
    func panCamera(_ direction: float2) {
        if lockCamera || gameView.pointOfView != cameraNodeFP {
            return
        }
        showDbgMsg(dbgMsg: DbgMsgs.xDelta + gameView.xDelta.description)
        //showDbgMsg(dbgMsg: DbgMsgs.cameraPan + " => x: " + direction.x.description + " / y: " + direction.y.description)
        
        var directionToPan = direction
        
        #if os(iOS) || os(tvOS)
            directionToPan *= float2(1.0, -1.0)
        #endif
        
        let F = SCNFloat(0.005)
        let xPercent:Float = Float(gameView.xDelta * 0.005) / (Float.pi / -2)
        let yPercent:Float = Float(gameView.yDelta * 0.005) / (Float.pi / -2)
        let zPercent:Float = 1.0 - xPercent
        gameView.xPercent = xPercent
        gameView.yPercent = yPercent
        gameView.zPercent = zPercent
        showDbgMsg(dbgMsg: DbgMsgs.xDelta + "alt: "  + (gameView.xDelta * 0.005).description)
        showDbgMsg(dbgMsg: "Percent: x: "  + xPercent.description + " / z: " + zPercent.description + " / y: " + yPercent.description)
        // Make sure the camera handles are correctly reset (because automatic camera animations may have put the "rotation" in a weird state.
        SCNTransaction.animateWithDuration(0.0) {
            self.cameraYHandle.removeAllActions()
            self.cameraXHandle.removeAllActions()
        }
        self.cameraNewHandle.runAction(SCNAction.rotateBy(x: SCNFloat(directionToPan.y) * -F, y: SCNFloat(directionToPan.x) * -F, z: 0, duration: 0.0))
        self.cameraNodeFP.runAction(SCNAction.rotateBy(x: SCNFloat(directionToPan.y) * F, y: SCNFloat(directionToPan.x) * -F, z: 0, duration: 0.0))
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
    
    func setScore(score:Int){
        suake.score = score
        //self.score = score
        self.lbl.text = "Score: " + String(suake.score)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.lbl.position = CGPoint(x: (self.gameWindowSize.width / 2) - (self.lbl.frame.width / 2) - 30, y: (self.gameWindowSize.height / 2) - 40) // UPPER RIGHT
        })
    }
    
    func restartGame() {
        
        if(suake != nil){
            gameStarted = false
            suake.canceled = false
            suakeOpp.canceled = false
            lookDir = SuakeDir.UP
            
            suake.playAnim(anim: 0, play: false)
            suakeOpp.playAnim(anim: 0, play: false)
            lblGameOver.isHidden = true
            lblWinOrLoose.isHidden = true
            
            suake.removeFromParentNode()
            suakeOpp.removeFromParentNode()
            
            lightNode.removeFromParentNode()
            cameraNode.removeFromParentNode()
            
            for i in (0..<allPortalGroups.count).reversed(){
                allPortalGroups[i].removeFromParentNode()
                allPortalGroups.remove(at: i)
            }
        }
        
        kiDied = true
        suake = Suake(_gameBoard: self)
        lblPause.isHidden = !suake.canceled
        lblGameOver.isHidden = true
        lblWinOrLoose.isHidden = true
        lblGameOver.alpha = 0
        lblWinOrLoose.alpha = 0
        imgBlackout.alpha = 0
        setScore(score: 0)
        suake.setHealth(health: 100)
        
        suakeOpp = Suake(_gameBoard: self, opponent: true)
        
        gameView.scene?.rootNode.addChildNode(lightNode)
        gameView.scene?.rootNode.addChildNode(cameraNode)
        
        ch.imgCrosshair.position.y = -10
        
        let lookConst:SCNLookAtConstraint = SCNLookAtConstraint(target: suake.suakeHead)
        lookConst.isGimbalLockEnabled = true
        cameraNode.transform = SCNMatrix4MakeRotation(CGFloat(Double.pi) * 0, 0.0, -1.0, 0.0)
        cameraNode.position = SCNVector3(x:0, y: 45, z: -190) // camPosOrig
        cameraNode.constraints = [lookConst]
        cameraNode.camera?.wantsDepthOfField = false
        gameView.pointOfView = cameraNode
        //cameraNode.constraints = nil
        lightNode.position = SCNVector3(x: 0, y: 15, z: 10) // lightPos
        lightNode.constraints = [lookConst]
        
        cameraNodeFP.position = suake.suakeHead.presentation.position
        cameraNodeFP.position.z += suake.suakeHead.size.z / 10
        cameraNodeFP.position.y += 8
        cameraNodeFP.eulerAngles.y += CGFloat(Double.pi)
        
        if(goodyNode != nil){
            goodyNode.removeFromParentNode()
        }
        goodyNode = GoodyNode(_gameBoard: self)
        goodyNode.placeOnBoard(pos: DbgVars.goodyPos) // SCNVector3(x: 1, y: 0, z: 8))
        let lookConst2:SCNLookAtConstraint = SCNLookAtConstraint(target: goodyNode)
        lookConst2.isGimbalLockEnabled = true
        goodyLightNode.position = goodyLightPos
        goodyLightNode.constraints = [lookConst2]
        goodyNode.posGoody()
        
        if(machinegunWP != nil){
            machinegunWP.removeFromParentNode()
        }
        machinegunWP = MachinegunPickup(_game: self)
        machinegunWP.placeOnBoard(pos: DbgVars.machinegunPickup)
        
        /*if(shotgun != nil){
            shotgun.removeFromParentNode()
        }
        shotgun = Shotgun(_game: self)
        */
        if(shotgunWP != nil){
            shotgunWP.removeFromParentNode()
        }
        shotgunWP = ShotgunPickup(_game: self)
        shotgunWP.placeOnBoard(pos: DbgVars.shotgunPickup)
        
        /*if(rocketlauncher != nil){
            rocketlauncher.removeFromParentNode()
        }
        rocketlauncher = Rocketlauncher(_game: self)
        */
        if(rocketlauncherWP != nil){
            rocketlauncherWP.removeFromParentNode()
        }
        rocketlauncherWP = RocketlauncherPickup(_game: self)
        rocketlauncherWP.placeOnBoard(pos: DbgVars.rocketLauncherPickup)
        
        if(railgunWP != nil){
            railgunWP.removeFromParentNode()
        }
        railgunWP = RailgunPickup(_game: self)
        railgunWP.placeOnBoard(pos: DbgVars.railgunPickup)
        
        suake.selectWeapon(weaponToSelect: CollisionCategory.MachineGunCategory, pickedUp: false, mute: true)
        
        allPortalGroups.append(PortalGroup(game:self, id: 1, inCoord: DbgVars.portGrpIn1, outCoord: DbgVars.portGrpOut1))
        
        allPortalGroups.append(PortalGroup(game:self, id: 2, inCoord: DbgVars.portGrpIn2, outCoord: DbgVars.portGrpOut2))
        
        allPortalGroups.append(PortalGroup(game:self, id: 3, inCoord: DbgVars.portGrpIn3, outCoord: DbgVars.portGrpOut3))
        
        if(DbgVars.showArrows){
            arrows.showArrows = .DIR
            arrows.showHideHelperArrows()
        }
        drawMapOverlay()
        enableDebugView(enabled: showAllDebug)
    }
    
    
    var gameStarted:Bool = false
    var gameStartedNG:Bool = false
    
    var spawnTime:TimeInterval = 1.0
    var showAllDebug:Bool = true
    var showSceneDebug:Bool = true
    
    func toggleDebugView(){
        showAllDebug = !showAllDebug
        enableDebugView(enabled: showAllDebug)
    }
    
    func toggleSceneDebugView(){
        showSceneDebug = !showSceneDebug
        enableSceneDebugView(enabled: showSceneDebug)
    }
    
    func enableDebugView(enabled:Bool){
        showAllDebug = enabled
        lblLog.isHidden = !enabled
        lblDbg.isHidden = !enabled
        
        for i in (0..<allPortalGroups.count){
            allPortalGroups[i].lblIsHidden = !enabled
        }
    }
    
    func enableSceneDebugView(enabled:Bool){
        showSceneDebug = enabled
        if(showSceneDebug){
            gameView.debugOptions.insert(.showPhysicsShapes)
            gameView.debugOptions.insert(.showBoundingBoxes)
            gameView.debugOptions.insert(.showConstraints)
        }else{
            gameView.debugOptions.remove(.showPhysicsShapes)
            gameView.debugOptions.remove(.showBoundingBoxes)
            gameView.debugOptions.remove(.showConstraints)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer,
                           didRenderScene scene: SCNScene,
                           atTime time: TimeInterval){
        if time > spawnTime {
            if(self.gameStarted){
                /*if(!self.gameStartedNG){
                    self.gameStartedNG = true
                    suake.startAnim()
                }else{
                    suake.suakeHead.position.z += suake.moveDist
                    suake.animCameraNLights()
                    //SCNTransaction.begin()
                    //SCNTransaction.animationDuration = 0.0
                    //suake.suakeTail.stopAnim()
                    //suake.suakeTail.position.z += suake.moveDist
                    //suake.suakeTail.playAnim()
                    //suake.suakeMiddle.stopAnim()
                    //suake.suakeMiddle.position.z += suake.moveDist
                    //suake.suakeMiddle.playAnim()
                    //suake.suakeHead.stopAnim()
                    //suake.suakeHead.position.z += suake.moveDist
                    //suake.suakeHead.playAnim()
                    //SCNTransaction.commit()
                }*/
            }
            spawnTime = time + TimeInterval(1.0)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        /*if(suake.keysForRenderLoop.count > 0){
            let nextKeyForRenderLoop:KeyboardDirection = suake.keysForRenderLoop[0]
            if(nextKeyForRenderLoop != KeyboardDirection.KEY_NONE){
                
                if(nextKeyForRenderLoop == KeyboardDirection.KEY_UP ||
                    nextKeyForRenderLoop == KeyboardDirection.KEY_LEFT ||
                    nextKeyForRenderLoop == KeyboardDirection.KEY_DOWN ||
                    nextKeyForRenderLoop == KeyboardDirection.KEY_RIGHT){
                    
                    if(menuShowing){
                        if(nextKeyForRenderLoop == KeyboardDirection.KEY_UP){
                            if(menuPos > 0){
                                lblInd.position.y += 40
                                menuPos -= 1
                                if(menuPos == 0){
                                    lblMultiPlayerBG.fontColor = NSColor.black
                                    lblSinglePlayerBG.fontColor = NSColor.yellow
                                }else if(menuPos == 1){
                                    lblSettingsBG.fontColor = NSColor.black
                                    lblMultiPlayerBG.fontColor = NSColor.yellow
                                }else if(menuPos == 2){
                                    lblCreditsBG.fontColor = NSColor.black
                                    lblSettingsBG.fontColor = NSColor.yellow
                                }else if(menuPos == 3){
                                    lblExitBG.fontColor = NSColor.black
                                    lblCreditsBG.fontColor = NSColor.yellow
                                }
                            }
                        }else if(nextKeyForRenderLoop == KeyboardDirection.KEY_DOWN){
                            if(menuPos < 4){
                                lblInd.position.y -= 40
                                menuPos += 1
                                if(menuPos == 1){
                                    lblSinglePlayerBG.fontColor = NSColor.black
                                    lblMultiPlayerBG.fontColor = NSColor.yellow
                                }else if(menuPos == 2){
                                    lblMultiPlayerBG.fontColor = NSColor.black
                                    lblSettingsBG.fontColor = NSColor.yellow
                                }else if(menuPos == 3){
                                    lblSettingsBG.fontColor = NSColor.black
                                    lblCreditsBG.fontColor = NSColor.yellow
                                }else if(menuPos == 4){
                                    lblCreditsBG.fontColor = NSColor.black
                                    lblExitBG.fontColor = NSColor.yellow
                                }
                            }
                        }
                    }else{
                        suake.startWithExtrude = false
                        suake.expanded = false
                        
                        var suakeDir:SuakeDir = suake.key2SuakeDirNG(keyCode: nextKeyForRenderLoop)
                        
                        suakeDir = adjustDir(dir: suakeDir)
                        
                        if(!gameStarted){
                            startGame()
                            /*gameStarted = true
                             suake.startAnim()
                             if(DbgVars.vsKI){
                             suakeOpp.startAnim()
                             }
                             if(DbgVars.bgMusicOn && !mediaManager.bgMusic.isPlaying){
                             mediaManager.playBGMusic()
                             }
                             showDbgMsg(dbgMsg: DbgMsgs.gameStarted)*/
                        }else{
                            if(suakeDir == .UP){
                                suake.bendTrigger(newDir: suakeDir)
                                showDbgMsg(dbgMsg: DbgMsgs.keyUp)
                            }else if(suakeDir == .LEFT){
                                suake.bendTrigger(newDir: suakeDir)
                                showDbgMsg(dbgMsg: DbgMsgs.keyLeft)
                            }else if(suakeDir == .DOWN){
                                suake.bendTrigger(newDir: suakeDir)
                                showDbgMsg(dbgMsg: DbgMsgs.keyDown)
                            }else if(suakeDir == .RIGHT){
                                suake.bendTrigger(newDir: suakeDir)
                                showDbgMsg(dbgMsg: DbgMsgs.keyRight)
                            }else{
                                suake.stopAnim()
                                showDbgMsg(dbgMsg: DbgMsgs.gameStopped)
                            }
                        }
                    }
                }
            }
            suake.keysForRenderLoop.remove(at: 0)
        }*/
        if(suake.nextKeyForRenderLoop != KeyboardDirection.KEY_NONE){
            
            if(suake.nextKeyForRenderLoop == KeyboardDirection.KEY_UP ||
                suake.nextKeyForRenderLoop == KeyboardDirection.KEY_LEFT ||
                suake.nextKeyForRenderLoop == KeyboardDirection.KEY_DOWN ||
                suake.nextKeyForRenderLoop == KeyboardDirection.KEY_RIGHT){
                
                if(menuShowing){
                    if(suake.nextKeyForRenderLoop == KeyboardDirection.KEY_UP){
                        if(menuPos > 0){
                            lblInd.position.y += 40
                            menuPos -= 1
                            if(menuPos == 0){
                                lblMultiPlayerBG.fontColor = NSColor.black
                                lblSinglePlayerBG.fontColor = NSColor.yellow
                            }else if(menuPos == 1){
                                lblSettingsBG.fontColor = NSColor.black
                                lblMultiPlayerBG.fontColor = NSColor.yellow
                            }else if(menuPos == 2){
                                lblCreditsBG.fontColor = NSColor.black
                                lblSettingsBG.fontColor = NSColor.yellow
                            }else if(menuPos == 3){
                                lblExitBG.fontColor = NSColor.black
                                lblCreditsBG.fontColor = NSColor.yellow
                            }
                        }
                    }else if(suake.nextKeyForRenderLoop == KeyboardDirection.KEY_DOWN){
                        if(menuPos < 4){
                            lblInd.position.y -= 40
                            menuPos += 1
                            if(menuPos == 1){
                                lblSinglePlayerBG.fontColor = NSColor.black
                                lblMultiPlayerBG.fontColor = NSColor.yellow
                            }else if(menuPos == 2){
                                lblMultiPlayerBG.fontColor = NSColor.black
                                lblSettingsBG.fontColor = NSColor.yellow
                            }else if(menuPos == 3){
                                lblSettingsBG.fontColor = NSColor.black
                                lblCreditsBG.fontColor = NSColor.yellow
                            }else if(menuPos == 4){
                                lblCreditsBG.fontColor = NSColor.black
                                lblExitBG.fontColor = NSColor.yellow
                            }
                        }
                    }
                }else{
                    suake.startWithExtrude = false
                    suake.expanded = false
                    
                    var suakeDir:SuakeDir = suake.key2SuakeDirNG(keyCode: suake.nextKeyForRenderLoop)
                    
                    suakeDir = adjustDir(dir: suakeDir)
                    
                    if(!gameStarted){
                        startGame()
                        /*gameStarted = true
                        suake.startAnim()
                        if(DbgVars.vsKI){
                            suakeOpp.startAnim()
                        }
                        if(DbgVars.bgMusicOn && !mediaManager.bgMusic.isPlaying){
                            mediaManager.playBGMusic()
                        }
                        showDbgMsg(dbgMsg: DbgMsgs.gameStarted)*/
                    }else{
                        if(suakeDir == .UP){
                            suake.bendTrigger(newDir: suakeDir)
                            showDbgMsg(dbgMsg: DbgMsgs.keyUp)
                        }else if(suakeDir == .LEFT){
                            suake.bendTrigger(newDir: suakeDir)
                            showDbgMsg(dbgMsg: DbgMsgs.keyLeft)
                        }else if(suakeDir == .DOWN){
                            suake.bendTrigger(newDir: suakeDir)
                            showDbgMsg(dbgMsg: DbgMsgs.keyDown)
                        }else if(suakeDir == .RIGHT){
                            suake.bendTrigger(newDir: suakeDir)
                            showDbgMsg(dbgMsg: DbgMsgs.keyRight)
                        }else{
                            suake.stopAnim()
                            showDbgMsg(dbgMsg: DbgMsgs.gameStopped)
                        }
                    }
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_C){ // C: Allow CAMERA CONTROL toggle
                gameView.allowsCameraControl = !gameView.allowsCameraControl
                if(!gameView.allowsCameraControl){
                    gameView.pointOfView = cameraNewHandle //cameraNode
                    showDbgMsg(dbgMsg: DbgMsgs.camOff)
                }else{
                    showDbgMsg(dbgMsg: DbgMsgs.camOn)
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_R){ // R: RESTART Game
                showDbgMsg(dbgMsg: DbgMsgs.gameRestarted)
                restartGame()
            }else if(suake.nextKeyForRenderLoop == .KEY_T){ // T: TEST TURN left
                showDbgMsg(dbgMsg: DbgMsgs.turnTest)
                //suake.turnTest(bendLeft: true)
            }else if(suake.nextKeyForRenderLoop == .KEY_B){ // B: TEST TURN left PLAY ANIM
                showDbgMsg(dbgMsg: DbgMsgs.turnTest)
            }else if(suake.nextKeyForRenderLoop == .KEY_E){ // E: Suake EXPAND / EXTRUDE
                showDbgMsg(dbgMsg: DbgMsgs.expandTest)
                suake.expand()
            }else if(suake.nextKeyForRenderLoop == .KEY_W){ // W: Toggle CROSSHAIR / SHOW First Person WEAPON
                if(suake.nextKeyModifierFlags.contains(.shift)){
                    /*rocketlauncher.gNodeFP.isHidden = !rocketlauncher.gNodeFP.isHidden
                    if(rocketlauncher.gNodeFP.isHidden){
                        showDbgMsg(dbgMsg: DbgMsgs.showWeaponOff)
                    }else{
                        showDbgMsg(dbgMsg: DbgMsgs.showWeaponOn)
                    }*/
                }else{
                    ch.toggleCh()
                    if(ch.imgCrosshair.isHidden){
                        showDbgMsg(dbgMsg: DbgMsgs.chOff)
                    }else{
                        showDbgMsg(dbgMsg: DbgMsgs.chOn)
                    }
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_A){ // A: Toggle ARROWS visibility
                let showArrows:Arrows.ArrowsShowState = arrows.areArrowsHiddedToggleNG()
                if(showArrows == .NONE){
                    showDbgMsg(dbgMsg: DbgMsgs.arrowsOff)
                }else if(showArrows == .DIR){
                    showDbgMsg(dbgMsg: DbgMsgs.arrowsDir)
                }else{
                    showDbgMsg(dbgMsg: DbgMsgs.arrowsAll)
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_N){ // N: SHOW NORMAL SuakeNode
                showDbgMsg(dbgMsg: DbgMsgs.normal)
                suake.normal()
            }else if(suake.nextKeyForRenderLoop == .KEY_M){ // M: SHOW MIDDLE SuakeNode
                showDbgMsg(dbgMsg: DbgMsgs.middle)
                suake.middle()
            }else if(suake.nextKeyForRenderLoop == .KEY_P){ // P: Toggle PAUSE
                suake.togglePause()
                suakeOpp.togglePause()
                lblPause.isHidden = !suake.canceled
                if(suake.canceled){
                    showDbgMsg(dbgMsg: DbgMsgs.gamePaused)
                }else{
                    showDbgMsg(dbgMsg: DbgMsgs.gameResumed)
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_L){ // L: Show START COUNTER
                showDbgMsg(dbgMsg: DbgMsgs.gameShowStartCounter)
                StartCountAnim.showStartCountAnim(game: self){
                    self.startGame()
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_X){ // X: Show Cheatsheet
                cheatSheetShowing = !cheatSheetShowing
                if(cheatSheetShowing){
                    showDbgMsg(dbgMsg: DbgMsgs.gameShowKeyHints)
                    gameView.overlaySKScene = skCheatSheet
                }else{
                    showDbgMsg(dbgMsg: DbgMsgs.gameHideKeyHints)
                    gameView.overlaySKScene = sk
                }
                // DbgMsg call in toggle / set func
            }else if(suake.nextKeyForRenderLoop == .KEY_SPACE){ // SPACE: FIRE Weapon
                suake.shoot()
            }else if(suake.nextKeyForRenderLoop == .KEY_ESC){ // ESCAPE: Toggle MENU
                if(menuSetupShowing){
                    menuSetupShowing = false
                    gameView.overlaySKScene = skMenu
                }else if(menuCreditsShowing){
                    menuCreditsShowing = false
                    gameView.overlaySKScene = skMenu
                }else{
                    menuShowing = !menuShowing
                    if(menuShowing){
                        showDbgMsg(dbgMsg: DbgMsgs.gameShowMenu)
                        let when = DispatchTime.now()
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            self.myCursor = NSCursor(image: self.cursorImg, hotSpot: NSPoint(x: self.cursorImg.size.width / 2, y: self.cursorImg.size.height / 2))
                            self.gameView.addCursorRect(self.gameView.frame, cursor: self.myCursor)
                        }
                        cameraNode.camera?.wantsDepthOfField = true
                        //cameraNode.camera?.focalBlurSampleCount = 5
                        gameView.overlaySKScene = skMenu
                    }else{
                        showDbgMsg(dbgMsg: DbgMsgs.gameHideMenu)
                        DispatchQueue.main.sync {
                            self.gameView.removeCursorRect(self.gameView.frame, cursor: self.myCursor)
                            self.gameView.addCursorRect(self.gameView.frame, cursor: NSCursor.arrow())
                        }
                        cameraNode.camera?.wantsDepthOfField = false
                        gameView.overlaySKScene = sk
                    }
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_RETURN){ // RETURN: Choose MENU
                if(menuShowing){
                    if(menuPos == 0 || menuPos == 1){ // Singleplayer / Multiplayer
                        showDbgMsg(dbgMsg: DbgMsgs.gameHideMenu)
                        menuShowing = false
                        cameraNode.camera?.wantsDepthOfField = false
                        gameView.overlaySKScene = sk
                    }else if(menuPos == 2){ // Setup
                        //showDbgMsg(dbgMsg: DbgMsgs.gameHideMenu)
                        menuSetupShowing = true
                        self.gameView.overlaySKScene = self.skSetup
                    }else if(menuPos == 3){ // Credits
                        //showDbgMsg(dbgMsg: DbgMsgs.gameHideMenu)
                        menuCreditsShowing = true
                        skCredits.setUp2()
                        gameView.overlaySKScene = skCredits
                    }else if(menuPos == 4){ // Exit
                        showDbgMsg(dbgMsg: DbgMsgs.gameQuitApp)
                        NSApplication.shared().terminate(self)
                    }
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_F){ // F: Toggle FIRSTPERSON VIEW
                if(suake.nextKeyModifierFlags.contains(.shift)){
                    gameView.lockCursor = !gameView.lockCursor
                    if(gameView.lockCursor){
                        showDbgMsg(dbgMsg: DbgMsgs.cursorLockOn)
                    }else{
                        showDbgMsg(dbgMsg: DbgMsgs.cursorLockOff)
                    }
                }else{
                    fpv = !fpv
                    if(fpv){
                        showDbgMsg(dbgMsg: DbgMsgs.fpvOn)
                        gameView.pointOfView = cameraNodeFP
                    }else{
                        showDbgMsg(dbgMsg: DbgMsgs.fpvOff)
                        gameView.pointOfView = cameraNode
                    }
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_1){ // 1: Increase Volume / Select MACHINEGUN
                if(suake.nextKeyModifierFlags.contains(NSEvent.ModifierFlags.shift)){
                    mediaManager.incVol()
                }else if(suake.nextKeyModifierFlags.contains(NSEvent.ModifierFlags.option)){
                    showDbgMsg(dbgMsg: DbgMsgs.dbgAmmoReload + DbgMsgs.machinegun)
                    suake.machinegun.ammoCount += machinegunWP.shotsPerPickup
                    suake.selectWeapon(weaponToSelect: CollisionCategory.MachineGunCategory, pickedUp: true)
                }else{
                    suake.selectWeapon(weaponToSelect: CollisionCategory.MachineGunCategory, pickedUp: false)
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_2){ // 2: Select SHOTGUN
                if(suake.nextKeyModifierFlags.contains(NSEvent.ModifierFlags.option)){
                    showDbgMsg(dbgMsg: DbgMsgs.dbgAmmoReload + DbgMsgs.shotgun)
                    suake.shotgun.ammoCount += shotgunWP.shotsPerPickup
                    //shotgunWP.shots += shotgunWP.shotsPerPickup
                    suake.selectWeapon(weaponToSelect: CollisionCategory.ShotgunCategory, pickedUp: true)
                }else{
                    suake.selectWeapon(weaponToSelect: CollisionCategory.ShotgunCategory, pickedUp: false)
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_3){ // 3: Select ROCKETLAUNCHER
                if(suake.nextKeyModifierFlags.contains(NSEvent.ModifierFlags.option)){
                    showDbgMsg(dbgMsg: DbgMsgs.dbgAmmoReload + DbgMsgs.rocketlauncher)
                    suake.rocketlauncher.ammoCount += rocketlauncherWP.shotsPerPickup
                    //rocketlauncherWP.shots += rocketlauncherWP.shotsPerPickup
                    suake.selectWeapon(weaponToSelect: CollisionCategory.RocketLauncherCategory, pickedUp: true)
                }else{
                    suake.selectWeapon(weaponToSelect: CollisionCategory.RocketLauncherCategory, pickedUp: false)
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_4){ // 4: Select RAILGUN
                if(suake.nextKeyModifierFlags.contains(NSEvent.ModifierFlags.option)){
                    showDbgMsg(dbgMsg: DbgMsgs.dbgAmmoReload + DbgMsgs.railgun)
                    suake.railgun.ammoCount += railgunWP.shotsPerPickup
                    suake.selectWeapon(weaponToSelect: CollisionCategory.RailGunCategory, pickedUp: true)
                }else{
                    suake.selectWeapon(weaponToSelect: CollisionCategory.RailGunCategory, pickedUp: false)
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_DASH){
                mediaManager.decVol()
            }else if(suake.nextKeyForRenderLoop == .KEY_H){ // H: TEST WORMHOLE
                //enterWH()
                /*if(whShowing){
                    showDbgMsg(dbgMsg: DbgMsgs.gameWormHoleOn)
                }else{
                    showDbgMsg(dbgMsg: DbgMsgs.gameWormHoleOff)
                }*/
            }else if(suake.nextKeyForRenderLoop == .KEY_D){
                if(suake.nextKeyModifierFlags.contains(NSEvent.ModifierFlags.command)){
                    if(suake.nextKeyModifierFlags.contains(NSEvent.ModifierFlags.shift)){
                        toggleSceneDebugView()
                        if(showAllDebug){
                            showDbgMsg(dbgMsg: DbgMsgs.gameDbgViewOn)
                        }else{
                            showDbgMsg(dbgMsg: DbgMsgs.gameDbgViewOff)
                        }
                    }else{
                        toggleDebugView()
                        if(showAllDebug){
                            showDbgMsg(dbgMsg: DbgMsgs.gameDbgViewOn)
                        }else{
                            showDbgMsg(dbgMsg: DbgMsgs.gameDbgViewOff)
                        }
                    }
                }else if(suake.nextKeyModifierFlags.contains(NSEvent.ModifierFlags.shift)){
                    //CameraHelper.showDieAnim(game: self)
                    showDbgMsg(dbgMsg: DbgMsgs.dieTest)
                    suake.setHealth(health: 0)
                }else{
                    showDbgMsg(dbgMsg: DbgMsgs.hitTest)
                    if(suake.health > 25){
                        suake.setHealth(health: suake.health - 25)
                        CameraHelper.showHitAnim(game: self)
                    }else{
                        suake.setHealth(health: 0)
                    }
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_S){
                mediaManager.bgMusicOn = !mediaManager.bgMusic.isPlaying
                if(mediaManager.bgMusicOn){
                    showDbgMsg(dbgMsg: DbgMsgs.bgMusicOn)
                }else{
                    showDbgMsg(dbgMsg: DbgMsgs.bgMusicOff)
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_O){
                if(suake.nextKeyModifierFlags.contains(.shift)){
                    suake.shotgun.shoot()
                    mediaManager.playSound(soundType: .shotgun)
                }else if(suake.nextKeyModifierFlags.contains(.option)){
                    mediaManager.playSound(soundType: .railgun)
                }else if(suake.nextKeyModifierFlags.contains(.command)){
                    mediaManager.playSound(soundType: .rifle)
                }else{
                    mediaManager.playSound(soundType: .machineGun4)
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_G){
                if(suake.nextKeyModifierFlags.contains(.shift)){
                    showDbgMsg(dbgMsg: DbgMsgs.expandTest)
                    suake.expand()
                }else{
                    showDbgMsg(dbgMsg: DbgMsgs.growTest)
                    suake.grow()
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_3){
                if(suake.nextKeyModifierFlags.contains(.shift)){
                    suake.incSpeed()
                }
            }else if(suake.nextKeyForRenderLoop == .KEY_7){
                if(suake.nextKeyModifierFlags.contains(.shift)){
                    suake.decSpeed()
                }
            }
            suake.nextKeyForRenderLoop = KeyboardDirection.KEY_NONE
        }
    }
    
    func startGame(){
        showDbgMsg(dbgMsg: DbgMsgs.gameStarted)
        gameStarted = true
        suake.startAnim()
        if(DbgVars.vsKI){
            suakeOpp.startAnim()
        }
        if(DbgVars.bgMusicOn && !mediaManager.bgMusic.isPlaying){
            mediaManager.playBGMusic()
        }
    }
    
    let cursorImg:NSImage = NSImage(named: "red.png")!
    var myCursor:NSCursor! // = NSCursor(image:, hotSpot: NSPoint(x: 32, y: 32))
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        /* OLD code
        // If we hit a wall, position needs to be adjusted
        if let position = replacementPosition {
            character.node.position = position
        }*/
    }
    
    // MARK: SCNPhysicsContactDelegate Conformance
    
    // To receive contact messages, you set the contactDelegate property of an SCNPhysicsWorld object.
    // SceneKit calls your delegate methods when a contact begins, when information about the contact changes, and when the contact ends.
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // ROCKET hits FLOOR
        if(contact.nodeA.isKind(of: SuakeNode.self) && contact.nodeB.isKind(of: SuakeNode.self)){
            kiDied = (contact.nodeB as! SuakeNode).opponent
            gameOver()
        }/*else if(contact.nodeA.isKind(of: GoodyNode.self) && contact.nodeB.isKind(of: Pellet.self)){
            
            let blt:Pellet = contact.nodeB as! Pellet
            if(blt.parent != nil && ((contact.nodeA as! GoodyNode).hitByBulletGrp == nil) || (contact.nodeA as! GoodyNode).hitByBulletGrp != nil && (contact.nodeA as! GoodyNode).hitByBulletGrp != blt.bltGrp){
                if(!goodyNode.isHit){
                    goodyNode.isHit = true
                    mediaManager.playSound(soundType: .pick_goody)
                    showDbgMsg(dbgMsg: DbgMsgs.goodyHit)
                    blt.bltGrp.bulletsNode5.removeFromParentNode()
                    blt.bltGrp.bulletsNode4.removeFromParentNode()
                    blt.bltGrp.bulletsNode3.removeFromParentNode()
                    blt.bltGrp.bulletsNode2.removeFromParentNode()
                    blt.bltGrp.bulletsNode1.removeFromParentNode()
                    blt.bltGrp.removeFromParentNode()
                    blt.removeFromParentNode()
                    let when = DispatchTime.now() + (self.moveDelay * 0.1)
                        DispatchQueue.main.asyncAfter(deadline: when) {
                        self.goodyNode.newGoodyPos()
                        self.goodyNode.posGoody()
                    }
                }
            }
        }*/else if(contact.nodeA.isKind(of: Portal.self) && contact.nodeB.isKind(of: MachinegunBullet.self) && (contact.nodeA as! Portal).inPortal){
            let blt:MachinegunBullet = contact.nodeB as! MachinegunBullet
            if(!blt.isBeaming){
                blt.isBeaming = true
                blt.removeFromParentNode()
                for i in (0..<suake.machinegun.firedShots.count){
                    if(suake.machinegun.firedShots[i] == blt){
                        suake.machinegun.firedShots.remove(at: i)
                        break
                    }
                }
                for i in (0..<allPortalGroups.count){
                    if(allPortalGroups[i].id == (contact.nodeA as! Portal).grpId){
                        suake.machinegun.addSingleBullet(pos: SCNVector3(x: allPortalGroups[i].portalOut.position.x, y: blt.position.y, z: allPortalGroups[i].portalOut.position.z), vect: SCNVector3(x: 0, y: 0, z: 285))
                        break
                    }
                }
                mediaManager.playSound(soundType: .telein)
                showDbgMsg(dbgMsg: DbgMsgs.rifleShotBeamed)
            }
        }else if(contact.nodeA.isKind(of: Portal.self) && contact.nodeB.isKind(of: Pellet.self) && (contact.nodeA as! Portal).inPortal){
            let blt:Pellet = contact.nodeB as! Pellet
            blt.removeFromParentNode()
            for i in (0..<allPortalGroups.count){
                if(allPortalGroups[i].id == (contact.nodeA as! Portal).grpId){
                    suake.shotgun.addSingleBullet(pos: SCNVector3(x: allPortalGroups[i].portalOut.position.x, y: blt.position.y, z: allPortalGroups[i].portalOut.position.z), vect: SCNVector3(x: 0, y: 0, z: blt.shootingVelocity))
                    break
                }
            }
            mediaManager.playSound(soundType: .telein)
        }else if(contact.nodeB.isKind(of: RocketNode.self) && contact.nodeA.isKind(of: Portal.self) && (contact.nodeA as! Portal).inPortal){
            let rn:RocketNode = contact.nodeB as! RocketNode
            if(!rn.isBeaming){
                rn.isBeaming = true
                rn.removeFromParentNode()
                //suake.rocketlauncher.firedShots
                for i in (0..<allPortalGroups.count){
                    if(allPortalGroups[i].id == (contact.nodeA as! Portal).grpId){
                        gameView.scene?.rootNode.addChildNode(suake.rocketlauncher.addRocket(pos: SCNVector3(x: allPortalGroups[i].portalOut.position.x, y: 1.6, z: allPortalGroups[i].portalOut.position.z), xDelta: 0))
                        //rocketlauncher.addRocket(pos: SCNVector3(x: allPortalGroups[i].portalOut.position.x, y: 1.6, z: allPortalGroups[i].portalOut.position.z), xDelta: 0)
                        break
                    }
                }
                mediaManager.playSound(soundType: .telein)
            }
        }/*else if(contact.nodeB.isKind(of: RocketNode.self) && contact.nodeA.isKind(of: SuakeNode.self)){
            let rn:RocketNode = contact.nodeB as! RocketNode
            if(!rn.isExploded){
                rocketlauncher.explodeRocket(rocketNode: rn, targetNode: contact.nodeA, removeTargetNode: false)
                if((contact.nodeA as! SuakeNode).opponent){
                    suakeOpp.setHealth(health: 0)
                }else{
                    suake.setHealth(health: 0)
                }
            }
         }*/else if(contact.nodeB.isKind(of: RailgunBeam.self) && contact.nodeA.isKind(of: SuakeNode.self)){
            let rn:RailgunBeam = contact.nodeB as! RailgunBeam
            if(!rn.isTargetHit){
                rn.isTargetHit = true
                //suake.rocketlauncher.explodeRocket(rocketNode: rn, targetNode: contact.nodeA, removeTargetNode: false)
                if((contact.nodeA as! SuakeNode).opponent){
                    suakeOpp.setHealth(health: suakeOpp.health - rn.damage)
                    //suakeOpp.setHealth(health: 0)
                }else{
                    suake.setHealth(health: 0)
                }
            }
        }else if(contact.nodeB.isKind(of: RocketNode.self) && contact.nodeA.isKind(of: SuakeNode.self)){
            let rn:RocketNode = contact.nodeB as! RocketNode
            if(!rn.isTargetHit){
                suake.rocketlauncher.explodeRocket(rocketNode: rn, targetNode: contact.nodeA, removeTargetNode: false)
                if((contact.nodeA as! SuakeNode).opponent){
                    suakeOpp.setHealth(health: suakeOpp.health - rn.damage)
                    //suakeOpp.setHealth(health: 0)
                }else{
                    suake.setHealth(health: 0)
                }
            }
        }else if(contact.nodeB.isKind(of: Pellet.self) && contact.nodeA.isKind(of: SuakeNode.self)){
            let plt:Pellet = contact.nodeB as! Pellet
            if(!plt.isTargetHit){
                plt.isTargetHit = true
                //suake.rocketlauncher.explodeRocket(rocketNode: rn, targetNode: contact.nodeA, removeTargetNode: false)
                if((contact.nodeA as! SuakeNode).opponent){
                    plt.removeFromParentNode()
                    suakeOpp.setHealth(health: suakeOpp.health - plt.damage)
                    //suakeOpp.setHealth(health: 0)
                }else{
                    suake.setHealth(health: 0)
                }
            }
        }else if(contact.nodeB.isKind(of: MachinegunBullet.self) && contact.nodeA.isKind(of: SuakeNode.self)){
            let rn:MachinegunBullet = contact.nodeB as! MachinegunBullet
            if(!rn.isTargetHit){
                rn.isTargetHit = true
                rn.removeFromParentNode()
                if((contact.nodeA as! SuakeNode).opponent){
                    showDbgMsg(dbgMsg: DbgMsgs.oppHit)
                    suakeOpp.setHealth(health: suakeOpp.health - rn.damage)
                    for i in (0..<suake.machinegun.firedShots.count){
                        if(suake.machinegun.firedShots[i] == rn){
                            suake.machinegun.firedShots.remove(at: i)
                            break
                        }
                    }
                }/*else{
                    suake.setHealth(health: 0)
                }*/
            }
        }else if(contact.nodeA.isKind(of: RocketNode.self) && contact.nodeB.isKind(of: SuakeNode.self)){
            var i = -1
            i /= -1
        }/*else if(contact.nodeB.isEqual(to: floorNode)){
            if(contact.nodeA.isKind(of: RocketNode.self)){
                let rn:RocketNode = contact.nodeA as! RocketNode
                if(!rn.isExploded){
                    rocketlauncher.explodeRocket(rocketNode: rn, targetNode: contact.nodeB, removeTargetNode: false)
                }
            }
        }*/
        // ROCKET hits GOODY
        else if(contact.nodeA.isEqual(to: goodyNode) && contact.nodeB.isKind(of: RocketNode.self)){
            let rn:RocketNode = contact.nodeB as! RocketNode
            if(!rn.isTargetHit){
                showDbgMsg(dbgMsg: DbgMsgs.goodyHit)
                suake.grow()
                suake.rocketlauncher.explodeRocket(rocketNode: rn, targetNode: contact.nodeA, removeTargetNode: false)
                suake.score += 9
                setScore(score: suake.score)
                goodyNode.newGoodyPos()
                goodyNode.posGoody()
                mediaManager.playSound(soundType: .pick_goody)
            }
        }
        /*OLD code
        contact.match(BitmaskCollision) { (matching, other) in
            self.characterNode(other, hitWall: matching, withContact: contact)
        }
        contact.match(BitmaskCollectable) { (matching, _) in
            self.collectPearl(matching)
        }
        contact.match(BitmaskSuperCollectable) { (matching, _) in
            self.collectFlower(matching)
        }
        contact.match(BitmaskEnemy) { (_, _) in
            self.character.catchFire()
        }*/
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        if(contact.nodeB.isKind(of: RocketNode.self) && contact.nodeA.isKind(of: SuakeNode.self)){
            var i = -1
            i /= -1
        }else if(contact.nodeA.isKind(of: RocketNode.self) && contact.nodeB.isKind(of: SuakeNode.self)){
            var i = -1
            i /= -1
        }
        /*OLD code
         contact.match(BitmaskCollision) { (matching, other) in
            self.characterNode(other, hitWall: matching, withContact: contact)
        }*/
    }
    
    /*private var maxPenetrationDistance = CGFloat(0.0)
    private var replacementPosition: SCNVector3?
    
    private func characterNode(_ characterNode: SCNNode, hitWall wall: SCNNode, withContact contact: SCNPhysicsContact) {
        if characterNode.parent != character.node {
            return
        }
        
        if maxPenetrationDistance > contact.penetrationDistance {
            return
        }
        
        maxPenetrationDistance = contact.penetrationDistance
        
        var characterPosition = float3(character.node.position)
        var positionOffset = float3(contact.contactNormal) * Float(contact.penetrationDistance)
        positionOffset.y = 0
        characterPosition += positionOffset
        
        replacementPosition = SCNVector3(characterPosition)
    }*/
    
    // MARK: Scene Setup
    // Nodes to manipulate the camera
    private let cameraYHandle = SCNNode()
    private let cameraXHandle = SCNNode()
    private let cameraNewHandle = SCNNode()
    
    private func setupCamera() {
        let ALTITUDE = 1.0
        let DISTANCE = 10.0
        
        // We create 2 nodes to manipulate the camera:
        // The first node "cameraXHandle" is at the center of the world (0, ALTITUDE, 0) and will only rotate on the X axis
        // The second node "cameraYHandle" is a child of the first one and will ony rotate on the Y axis
        // The camera node is a child of the "cameraYHandle" at a specific distance (DISTANCE).
        // So rotating cameraYHandle and cameraXHandle will update the camera position and the camera will always look at the center of the scene.
        
        let pov = self.gameView.pointOfView!
        pov.eulerAngles = SCNVector3Zero
        pov.position = SCNVector3(0.0, 0.0, DISTANCE)
        
        cameraXHandle.rotation = SCNVector4(1.0, 0.0, 0.0, -M_PI_4 * 0.125)
        cameraXHandle.addChildNode(pov)
        
        cameraYHandle.position = SCNVector3(0.0, ALTITUDE, 0.0)
        cameraYHandle.rotation = SCNVector4(0.0, 1.0, 0.0, M_PI_2 + M_PI_4 * 3.0)
        cameraYHandle.addChildNode(cameraXHandle)
        
        gameView.scene?.rootNode.addChildNode(cameraYHandle)
        
        // Animate camera on launch and prevent the user from manipulating the camera until the end of the animation.
        SCNTransaction.animateWithDuration(completionBlock: { self.lockCamera = false }) {
            self.lockCamera = true
            
            // Create 2 additive animations that converge to 0
            // That way at the end of the animation, the camera will be at its default position.
            let cameraYAnimation = CABasicAnimation(keyPath: "rotation.w")
            cameraYAnimation.fromValue = SCNFloat(M_PI) * 2.0 - self.cameraYHandle.rotation.w as NSNumber
            cameraYAnimation.toValue = 0.0
            cameraYAnimation.isAdditive = true
            cameraYAnimation.beginTime = CACurrentMediaTime() + 3.0 // wait a little bit before stating
            cameraYAnimation.fillMode = kCAFillModeBoth
            cameraYAnimation.duration = 5.0
            cameraYAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.cameraYHandle.addAnimation(cameraYAnimation, forKey: nil)
            
            let cameraXAnimation = cameraYAnimation.copy() as! CABasicAnimation
            cameraXAnimation.fromValue = -SCNFloat(M_PI_2) + self.cameraXHandle.rotation.w as NSNumber
            self.cameraXHandle.addAnimation(cameraXAnimation, forKey: nil)
        }
    }
    
    /*private func setupAutomaticCameraPositions() {
        let rootNode = gameView.scene!.rootNode
        
        mainGround = rootNode.childNode(withName: "bloc05_collisionMesh_02", recursively: true)
        
        groundToCameraPosition[rootNode.childNode(withName: "bloc04_collisionMesh_02", recursively: true)!] = SCNVector3(-0.188683, 4.719608, 0.0)
        groundToCameraPosition[rootNode.childNode(withName: "bloc03_collisionMesh", recursively: true)!] = SCNVector3(-0.435909, 6.297167, 0.0)
        groundToCameraPosition[rootNode.childNode(withName: "bloc07_collisionMesh", recursively: true)!] = SCNVector3( -0.333663, 7.868592, 0.0)
        groundToCameraPosition[rootNode.childNode(withName: "bloc08_collisionMesh", recursively: true)!] = SCNVector3(-0.575011, 8.739003, 0.0)
        groundToCameraPosition[rootNode.childNode(withName: "bloc06_collisionMesh", recursively: true)!] = SCNVector3( -1.095519, 9.425292, 0.0)
        groundToCameraPosition[rootNode.childNode(withName: "bloc05_collisionMesh_02", recursively: true)!] = SCNVector3(-0.072051, 8.202264, 0.0)
        groundToCameraPosition[rootNode.childNode(withName: "bloc05_collisionMesh_01", recursively: true)!] = SCNVector3(-0.072051, 8.202264, 0.0)
    }*/
    
    /*private func setupCollisionNode(_ node: SCNNode) {
        if let geometry = node.geometry {
            // Collision meshes must use a concave shape for intersection correctness.
            node.physicsBody = SCNPhysicsBody.static()
            node.physicsBody!.categoryBitMask = BitmaskCollision
            node.physicsBody!.physicsShape = SCNPhysicsShape(node: node, options: [.type: SCNPhysicsShape.ShapeType.concavePolyhedron as NSString])
            
            // Get grass area to play the right sound steps
            if geometry.firstMaterial!.name == "grass-area" {
                if grassArea != nil {
                    geometry.firstMaterial = grassArea
                } else {
                    grassArea = geometry.firstMaterial
                }
            }
            
            // Get the water area
            if geometry.firstMaterial!.name == "water" {
                waterArea = geometry.firstMaterial
            }
            
            // Temporary workaround because concave shape created from geometry instead of node fails
            let childNode = SCNNode()
            node.addChildNode(childNode)
            childNode.isHidden = true
            childNode.geometry = node.geometry
            node.geometry = nil
            node.isHidden = false
            
            if node.name == "water" {
                node.physicsBody!.categoryBitMask = BitmaskWater
            }
        }
        
        for childNode in node.childNodes {
            if childNode.isHidden == false {
                setupCollisionNode(childNode)
            }
        }
    }*/
    
    /*private func setupSounds() {
        // Get an arbitrary node to attach the sounds to.
        let node = self.gameView.scene!.rootNode
        
        node.addAudioPlayer(SCNAudioPlayer(source: SCNAudioSource(name: "music.m4a", volume: 0.25, positional: false, loops: true, shouldStream: true)))
        node.addAudioPlayer(SCNAudioPlayer(source: SCNAudioSource(name: "wind.m4a", volume: 0.3, positional: false, loops: true, shouldStream: true)))
        flameThrowerSound = SCNAudioPlayer(source: SCNAudioSource(name: "flamethrower.mp3", volume: 0, positional: false, loops: true))
        node.addAudioPlayer(flameThrowerSound)
        
        collectPearlSound = SCNAudioSource(name: "collect1.mp3", volume: 0.5)
        collectFlowerSound = SCNAudioSource(name: "collect2.mp3")
        victoryMusic = SCNAudioSource(name: "Music_victory.mp3", volume: 0.5, shouldLoad: false)
    }
    
    // MARK: Collecting Items
    
    private func removeNode(_ node: SCNNode, soundToPlay sound: SCNAudioSource) {
        if let parentNode = node.parent {
            let soundEmitter = SCNNode()
            soundEmitter.position = node.position
            parentNode.addChildNode(soundEmitter)
            
            soundEmitter.runAction(SCNAction.sequence([
                SCNAction.playAudio(sound, waitForCompletion: true),
                SCNAction.removeFromParentNode()]))
            
            node.removeFromParentNode()
        }
    }*/
    
    
    // MARK: Congratulating the Player
    
    /*OLD code
     private func showEndScreen() {
        gameIsComplete = true
        
        // Add confettis
        let particleSystemPosition = SCNMatrix4MakeTranslation(0.0, 8.0, 0.0)
        #if os(iOS) || os(tvOS)
        gameView.scene!.addParticleSystem(confettiParticleSystem, transform: particleSystemPosition)
        #elseif os(OSX)
        gameView.scene!.addParticleSystem(confettiParticleSystem, transform: particleSystemPosition)
        #endif
        
        // Stop the music.
        gameView.scene!.rootNode.removeAllAudioPlayers()
        
        // Play the congrat sound.
        gameView.scene!.rootNode.addAudioPlayer(SCNAudioPlayer(source: victoryMusic))
        
        // Animate the camera forever
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.cameraYHandle.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y:-1, z: 0, duration: 3)))
            self.cameraXHandle.runAction(SCNAction.rotateTo(x: CGFloat(-M_PI_4), y: 0, z: 0, duration: 5.0))
        }
        
        gameView.showEndScreen();
    }*/
    
}
