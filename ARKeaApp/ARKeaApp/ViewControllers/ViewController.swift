//
//  ViewController.swift
//  ARKeaApp
//
//  Created by Rathod on 7/23/20.
//  Copyright © 2020 Rathod. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

struct ARAppState {
  static let detectPlane = 0  //Scan playable surface (Plane Detection On)
  static let pointToSurface = 1 //Point to surface to see focus point (Plane Detection Off)
  static let readyToPlaceObject = 2 //We are ready to play
}

class ViewController: UIViewController, Storyboarded {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var joyStickControls: SKView! {
        didSet {
            joyStickControls.isMultipleTouchEnabled = true
            joyStickControls.backgroundColor = .clear
            joyStickControls.isHidden = true
        }
    }
    
    var objectType: String = ""
    
    var arAppState: Int = ARAppState.detectPlane
    var targetPoint: CGPoint!
    
    var objectScene: SCNScene!
    
    var objectNode: SCNNode!
    var targetNode: SCNNode!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConfiguaration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = false
//        sceneView.debugOptions = [.showBoundingBoxes]
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        targetPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.25)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("moveObject"), object: nil, queue: OperationQueue.main) {[weak self] (notification) in
            guard let userInfo = notification.userInfo,
                let selfObj = self else { return }
            
            let data = userInfo["data"] as! AnalogJoystick
            
            selfObj.objectNode.position.x = selfObj.objectNode.position.x + Float(data.velocity.x * 0.0005)
            selfObj.objectNode.position.y = selfObj.objectNode.position.y + Float(data.velocity.y * 0.0005)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("rotateObject"), object: nil, queue: OperationQueue.main) {[weak self] (notification) in
            guard let userInfo = notification.userInfo else { return }
            let data = userInfo["data"] as! AnalogJoystick
            
            self?.objectNode.eulerAngles.y = Float(data.angular) + Float(180.0.degreesToRadians)
        }
        
        registerGestureRecognizers()
    }

    func setupConfiguaration() {
        guard ARWorldTrackingConfiguration.isSupported else {
          print("World Configuration is Not Supported")
          return
        }
        
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.planeDetection = [.horizontal]
        config.isLightEstimationEnabled = true
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
//        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotate))
//        longPressGestureRecognizer.minimumPressDuration = 0.1
//        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        initSceneNodes()
    }
    
    func initSceneNodes() {
        if let targetScene = SCNScene(named: "art.scnassets/Scenes/Target.scn") {
            targetNode = targetScene.rootNode.childNode(withName: "target", recursively: false)
            targetNode.scale = SCNVector3(0.1, 0, 0.1)
            targetNode.isHidden = true
            targetNode.name = "Target"
            sceneView.scene.rootNode.addChildNode(targetNode)
        }
        
        if objectType == "Chairs" {
            objectScene = SCNScene(named: "art.scnassets/Scenes/Chair.scn")
            objectNode = objectScene?.rootNode.childNode(withName: "chair", recursively: false)
        } else {
            objectScene = SCNScene(named: "art.scnassets/Scenes/Table.scn")
            objectNode = objectScene?.rootNode.childNode(withName: "table", recursively: false)
        }
        
        objectNode.name = objectType
        setupJoyStickView()
    }
    
    func setupJoyStickView() {
        let joyStickScene = JoyStickScene(size: CGSize(width: view.bounds.size.width, height: 180))
        joyStickScene.scaleMode = .resizeFill
        joyStickControls.presentScene(joyStickScene)
        joyStickControls.ignoresSiblingOrder = true
    }
    
    func createPlaneNode(node: SCNNode, anchor: ARPlaneAnchor) {
        
        self.removePlaneNode(node: node)
        
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        plane.materials.first?.diffuse.contents = UIColor.clear
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.name = "HorizontalPlane"
        planeNode.position = SCNVector3(anchor.center.x, -0.001, anchor.center.z)
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.eulerAngles.x = -.pi / 2
        node.addChildNode(planeNode)
    }
    
    func removePlaneNode(node: SCNNode) {
        node.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
    
    func placeObjectOnPlane(location: ARHitTestResult) {
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "Chairs" || node.name == "Tables" {
                node.removeFromParentNode()
            }
        }
        
        let transform = location.worldTransform.columns.3
        objectNode.position = SCNVector3(transform.x, transform.y, transform.z)
        
        if let chair = objectNode {
            centerPivot(for: chair)
            targetNode.isHidden = true
            joyStickControls.isHidden = false
            sceneView.scene.rootNode.addChildNode(chair)
        }
    }
    
    func updateTargetNode() {
        let results = self.sceneView.hitTest(self.targetPoint,
                                             types: [.existingPlaneUsingExtent])
        
        if results.count == 1 {
            if let match = results.first {
                let transform = match.worldTransform.columns.3
                self.targetNode.position = SCNVector3(x: transform.x, y: transform.y + 0.01, z: transform.z)
                self.arAppState = ARAppState.readyToPlaceObject
            }
        } else {
            self.arAppState = ARAppState.pointToSurface
        }
    }
    
    func centerPivot(for node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y,
            min.z + (max.z - min.z)/2
        )
    }
    
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.createPlaneNode(node: node, anchor: planeAnchor)
        }
        
        if self.targetNode.isHidden {
          self.targetNode.isHidden = false
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count > 0 {
            DispatchQueue.main.async {
                self.createPlaneNode(node: node, anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }
        
        DispatchQueue.main.async {
            self.removePlaneNode(node: node)
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateTargetNode()
        }
    }
}

extension ViewController {
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        
        guard let hitTest = self.sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent).first,
            let anchor = hitTest.anchor as? ARPlaneAnchor else { return }
        
        if anchor.alignment == .horizontal {
            placeObjectOnPlane(location: hitTest)
        }
    }
    
    @objc func pinched(sender: UIPinchGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        
        if !hitTest.isEmpty {
            let results = hitTest.first!
            let node = results.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            //print(sender.scale)
            node.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
//    @objc func rotate(sender: UILongPressGestureRecognizer) {
//        let sceneView = sender.view as! ARSCNView
//        let holdLocation = sender.location(in: sceneView)
//        let hitTest = sceneView.hitTest(holdLocation)
//        if !hitTest.isEmpty {
//            let result = hitTest.first!
//            if sender.state == .began {
//                let rotation = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 3.0)
//                let forever = SCNAction.repeatForever(rotation)
//                result.node.runAction(forever)
//                print("holding")
//            } else if sender.state == .ended {
//                result.node.removeAllActions()
//            }
//        }
//    }
}

extension FloatingPoint {
  var degreesToRadians: Self { return self * .pi / 180 }
  var radiansToDegrees: Self { return self * 180 / .pi }
}
