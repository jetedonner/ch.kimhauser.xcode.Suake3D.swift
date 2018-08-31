//
//  CreditsSkScene.swift
//  Suake3D
//
//  Created by dave on 01.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SpriteKit

class CreditsSkScene : SKScene {
    
    let str:String = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
    
    var game:GameViewController!
    var scrollView:NSScrollView!
    //var inPortal:Bool = true
    
    convenience init(game:GameViewController){
        self.init(fileNamed: "game.scnassets/overlays/Credits")!
        //self.init()
        self.game = game
    }
    
    public func setUp2(){
        // Create scrollview
        /*var text:NSTextView = NSTextView(frame: NSRect(x: 0, y: 0, width: 200, height: 200))
        text.string = str
        
        let scrollView = NSScrollView(frame: (self.view?.window?.contentView?.frame)!)
        
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = NSBorderType.noBorder
        //scrollView.autoresizingMask = NSAutoresizingMaskOptions(rawValue: /*.ViewWidthSizable &*/ .ViewHeightSizable)
        
        
        // Create document view
        
        //let docView = LineView()
        //docView.autoresizingMask = NSAutoresizingMaskOptions(arrayLiteral: .ViewWidthSizable, .ViewHeightSizable)
        
        
        // Add the docView to the scrollView
        scrollView.documentView = text
        
        
        // Add the document to the docView (note: This will trigger an update of its frame based on the available and needed size, hence it must be done after the docView is inserted into the scrollview)
        
        //docView.document = document as? MyDocument
        
        
        // Set the scrollview as the window's main view
        self.view?.window?.contentView = scrollView
        //game.gameView.window!.contentView = scrollView*/
    }
    
    public func setupScrollView(){
        /*var text:NSTextView = NSTextView(frame: NSRect(x: 0, y: 0, width: 200, height: 200))
        text.string = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."

        //  The converted code is limited to 1 KB.
        //  Please Sign Up (Free!) to remove this limitation.
        //
        //  Converted to Swift 4 by Swiftify v4.1.6781 - https://objectivec2swift.com/
        var windowSize: CGSize = game.gameView.window!.contentView!.frame.size
        //var scene = IIMyScene(size: windowSize)
        //Set the scale mode to scale to fit the window
        //scene.scaleMode = SKSceneScaleMode.resizeFill
        var skView: SKView? = self.view //skView
        //var scrollView = self.scrollView as? NSScrollView
        //self.scrollView = NSScrollView(frame: frame)
        skView?.presentScene(self)
        skView?.showsFPS = true
        skView?.showsNodeCount = true
        scrollView?.drawsBackground = false
        scrollView?.hasVerticalScroller = true
        scrollView?.hasHorizontalScroller = true
        scrollView?.borderType = .noBorder
        scrollView?.autohidesScrollers = true
        //var clearDocumentView = ENHFLippedView(frame: NSRectFromCGRect(CGRect.zero))
        var clearDocumentView = NSView(frame: NSRectFromCGRect(CGRect.zero))
        clearDocumentView.wantsLayer = true
        clearDocumentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView?.documentView = clearDocumentView
        var viewsDict = dictionaryOfNames(arr: skView!, scrollView!, clearDocumentView)
        //var viewsDict = NSDictionaryOfVariableBindings("skView", scrollView, clearDocumentView)
        var constraints: [NSLayoutConstraint]? = nil
        
        if let aDict = viewsDict as? [String : Any] {
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[skView]|", options: [], metrics: nil, views: aDict)
        }
        if let aConstraints = constraints {
            game.gameView.window!.contentView?.addConstraints(aConstraints)
        }
        if let aDict = viewsDict as? [String : Any] {
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[skView]|", options: [], metrics: nil, views: aDict)
        }
        if let aConstraints = constraints {
            game.gameView.window!.contentView?.addConstraints(aConstraints)
        }
        var constraint = NSLayoutConstraint(item: clearDocumentView, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1.5, constant: 0.0)
        game.gameView.window!.contentView?.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: clearDocumentView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.5, constant: 0.0)
        game.gameView.window!.contentView?.addConstraint(constraint)
        var frame: CGRect = (game.gameView.window!.contentView?.frame)!
        var contentSize: CGSize = frame.size
        contentSize.height *= 1.5
        contentSize.width *= 1.5
        //self.contentSize = contentSize
        
        scrollView?.postsBoundsChangedNotifications = true
        // a register for those notifications on the synchronized content view.
        //NotificationCenter.default.addObserver(self, selector: #selector(self.scrollViewDidScroll(_:)), name: NSView.boundsDidChangeNotification, object: scrollView.contentView)
        //_scrollViewDidScroll(scrollView)
        //scrollDown = true
        //Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateString), userInfo: nil, repeats: true)
        
        /*let clearContentView = UIView(frame: CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
        clearContentView.backgroundColor = UIColor.clear
        scrollView.addSubview(clearContentView)
        self.clearContentView = clearContentView*/
        //scrollView?.addSubview(text)
        
        //clearContentView.addObserver(self, forKeyPath: "transform", options: .new, context: &ViewTransformChangedObservationContext)
        game.gameView.overlaySKScene?.view?.addSubview(text)

        //  %< ------------------------ The converted code is limited to 1 KB ------------------------ %<
        //self.ad
        //window.contentView?.addSubview(label)
        //scrollView.addSubview(text)
        //self.view?.addSubview(text)//scrollView)
         */
    }
    
    override func scrollWheel(with event: NSEvent) {
        var i = -1
        i /= -1
        //scene.scrollWheel(with: event)
    }
    
    func dictionaryOfNames(arr:NSView...) -> Dictionary<String,NSView> {
        var d = Dictionary<String,NSView>()
        for (ix,v) in arr.enumerated(){
            d["v\(ix+1)"] = v
        }
        return d
    }
}
