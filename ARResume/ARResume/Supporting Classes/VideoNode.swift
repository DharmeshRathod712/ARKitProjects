//
//  VideoNode.swift
//  ARImageTrackingWithText
//
//  Created by Rathod on 7/21/20.
//  Copyright © 2020 Rathod. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation
import SpriteKit
import ARKit

class VideoNode: SCNNode {
    
    var videoScene: SKScene!
    var videoNode: SKVideoNode!
    var videoPlayer: AVPlayer!
    
    var isPlaying = false
    
    init(plane: SCNPlane) {
        super.init()
        
        if let fileUrlString = Bundle.main.path(forResource: "video", ofType: "mp4") {
            videoPlayer = AVPlayer(url: URL(fileURLWithPath: fileUrlString))
            videoNode = SKVideoNode(avPlayer: videoPlayer)
            videoNode.yScale = -1
            
            videoScene = SKScene(size: CGSize(width: 1280, height: 960))
            videoScene.scaleMode = .aspectFit
            
            videoNode.size = videoScene.size
            videoNode.position = CGPoint(x: videoScene.size.width / 2,
                                         y: videoScene.size.height / 2)
            
            videoScene.addChild(videoNode)
            
            plane.firstMaterial?.diffuse.contents = videoScene
            
            videoPlayer.volume = 1
            
            videoPlayer.pause()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playVideo(){
        self.videoPlayer.seek(to: CMTime.zero)
        isPlaying = true
        self.videoPlayer.play()
    }
    

    func stopVideo(){
        self.videoPlayer.seek(to: CMTime.zero)
        isPlaying = false
        self.videoPlayer.pause()
        
    }
    
}
