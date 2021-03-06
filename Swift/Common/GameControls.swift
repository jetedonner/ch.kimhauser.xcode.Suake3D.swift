/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Handles keyboard (OS X), touch (iOS) and controller (iOS, tvOS) input for controlling the game.
*/

import simd
import SceneKit
import GameController

#if os(OSX)
    
protocol KeyboardAndMouseEventsDelegate {
    // !!! WONT ALLOW STATISTICS CLICK (DBG MENU) !!!!
    func mouseDown(in view: NSView, with event: NSEvent) -> Bool
    //func mouseDragged(in view: NSView, with event: NSEvent) -> Bool
    //func mouseUp(in view: NSView, with event: NSEvent) -> Bool
    func keyDown(in view: NSView, with event: NSEvent) -> Bool
    func keyUp(in view: NSView, with event: NSEvent) -> Bool
    //func scrollWheel(with event: NSEvent)
}
    
public enum KeyboardDirection : UInt16 {
    case left   = 1123
    case right  = 1124
    case down   = 1125
    case up     = 1126
    case KEY_NONE = 9999,
    KEY_A = 0,
    KEY_S = 1,
    KEY_D = 2,
    KEY_F = 3,
    KEY_H = 4,
    KEY_G = 5,
    KEY_Y = 6,
    KEY_X = 7,
    KEY_C = 8,
    KEY_V = 9,
    KEY_B = 11,
    KEY_Q = 12,
    KEY_W = 13,
    KEY_E = 14,
    KEY_R = 15,
    KEY_Z = 16,
    KEY_T = 17,
    KEY_1 = 18,
    KEY_2 = 19,
    KEY_3 = 20,
    KEY_4 = 21,
    KEY_5 = 23,
    KEY_7 = 26,
    KEY_O = 31,
    KEY_U = 32,
    KEY_UE = 33,
    KEY_P = 35,
    KEY_RETURN = 36,
    KEY_L = 37,
    KEY_DASH = 44,
    KEY_N = 45,
    KEY_M = 46,
    KEY_SPACE = 49,
    KEY_ESC = 53,
    KEY_LEFT = 123,
    KEY_RIGHT = 124,
    KEY_DOWN = 125,
    KEY_UP = 126
    
    var vector : float2 {
        switch self {
        case .KEY_UP:    return float2( 0, -1)
        case .KEY_DOWN:  return float2( 0,  1)
        case .KEY_LEFT:  return float2(-1,  0)
        case .KEY_RIGHT: return float2( 1,  0)
        default: return float2( 0, 0)
        }
    }
}
    
extension GameViewController: KeyboardAndMouseEventsDelegate {
}
    
#endif

extension GameViewController {

    // MARK: Controller orientation
    
    private static let controllerAcceleration = Float(1.0 / 10.0)
    private static let controllerDirectionLimit = float2(1.0)
    
    internal func controllerDirection() -> float2 {
        // Poll when using a game controller
        if let dpad = controllerDPad {
            if dpad.xAxis.value == 0.0 && dpad.yAxis.value == 0.0 {
                controllerStoredDirection = float2(0.0)
            } else {
                controllerStoredDirection = clamp(controllerStoredDirection + float2(dpad.xAxis.value, -dpad.yAxis.value) * GameViewController.controllerAcceleration, min: -GameViewController.controllerDirectionLimit, max: GameViewController.controllerDirectionLimit)
            }
        }
        
        return controllerStoredDirection
    }
    
    // MARK: Game Controller Events
    
    internal func setupGameControllers() {
        #if os(OSX)
        gameView.eventsDelegate = self
        #endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.handleControllerDidConnectNotification(_:)), name: .GCControllerDidConnect, object: nil)
    }
    
    @objc func handleControllerDidConnectNotification(_ notification: NSNotification) {
        let gameController = notification.object as! GCController
        registerCharacterMovementEvents(gameController)
    }
    
    private func registerCharacterMovementEvents(_ gameController: GCController) {
        
        // An analog movement handler for D-pads and thumbsticks.
        let movementHandler: GCControllerDirectionPadValueChangedHandler = { [unowned self] dpad, _, _ in
            self.controllerDPad = dpad
        }
        
        #if os(tvOS)
            
        // Apple TV remote
        if let microGamepad = gameController.microGamepad {
            // Allow the gamepad to handle transposing D-pad values when rotating the controller.
            microGamepad.allowsRotation = true
            microGamepad.dpad.valueChangedHandler = movementHandler
        }
            
        #endif
        
        // Gamepad D-pad
        if let gamepad = gameController.gamepad {
            gamepad.dpad.valueChangedHandler = movementHandler
        }
        
        // Extended gamepad left thumbstick
        if let extendedGamepad = gameController.extendedGamepad {
            extendedGamepad.leftThumbstick.valueChangedHandler = movementHandler
        }
    }
    
    // MARK: Touch Events
    
    #if os(iOS)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if gameView.virtualDPadBounds().contains(touch.location(in: gameView)) {
                // We're in the dpad
                if padTouch == nil {
                    padTouch = touch
                    controllerStoredDirection = float2(0.0)
                }
            } else if panningTouch == nil {
                // Start panning
                panningTouch = touches.first
            }
            
            if padTouch != nil && panningTouch != nil {
                break // We already have what we need
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = panningTouch {
            let displacement = (float2(touch.location(in: view)) - float2(touch.previousLocation(in: view)))
            panCamera(displacement)
        }
        
        if let touch = padTouch {
            let displacement = (float2(touch.location(in: view)) - float2(touch.previousLocation(in: view)))
            controllerStoredDirection = clamp(mix(controllerStoredDirection, displacement, t: GameViewController.controllerAcceleration), min: -GameViewController.controllerDirectionLimit, max: GameViewController.controllerDirectionLimit)
        }
    }
    
    func commonTouchesEnded(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = panningTouch {
            if touches.contains(touch) {
                panningTouch = nil
            }
        }
        
        if let touch = padTouch {
            if touches.contains(touch) || event?.touches(for: view)?.contains(touch) == false {
                padTouch = nil
                controllerStoredDirection = float2(0.0)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        commonTouchesEnded(touches, withEvent: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        commonTouchesEnded(touches, withEvent: event)
    }
    
    #endif
    
    // MARK: Mouse and Keyboard Events
    
    #if os(OSX)
    
    // !!! WONT ALLOW STATISTICS CLICK (DBG MENU) !!!!
    
    func mouseDown(in view: NSView, with event: NSEvent) -> Bool {
        // DELALL!!!
        // Remember last mouse position for dragging.
        if(menuShowing){
            if(menuSetupShowing){
                // Get mouse position in scene coordinates
                let location = event.location(in: skSetup)
                // Get node at mouse position
                let node = skSetup.atPoint(location)
                if(node == lblSetupControls){
                    print("YES lblSetupControls CLICKED")
                }else if(node == lblSetupDisplay){
                    print("YES lblSetupDisplay CLICKED")
                }else if(node == lblSetupMisc){
                    print("YES lblSetupMisc CLICKED")
                }
            }else{
                // Get mouse position in scene coordinates
                let location = event.location(in: skMenu)
                // Get node at mouse position
                let node = skMenu.atPoint(location)
                if(node == lblSinglePlayer || node == lblMultiPlayer){
                    if(node == lblSinglePlayer){
                        print("YES lblSinglePlayer CLICKED")
                    }else{
                        print("YES lblMultiPlayer CLICKED")
                    }
                    showDbgMsg(dbgMsg: DbgMsgs.gameHideMenu)
                    menuShowing = false
                    cameraNode.camera?.wantsDepthOfField = false
                    DispatchQueue.main.async {
                        view.removeCursorRect(view.frame, cursor: self.myCursor)
                        view.addCursorRect(view.frame, cursor: NSCursor.arrow())
                    }
                    gameView.overlaySKScene = sk
                }else if(node == lblCredits){
                    print("YES lblCredits CLICKED")
                    menuCreditsShowing = true
                    skCredits.setUp2()
                    gameView.overlaySKScene = skCredits
                }else if(node == lblSettings){
                    print("YES lblSettings CLICKED")
                    menuSetupShowing = true
                    gameView.overlaySKScene = skSetup
                }else if(node == lblExit){
                    print("YES lblExit CLICKED")
                    showDbgMsg(dbgMsg: DbgMsgs.gameQuitApp)
                    NSApplication.shared().terminate(self)
                }
            }
        }else{
            lastMousePosition = float2(view.convert(event.locationInWindow, from: nil))
            if(DbgVars.clickShotEnabled && lastMousePosition.y > 20.0){
                suake.shoot()
                //showDbgMsg(dbgMsg: DbgMsgs.rocketFired)
                //rocketlauncher.addRocket(xDelta: gameView.xDelta)
            }
        }
        return true
    }
    
    /*func mouseDragged(in view: NSView, with event: NSEvent) -> Bool {
        // let mousePosition = float2(view.convert(event.locationInWindow, from: nil))
        // DELALL!!!
        // panCamera(mousePosition - lastMousePosition)
        // lastMousePosition = mousePosition
        
        return true
    }
    
    func mouseUp(in view: NSView, with event: NSEvent) -> Bool {
        return true
    }*/
    
    func keyDown(in view: NSView, with event: NSEvent) -> Bool {
        print("keyDown: %d", event.keyCode)
        if let direction = KeyboardDirection(rawValue: event.keyCode) {
            if !event.isARepeat {
                
                // LEGACY code
                suake.nextKeyForRenderLoop = direction
                suake.keysForRenderLoop.append(direction)
                suake.nextKeyModifierFlags = event.modifierFlags
                keyPressed(with: event)
                
                // NEW?
                controllerStoredDirection += direction.vector
            }
            return true
        }
        
        return false
    }
    
    func keyUp(in view: NSView, with event: NSEvent) -> Bool {
        print("keyUp: %d", event.keyCode)
        if let direction = KeyboardDirection(rawValue: event.keyCode) {
            if !event.isARepeat {
                controllerStoredDirection -= direction.vector
            }
            return true
        }
        
        return false
    }
    
    /*override func scrollWheel(with event: NSEvent){
        var i = -1
        i /= -1
    }*/
    
    #endif
}
