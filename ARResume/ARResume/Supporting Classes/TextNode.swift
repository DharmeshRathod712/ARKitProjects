//
//  TextNode.swift
//  ARImageTrackingWithText
//
//  Created by Rathod on 7/22/20.
//  Copyright © 2020 Rathod. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

class TextNode: SCNNode {
    
    var text: SCNText!
    
    init(_ str: String, _ font: UIFont, maxWidth: Int? = nil, _ txtColor: UIColor = UIColor.white) {
        super.init()
        
        text = SCNText(string: str, extrusionDepth: 0.5)
        text.firstMaterial?.diffuse.contents = txtColor
        text.firstMaterial?.transparency = 0.9
        
        text.flatness = 0.1
        text.font = font
        
        if let maxWidth = maxWidth {
            text.containerFrame = CGRect(origin: .zero,
                                         size: CGSize(width: maxWidth,
                                                      height: 500))
            text.isWrapped = true
        }
        
        self.geometry = text
        self.scale = SCNVector3(0.001, 0.001, 0.001)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
