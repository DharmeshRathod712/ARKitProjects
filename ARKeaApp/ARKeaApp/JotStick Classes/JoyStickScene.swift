//
//  JoyStickScene.swift
//  ARKeaApp
//
//  Created by Rathod on 7/26/20.
//  Copyright © 2020 Rathod. All rights reserved.
//

import SpriteKit

class JoyStickScene: SKScene {
    
    let setJoystickStickImageBtn = SKLabelNode()
    let setJoystickSubstrateImageBtn = SKLabelNode()
    
    enum NodesZPosition: CGFloat {
        case joystick
    }
    
    weak var moveJoyStick: AnalogJoystick? = {
        //let js = AnalogJoystick(diameter: 100, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        let js = AnalogJoystick(withBase: AnalogJoystickComponent.init(diameter: 100, color: nil, image: #imageLiteral(resourceName: "jSubstrate")),
                                handle: AnalogJoystickComponent.init(diameter: 100, color: nil, image: #imageLiteral(resourceName: "jStick")))
        js.position = CGPoint(x: js.radius + 45, y: js.radius + 45)
        js.zPosition = NodesZPosition.joystick.rawValue
        return js
    }()
    
    weak var rotateJoyStick: AnalogJoystick? = {
        let js = AnalogJoystick(withBase: AnalogJoystickComponent.init(diameter: 70, color: nil, image: #imageLiteral(resourceName: "jSubstrate")),
                                handle: AnalogJoystickComponent.init(diameter: 70, color: nil, image: #imageLiteral(resourceName: "jStick")))
        js.position = CGPoint(x: js.radius + 45, y: js.radius + 45)
        js.zPosition = NodesZPosition.joystick.rawValue
        return js
    }()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        let moveJoystickHiddenArea = AnalogJoystickHiddenArea(rect: CGRect(x: 0, y: 0, width: frame.midX, height: frame.height))
        moveJoystickHiddenArea.joystick = moveJoyStick
        moveJoystickHiddenArea.strokeColor = .clear
        moveJoyStick?.isMoveable = false
        addChild(moveJoystickHiddenArea)
        
        let rotateJoystickHiddenArea = AnalogJoystickHiddenArea(rect: CGRect(x: frame.midX, y: 0, width: frame.midX, height: frame.height))
        rotateJoystickHiddenArea.joystick = rotateJoyStick
        rotateJoystickHiddenArea.strokeColor = .clear
        rotateJoyStick?.isMoveable = false
        addChild(rotateJoystickHiddenArea)
        
        let btnsOffset: CGFloat = 10
        let btnsOffsetHalf = btnsOffset / 2
        let startLabelY = CGFloat(40)
        
        setJoystickStickImageBtn.fontColor = UIColor.black
        setJoystickStickImageBtn.fontSize = 20
        setJoystickStickImageBtn.verticalAlignmentMode = .bottom
        setJoystickStickImageBtn.position = CGPoint(x: frame.midX, y: startLabelY - btnsOffsetHalf)
        addChild(setJoystickStickImageBtn)
        
        setJoystickSubstrateImageBtn.fontColor  = UIColor.black
        setJoystickSubstrateImageBtn.fontSize = 20
        setJoystickStickImageBtn.verticalAlignmentMode = .top
        setJoystickSubstrateImageBtn.position = CGPoint(x: frame.midX, y: startLabelY + btnsOffsetHalf)
        addChild(setJoystickSubstrateImageBtn)
        
        view.isMultipleTouchEnabled = true
        
        setupNodes()
        setupJoystick()
    }
    
    func setupNodes() {
        anchorPoint = CGPoint(x: 0.0, y: 0.0)
    }
    
    func setupJoystick() {
        
        moveJoyStick?.on(.move) { joystick in
//            print("joystick: == \(joystick)")
            NotificationCenter.default.post(name: NSNotification.Name("moveObject"), object: nil, userInfo: ["data": joystick])
        }
        
        rotateJoyStick?.on(.move) { joystick in
            NotificationCenter.default.post(name: NSNotification.Name("rotateObject"), object: nil, userInfo: ["data": joystick])
        }
        
    }
    
}
