//
//  MediaManager.swift
//  iSuake
//
//  Created by Kim David Hauser on 28.10.17.
//  Copyright © 2017 Kim David Hauser. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayer {
    
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
    
    convenience init?(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        self.init(playerItem: playerItem)
        self.rate = 0
    }
    
    convenience init?(name: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return nil
        }
        self.init(url: url)
        self.rate = 0
    }
    
    func playFromStart() {
        seek(to: CMTimeMake(0, 1))
        play()
    }
    
    func playLoop() {
        playFromStart()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.currentItem, queue: nil) { notification in
            if self.timeControlStatus == .playing {
                self.playFromStart()
            }
        }
    }
    
    func endLoop() {
        pause()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self)
    }
}

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

class MediaManager{
    
    var game:GameViewController!
    public var player: AVAudioPlayer?
    
    //public var _volumeNG:Decimal = Decimal(0.15)
    
    public var _volumeEffects:Decimal = Decimal(0.15) //:Float = 0.35
    public var _volume:Decimal = Decimal(0.15) //:Float = 0.15
    public var _volumeIncDecStep:Decimal = Decimal(0.05) //:Float = 0.05
    public var _volumeMin:Decimal = Decimal(0.0) //:Float = 0.05
    public var _volumeMax:Decimal = Decimal(1.0) //:Float = 1.0
    
    let bgMusic:AVPlayer = AVPlayer(name: "music_cut", extension: "mp3")!
    
    public var _playBGMusic:Bool = false
    var bgMusicOn: Bool {
        set {
            _playBGMusic = newValue
            if(_playBGMusic){
                bgMusic.volume = Float(self.volume as NSNumber)
                bgMusic.playLoop()
            }else{
                bgMusic.endLoop()
            }
        }
        get { return _playBGMusic }
    }
    
    var volume: Decimal {
        set {
            
            _volume = newValue
            bgMusic.volume = Float(_volume as NSNumber)
            GSAudio.sharedInstance.volume = Float(_volume as NSNumber)
        }
        get { return _volume }
    }
    
    public func incVol(){
        if(volume < _volumeMax){
            volume += _volumeIncDecStep
            game.showDbgMsg(dbgMsg: DbgMsgs.gameVolumeChanged + volume.description)
        }
    }
    
    public func decVol(){
        if(volume > _volumeMin + 0.001){
            volume -= _volumeIncDecStep
        }else{
            volume = _volumeMin
        }
        game.showDbgMsg(dbgMsg: DbgMsgs.gameVolumeChanged + volume.description)
    }
    
    enum SoundType: Int {
        case railgun = 1, shotgun, rifle, wp_change, pick_goody, pick_weapon, telein, bottleRocket, machineGun3, machineGun4, noammo, pain_25, pain_50, pain_75, pain_100, explosion1, explosion2, hitEnemy, beep, beep2
    }
    
    init(_game:GameViewController) {
        self.game = _game
        self.player = AVAudioPlayer()
        self.volume = 0.15
        //self.player?.volume = self.volume
    }
    
    public func playBGMusic(){
        bgMusic.volume = Float(volume as NSNumber)
        bgMusic.playLoop()
    }

    public func playCutSuakePainSound(percentLeft:Double) {
        if(percentLeft > 75){
            playSound(soundType: .pain_100, volume: self._volumeEffects)
        }else if(percentLeft > 50){
            playSound(soundType: .pain_75, volume: self._volumeEffects)
        }else if(percentLeft > 25){
            playSound(soundType: .pain_50, volume: self._volumeEffects)
        }else{
            playSound(soundType: .pain_25, volume: self._volumeEffects)
        }
    }
    
    public func playSound(soundType: SoundType) {
        playSound(soundType: soundType, volume: self.volume)
    }
    
    public func playSound(soundType: SoundType, volume:Decimal) {
        var fileName = ""
        
        switch soundType {
        case SoundType.beep:
            fileName = "beep-07"
            break
        case SoundType.beep2:
            fileName = "beep-08b"
            break
        case SoundType.rifle:
            fileName = "rifle"
            break
        case SoundType.shotgun:
            fileName = "sshotf1b"
            break
        case SoundType.railgun:
            fileName = "railgf1a"
            break
        case SoundType.wp_change:
            fileName = "change"
            break
        case SoundType.pick_goody:
            fileName = "land1"
            break
        case SoundType.pick_weapon:
            fileName = "w_pkup"
            break
        case SoundType.telein:
            fileName = "telein"
            break
        case SoundType.bottleRocket:
            fileName = "bottleRocket"
            break
        case SoundType.pain_25:
            fileName = "pain25_1"
            break
        case SoundType.pain_50:
            fileName = "pain50_1"
            break
        case SoundType.pain_75:
            fileName = "pain27_1"
            break
        case SoundType.pain_100:
            fileName = "pain100_1"
            break
        case SoundType.machineGun3:
            fileName = "machineGun3"
            break
        case SoundType.machineGun4:
            fileName = "machineGun4"
            break
        case SoundType.explosion1:
            fileName = "Explosion1"
            break
        case SoundType.explosion2:
            fileName = "Explosion2"
            break
        case SoundType.hitEnemy:
            fileName = "hitEnemy"
            break
        case SoundType.noammo:
            fileName = "noammo"
            break
        default:
            fileName = "land1"
            break
        }
        if(fileName != ""){
            GSAudio.sharedInstance.playSound(soundFileName: fileName, volume: Float(volume as NSNumber))
        }
    }
    
    
    private func playSoundInternal(path:String){
        playSoundInternal(path: path, volume: self.volume)
    }
    
    private func playSoundInternal(path:String, volume:Decimal){
        //if(!self.gameBoard.suakeGame.muteSound){
            let url = URL(fileURLWithPath: path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.volume = Float(volume as NSNumber)
                player?.play()
            } catch {
            
            }
        //}
    }
}
