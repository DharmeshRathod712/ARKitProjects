//
//  ViewController.swift
//  ARImageTrackingWithText
//
//  Created by Rathod on 7/17/20.
//  Copyright © 2020 Rathod. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, Storyboarded {

    @IBOutlet var sceneView: ARSCNView!
    
    let configuration = ARImageTrackingConfiguration()
    
    var myData = [String: DataSet]()
    var objectNodes = [SCNNode]()
    var heartNode: SCNNode?
    var diamondNode: SCNNode?
    var playButtonNode = SCNNode()
    
    var videoPlayerNode: VideoNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        readData()
        
        let heartScene = SCNScene(named: "art.scnassets/Heart.scn")
        
        heartNode = heartScene?.rootNode
        diamondNode = SCNNode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        videoPlayerNode?.videoPlayer.volume = 0
        objectNodes = []
        
        setupSession()
    }
    
    //MARK:- Every time view appears remove all the nodes and anchors from the screen and run the configuration again
    func setupSession() {
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Card", bundle: Bundle.main) else {
            fatalError("Can not find referance image")
        }
        
        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 3
        
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        videoPlayerNode?.videoPlayer.pause()
        
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: self.sceneView),
            let hitTest = self.sceneView.hitTest(touchLocation, options: nil).first else { return }
        switch hitTest.node.name {
        case NodeName.play.rawValue,
             NodeName.plane.rawValue:
            if playButtonNode.isHidden {
                videoPlayerNode?.stopVideo()
                playButtonNode.isHidden = false
            } else {
                videoPlayerNode?.playVideo()
                playButtonNode.isHidden = true
            }
        case NodeName.githubId.rawValue:
            openWebPage(urlStr: "https://github.com/DharmeshRathod712")
        case NodeName.linkedInId.rawValue:
            openWebPage(urlStr: "https://www.linkedin.com/in/dharmeshrathod712/")
        case NodeName.twitterId.rawValue:
            openWebPage(urlStr: "https://twitter.com/DharmeshRathod_")
        default:
            break
        }
    }
    
    func openWebPage(urlStr: String) {
        let webVC = WebViewVC.instantiate()
        webVC.urlString = urlStr
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    func readData() {
        guard let url = Bundle.main.url(forResource: "DataSet", withExtension: "json") else {
            fatalError("Unable to find json File")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to load json")
        }
        
        let decoder = JSONDecoder()
        
        guard let loadMyData = try? decoder.decode([String: DataSet].self, from: data) else {
            fatalError("JSON parse error")
        }
        
        myData = loadMyData
    }
    
    func fadeOut(node: SCNNode, duration: Double = 1) {
        if node.name == "king" {
            let action = SCNAction.fadeOut(duration: duration)
            node.runAction(action)
        }
    }
    
    func fadeIn(node: SCNNode) {
        if node.name == "king" {
            let action = SCNAction.fadeIn(duration: 1)
            node.runAction(action)
        }
    }
    
    func addShapeNodes(wrapperNode: SCNNode, imgName: String) {
        var shapeNode: SCNNode?
        if imgName == "king" {
            shapeNode = heartNode
        } else if imgName == "queen" {
            shapeNode = diamondNode
        }
        
        let spin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)
        let repeatCount = SCNAction.repeatForever(spin)
        shapeNode?.runAction(repeatCount)
        
        if let shape = shapeNode {
            shape.name = imgName
            fadeOut(node: shape, duration: 0)
            wrapperNode.addChildNode(shape)
            objectNodes.append(wrapperNode)
        }
    }
}

//MARK: -  Delegate Methods
extension ViewController {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imgAnchor = anchor as? ARImageAnchor else { return nil }
        guard let name = imgAnchor.referenceImage.name else { return nil }
        
        let physicalSize = imgAnchor.referenceImage.physicalSize
        
        let wrapperNode = SCNNode()
        
        addShapeNodes(wrapperNode: wrapperNode, imgName: name)
    
        
        if let myData = myData[name] {
            
            let plane = SCNPlane(width: physicalSize.width, height: physicalSize.height)
            plane.cornerRadius = 0.005
            plane.firstMaterial?.diffuse.contents = UIColor.clear
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.name = "planeNode"
            planeNode.eulerAngles.x = -.pi / 2
            
            videoPlayerNode = VideoNode(plane: plane)
            videoPlayerNode?.eulerAngles.x = -.pi / 2
            planeNode.addChildNode(videoPlayerNode!)
            
            wrapperNode.addChildNode(planeNode)
            
            //MARK:- Play Button Node
            let playButtonPlane = SCNPlane(width: 0.015875, height: 0.015875)
            playButtonPlane.firstMaterial?.diffuse.contents = UIImage(named: "play")
            playButtonNode = SCNNode(geometry: playButtonPlane)
            playButtonNode.name = "Play"
            playButtonNode.position = planeNode.position
            playButtonNode.position.z = 0.001
            playButtonNode.isHidden = false
            planeNode.addChildNode(playButtonNode)
            
            let hSpacing: Float = 0.005
            let vSpacing: Float = 0.007
            //MARK:- Name Node
            let titleNode = TextNode(myData.name, UIFont.boldSystemFont(ofSize: 11), UIColor(red: 27/255, green: 99/255, blue: 186/255, alpha: 1.0))
            titleNode.name = "MyName"
            titleNode.pivotOnTopLeft()
            titleNode.position.x += Float(plane.width / 2) + hSpacing
            titleNode.position.y += Float(plane.height / 2)
            planeNode.addChildNode(titleNode)
            
            //MARK:- Qualification Node
            let qualificationNode = TextNode(myData.education, UIFont.systemFont(ofSize: 7, weight: .semibold), UIColor.white)
            qualificationNode.name = "Qualificaton"
            qualificationNode.pivotOnTopLeft()
            qualificationNode.position.x += Float(plane.width / 2) + hSpacing
            qualificationNode.position.y = titleNode.position.y - titleNode.height - vSpacing
            planeNode.addChildNode(qualificationNode)
            
            //MARK:- Profession/ Job Profile Node
            let jobProfileNode = TextNode(myData.profession, UIFont.systemFont(ofSize: 7, weight: .semibold), UIColor.white)
            jobProfileNode.name = "Profile"
            jobProfileNode.pivotOnTopLeft()
            jobProfileNode.position.x += Float(plane.width / 2) + hSpacing
            jobProfileNode.position.y = qualificationNode.position.y - qualificationNode.height - vSpacing
            planeNode.addChildNode(jobProfileNode)
            
            //MARK:- Country Node
            let countryNode = TextNode(myData.country, UIFont.systemFont(ofSize: 7, weight: .semibold), UIColor.white)
            countryNode.name = "Country"
            countryNode.pivotOnTopLeft()
            countryNode.position.x += Float(plane.width / 2) + hSpacing
            countryNode.position.y = jobProfileNode.position.y - jobProfileNode.height - vSpacing
            planeNode.addChildNode(countryNode)
            
            //MARK:- GitHub Profile Node
            
            let gitPlane = SCNPlane(width: 0.015875, height: 0.015875)
            gitPlane.firstMaterial?.diffuse.contents = UIImage(named: "GitHub")
            let gitNode = SCNNode(geometry: gitPlane)
            gitNode.name = "GithubId"
            gitNode.pivotOnTopCenter()
            gitNode.position.x -= Float(plane.width / 2) - Float(gitPlane.width / 2)
            gitNode.position.y -= Float(plane.height / 2) + hSpacing
            //countryNode.position.y - countryNode.height - vSpacing
            planeNode.addChildNode(gitNode)
            
            //MARK:- LinkedIn Profile Node
            let likedInPlane = SCNPlane(width: 0.015875, height: 0.015875)
            likedInPlane.firstMaterial?.diffuse.contents = UIImage(named: "LinkedIn")
            let likedInNode = SCNNode(geometry: likedInPlane)
            likedInNode.name = "LinkedInId"
            likedInNode.pivotOnTopCenter()
            //likedInNode.position.x += Float(plane.width / 2) + Float(gitPlane.width) + (hSpacing * 2)
            likedInNode.position.y -= Float(plane.height / 2) + hSpacing
            //countryNode.position.y - countryNode.height - vSpacing
            planeNode.addChildNode(likedInNode)
            
            //MARK:- Twitter Profile Node
            let twitterPlane = SCNPlane(width: 0.015875, height: 0.015875)
            twitterPlane.firstMaterial?.diffuse.contents = UIImage(named: "Twitter")
            let twitterNode = SCNNode(geometry: twitterPlane)
            twitterNode.name = "TwitterId"
            twitterNode.pivotOnTopCenter()
            twitterNode.position.x += Float(plane.width / 2) - Float(twitterPlane.width / 2)
            //Float(plane.width / 2) + Float(gitPlane.width * 2) + (hSpacing * 3)
            twitterNode.position.y -= Float(plane.height / 2) + hSpacing
            //countryNode.position.y - countryNode.height - vSpacing
            planeNode.addChildNode(twitterNode)
        }

        return wrapperNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if node.isHidden == true {
            videoPlayerNode?.stopVideo()
            playButtonNode.isHidden = false
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if objectNodes.count == 2 {
            let posiOne = SCNVector3ToGLKVector3(objectNodes[0].position)
            let posiTwo = SCNVector3ToGLKVector3(objectNodes[1].position)
            let position = GLKVector3Distance(posiOne, posiTwo)
            
            for node in objectNodes {
                node.enumerateChildNodes { (node, _) in
                    if node.name == "king" {
                        if position < 0.10 {
                            fadeIn(node: node)
                        } else {
                            fadeOut(node: node)
                        }
                    }
                }
            }
        }
    }
    
}

