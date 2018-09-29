//
//  ViewController.swift
//  AR KIT tutorial
//
//  Created by Karthik Nayak, Deavin Hester, Dagmawi Nadew, Yacob Alemneh on 8/30/18.
//  Copyright © 2018 Team - eye_Ohh_ess. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var resetButton: UIButton!
    
    var prevLocation = CGPoint(x: 0, y: 0)      // variable to capute prev location
    var shipPlaced = false                      // bool to lock only one ship in the scene
    
    /*
     This function removes all objects (nodes) placed in the scene
     */
    @IBAction func resetTapped(_ sender: Any) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        shipPlaced = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGestureToSceneView()      // long press gesture with 0 delay to take advantage of release gensture
        configureLighting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal                  // this tells sceneView to detect horizontal planes
        
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    /*
     This function takes in a scene tap location co-ordinates and adds a box node to the scene
     */
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x, y, z)
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    /*
     This function is called when the tap gesture is activated
     */
    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        let tapLocation = recognizer.location(in: sceneView)
        
        if prevLocation != tapLocation && !shipPlaced {
            
            prevLocation = tapLocation      // set current tap location to prev
            resetTapped(0)                  // simulate reset button to remove prev objects
            
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            
            addBox(x: translation.x, y: translation.y, z: translation.z)       // add a box to current location to "preview" ship placement
        }
        
        if (recognizer.state == UIGestureRecognizerState.ended) && !shipPlaced {               // when tap is release we want to place the ship
            resetTapped(0)                                                                     // simulate reset button to remove box node
            
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            
            guard let shipScene = SCNScene(named: "ship.scn"),
                let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: false)
                else { return }
            
            shipNode.position = SCNVector3(x: translation.x, y: translation.y, z: translation.z)
            sceneView.scene.rootNode.addChildNode(shipNode)
            shipPlaced = true
        }
        
    }
    
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.addShipToSceneView(withGestureRecognizer:)))
        tapGestureRecognizer.minimumPressDuration = 0
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // We safely unwrap the anchor argument as an ARPlaneAnchor to get information the flat surface at hand.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // creating an SCNPlane to visualize the ARPlaneAnchor
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // assigning a color to our detected plane
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        // SCNNode with the SCNPlane geometry we just created.
        let planeNode = SCNNode(geometry: plane)
        
        // getting a position for out plane to be places
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // adding the planeNode as the child node onto the newly added SceneKit node.
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // unwraping the anchor argument as ARPlaneAnchor, the node’s first child node, and the planeNode’s geometry as SCNPlane
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // we update the plane’s width and height using the planeAnchor extent’s x and z properties.
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // updatong the planeNode’s position
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}
