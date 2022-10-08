//
//  AVPlayerView.swift
//  Slime
//
//  Created by Soham Nagawanshi on 2/3/21.
//

import UIKit
import AVKit
import AVFoundation
class AVPlayerView: UIView {

    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    var playerLayer: AVPlayerLayer{
        return layer as! AVPlayerLayer
    }
    var player: AVPlayer?{
        get{
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }

}
