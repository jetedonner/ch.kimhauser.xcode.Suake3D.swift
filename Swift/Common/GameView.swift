/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The view displaying the game scene, including the 2D overlay.
*/

import simd
import SceneKit
import SpriteKit
    
class GameView: SCNView {
    
    // MARK: 2D Overlay
    
    private let overlayNode = SKNode()
    private let congratulationsGroupNode = SKNode()
    private let collectedPearlCountLabel = SKLabelNode(fontNamed: "Chalkduster")
    private var collectedFlowerSprites = [SKSpriteNode]()
    
    public var chMove:MoveCrosshairDelegate!
    public var lockCursor:Bool = false
    
    #if os(OSX)
    internal var lastMousePosition = float2(0)
    #elseif os(iOS)
    internal var padTouch: UITouch?
    internal var panningTouch: UITouch?
    #endif
    
    #if os(iOS) || os(tvOS)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //setup2DOverlay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //layout2DOverlay()
    }
    
    #elseif os(OSX)
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        //setup2DOverlay()
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        //layout2DOverlay()
    }
    
    var trackingArea : NSTrackingArea?
    
    override func updateTrackingAreas() {
        if trackingArea != nil {
            self.removeTrackingArea(trackingArea!)
        }
        let options : NSTrackingAreaOptions =
            [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow]
        trackingArea = NSTrackingArea(rect: self.bounds, options: options,
                                      owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea!)
    }
    
    var lastPosInitialized:Bool = false
    public var xDelta:Float = 0
    public var yDelta:Float = 0
    public var xPercent:Float = 0
    public var yPercent:Float = 0
    public var zPercent:Float = 1.0
    //var manualMove:Bool = false
    override func mouseMoved(with event: NSEvent) {
        //Swift.print("Mouse moved: \(event)")
        //if(!manualMove){
            if(chMove != nil){
                chMove.mouseMoved(with: event)
                let mousePosition = float2(self.convert(event.locationInWindow, from: nil))
                // DELALL!!!
                //lastMousePosition.x
                if(!lastPosInitialized /*lastMousePosition.x == 0 && lastMousePosition.y == 0*/){
                    lastPosInitialized = true
                    lastMousePosition = float2(x: mousePosition.x, y: mousePosition.y)
                }
                let tmp = CGGetLastMouseDelta()
                if(tmp.x == 0 && tmp.y == 0){
                    
                }else{
                    xDelta += Float(tmp.x)
                    yDelta += Float(tmp.y)
                    chMove.panCamera(float2(x: Float(tmp.x), y: Float(tmp.y * -1))) //mousePosition - lastMousePosition)
                }
                //lastMousePosition = mousePosition
                //NSCursor.
                //  Converted to Swift 4 by Swiftify v4.1.6792 - https://objectivec2swift.com/
                if(lockCursor){ //} mf.contains(NSEvent.ModifierFlags.shift)){
                    //manualMove = true
                    //var warpPoint = CGPoint(x: 600, y: 600)
                    var warpPoint = CGPoint(x: CGFloat(lastMousePosition.x), y: CGFloat(lastMousePosition.y)) // CGPoint(x: 42, y: 42)
                    //CGGetLastMouseDelta()
                    CGWarpMouseCursorPosition(warpPoint)
                    //CGAssociateMouseAndMouseCursorPosition(UInt32(true))
                }else{
                    lastMousePosition = mousePosition
                }
            }
        /*}else{
            lastMousePosition = float2(self.convert(event.locationInWindow, from: nil))
            manualMove = false
        }*/
    }
    
    override func mouseEntered(with event: NSEvent) {
        if(chMove != nil){
            chMove.mouseEntered(with: event)
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if(chMove != nil){
            chMove.mouseExited(with: event)
        }
    }
    
    /*override func mouseMoved(with event: NSEvent) {
        var i:Int = -1
        i /= -1
    }*/
    
    #endif
    
    /*private func layout2DOverlay() {
        DispatchQueue.main.async { // Correct
            self.overlayNode.position = CGPoint(x: 0.0, y: self.bounds.size.height)
            self.congratulationsGroupNode.position = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        }
        //overlayNode.position = CGPoint(x: 0.0, y: bounds.size.height)
        //congratulationsGroupNode.position = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        
        /*congratulationsGroupNode.xScale = 1.0
        congratulationsGroupNode.yScale = 1.0
        let currentBbox = congratulationsGroupNode.calculateAccumulatedFrame()
        
        let margin = CGFloat(25.0)
        let maximumAllowedBbox = bounds.insetBy(dx: margin, dy: margin)
        
        let top = currentBbox.maxY - congratulationsGroupNode.position.y
        let bottom = congratulationsGroupNode.position.y - currentBbox.minY
        let maxTopAllowed = maximumAllowedBbox.maxY - congratulationsGroupNode.position.y
        let maxBottomAllowed = congratulationsGroupNode.position.y - maximumAllowedBbox.minY
        
        let left = congratulationsGroupNode.position.x - currentBbox.minX
        let right = currentBbox.maxX - congratulationsGroupNode.position.x
        let maxLeftAllowed = congratulationsGroupNode.position.x - maximumAllowedBbox.minX
        let maxRightAllowed = maximumAllowedBbox.maxX - congratulationsGroupNode.position.x
        
        let topScale = top > maxTopAllowed ? maxTopAllowed / top : 1
        let bottomScale = bottom > maxBottomAllowed ? maxBottomAllowed / bottom : 1
        let leftScale = left > maxLeftAllowed ? maxLeftAllowed / left : 1
        let rightScale = right > maxRightAllowed ? maxRightAllowed / right : 1
        
        let scale = min(topScale, min(bottomScale, min(leftScale, rightScale)))
        
        congratulationsGroupNode.xScale = scale
        congratulationsGroupNode.yScale = scale*/
    }
    
    private func setup2DOverlay() {
        let w = bounds.size.width
        let h = bounds.size.height
        
        // Setup the game overlays using SpriteKit.
        let skScene = SKScene(size: CGSize(width: w, height: h))
        skScene.scaleMode = .resizeFill
        
        skScene.addChild(overlayNode)
        overlayNode.position = CGPoint(x: 0.0, y: h)
        
        // The Max icon.
        overlayNode.addChild(SKSpriteNode(imageNamed: "MaxIcon.png", position: CGPoint(x: 50, y: -50), scale: 0.5))
        
        // The flowers.
        for i in 0..<3 {
            collectedFlowerSprites.append(SKSpriteNode(imageNamed: "FlowerEmpty.png", position: CGPoint(x: 110 + i * 40, y: -50), scale: 0.25))
            overlayNode.addChild(collectedFlowerSprites[i])
        }
        
        // The pearl icon and count.
        overlayNode.addChild(SKSpriteNode(imageNamed: "ItemsPearl.png", position: CGPoint(x: 110, y: -100), scale: 0.5))
        collectedPearlCountLabel.text = "x0"
        collectedPearlCountLabel.position = CGPoint(x: 152, y: -113)
        overlayNode.addChild(collectedPearlCountLabel)
        
        // The virtual D-pad
        #if os(iOS)
        
        let virtualDPadBounds = virtualDPadBoundsInScene()
        let dpadSprite = SKSpriteNode(imageNamed: "dpad.png", position: virtualDPadBounds.origin, scale: 1.0)
        dpadSprite.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        dpadSprite.size = virtualDPadBounds.size
        skScene.addChild(dpadSprite)
        
        #endif
        
        // Assign the SpriteKit overlay to the SceneKit view.
        overlaySKScene = skScene
        skScene.isUserInteractionEnabled = false
    }
    
    var collectedPearlsCount = 0 {
        didSet {
            if collectedPearlsCount == 10 {
                collectedPearlCountLabel.position = CGPoint(x: 158, y: collectedPearlCountLabel.position.y)
            }
            collectedPearlCountLabel.text = "x\(collectedPearlsCount)"
        }
    }
    
    var collectedFlowersCount = 0 {
        didSet {
            collectedFlowerSprites[collectedFlowersCount - 1].texture = SKTexture(imageNamed: "FlowerFull.png")
        }
    }
    
    // MARK: Congratulating the Player
    
    func showEndScreen() {
        // Congratulation title
        let congratulationsNode = SKSpriteNode(imageNamed: "congratulations.png")
        
        // Max image
        let characterNode = SKSpriteNode(imageNamed: "congratulations_pandaMax.png")
        characterNode.position = CGPoint(x: 0.0, y: -220.0)
        characterNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        congratulationsGroupNode.addChild(characterNode)
        congratulationsGroupNode.addChild(congratulationsNode)
        
        let overlayScene = overlaySKScene!
        overlayScene.addChild(congratulationsGroupNode)
        
        // Layout the overlay
        layout2DOverlay()
        
        // Animate
        (congratulationsNode.alpha, congratulationsNode.xScale, congratulationsNode.yScale) = (0.0, 0.0, 0.0)
        congratulationsNode.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.25),
            SKAction.sequence([SKAction.scale(to: 1.22, duration: 0.25), SKAction.scale(to: 1.0, duration: 0.1)])]))
        
        (characterNode.alpha, characterNode.xScale, characterNode.yScale) = (0.0, 0.0, 0.0)
        characterNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.5),
                SKAction.sequence([SKAction.scale(to: 1.22, duration: 0.25), SKAction.scale(to: 1.0, duration: 0.1)])])]))
        
        congratulationsGroupNode.position = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5);
    }*/
    
    // MARK: Mouse and Keyboard Events
    
    #if os(OSX)
   
    var eventsDelegate: KeyboardAndMouseEventsDelegate?
    //var keyPressDelegate: KeyPressDelegate?
    
    // !!! WONT ALLOW STATISTICS CLICK (DBG MENU) !!!!
    override func mouseDown(with event: NSEvent) {
        guard let eventsDelegate = eventsDelegate, eventsDelegate.mouseDown(in: self, with: event) else {
            super.mouseDown(with: event)
            return
        }
        super.mouseDown(with: event)
    }
    
    /*override func mouseDragged(with event: NSEvent) {
        guard let eventsDelegate = eventsDelegate, eventsDelegate.mouseDragged(in: self, with: event) else {
            super.mouseDragged(with: event)
            return
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let eventsDelegate = eventsDelegate, eventsDelegate.mouseUp(in: self, with: event) else {
            super.mouseUp(with: event)
            return
        }
    }*/
    var mf:NSEvent.ModifierFlags = NSEvent.ModifierFlags.init(rawValue: 0)
    override func keyDown(with event: NSEvent) {
        mf = event.modifierFlags
        guard let eventsDelegate = eventsDelegate, eventsDelegate.keyDown(in: self, with: event) else {
            super.keyDown(with: event)
            
            /*LEGACY code
            
            if(keyPressDelegate != nil){
                keyPressDelegate?.keyPressed(with: event)
            }*/
            return
        }
    }
    
    override func keyUp(with event: NSEvent) {
        mf = NSEvent.modifierFlags() // event.modifierFlags
        guard let eventsDelegate = eventsDelegate, eventsDelegate.keyUp(in: self, with: event) else {
            super.keyUp(with: event)
            return
        }
    }
    
    override func scrollWheel(with event: NSEvent){
        var i = -1
        i /= -1
        super.scrollWheel(with: event)
    }
    
    /* LEGACY code
    
     override func keyDown(with event: NSEvent) {
        if(keyPressDelegate != nil){
            keyPressDelegate?.keyPressed(with: event)
        }
    }*/
    
    #endif
    
    // MARK: Virtual D-pad
    
    #if os(iOS)
    
    private func virtualDPadBoundsInScene() -> CGRect {
        return CGRect(x: 10.0, y: 10.0, width: 150.0, height: 150.0)
    }
    
    func virtualDPadBounds() -> CGRect {
        var virtualDPadBounds = virtualDPadBoundsInScene()
        virtualDPadBounds.origin.y = bounds.size.height - virtualDPadBounds.size.height + virtualDPadBounds.origin.y
        return virtualDPadBounds
    }
    
    #endif
    
}
