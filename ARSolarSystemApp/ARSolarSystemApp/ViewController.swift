//
//  ViewController.swift
//  ARBallApp
//
//  Created by Rathod on 6/26/20.
//  Copyright © 2020 Rathod. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
        
        addPlanets()
        
    }
    
    func addPlanets() {
        
        //MARK: Sun Settings
        let sun = SCNSphere(radius: 0.325)
        let sunMaterial = SCNMaterial()
        sunMaterial.diffuse.contents = UIImage(named: "art.scnassets/sun.jpg")
        sun.materials = [sunMaterial]
        
        let nodeSun = SCNNode()
        nodeSun.position = SCNVector3(0, 0, -1)
        nodeSun.geometry = sun
        sceneView.scene.rootNode.addChildNode(nodeSun)
        
        //MARK: Earth Settings
        let earthParentNode = SCNNode()
        earthParentNode.position = SCNVector3(0, 0, -1)
        sceneView.scene.rootNode.addChildNode(earthParentNode)
        
        let parentRotaion = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 20)
        let parentRotationRepeat = SCNAction.repeatForever(parentRotaion)
        earthParentNode.runAction(parentRotationRepeat)
        
        let earth = SCNSphere(radius: 0.12)
        let earthMaterial = SCNMaterial()
        earthMaterial.diffuse.contents = UIImage(named: "art.scnassets/earthday.jpg")
        earth.materials = [earthMaterial]
        
        let nodeEarth = SCNNode()
        nodeEarth.position = SCNVector3(1, 0, 0)
        nodeEarth.geometry = earth
        let earthRotaion = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 8)
        let earthRotaionRepeat = SCNAction.repeatForever(earthRotaion)
        nodeEarth.runAction(earthRotaionRepeat)
        earthParentNode.addChildNode(nodeEarth)
        
        //MARK: Moon Settings
        let moonParentNode = SCNNode()
        moonParentNode.position = SCNVector3(1, 0, 0)
        //sceneView.scene.rootNode.addChildNode(moonParentNode)
        let moonParentRotaion = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 5)
        let moonParentRotationRepeat = SCNAction.repeatForever(moonParentRotaion)
        moonParentNode.runAction(moonParentRotationRepeat)
        
        let moon = SCNSphere(radius: 0.05)
        let moonMaterial = SCNMaterial()
        moonMaterial.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
        moon.materials = [moonMaterial]
        
        let nodeMoon = SCNNode()
        nodeMoon.position = SCNVector3(0, 0, -0.3)
        nodeMoon.geometry = moon
        let moonRotaion = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 8)
        let moonRotaionRepeat = SCNAction.repeatForever(moonRotaion)
        nodeMoon.runAction(moonRotaionRepeat)
        moonParentNode.addChildNode(nodeMoon)
        earthParentNode.addChildNode(moonParentNode)
    }
    
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
