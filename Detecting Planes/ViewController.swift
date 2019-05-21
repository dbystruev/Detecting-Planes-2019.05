//
//  ViewController.swift
//  Detecting Planes
//
//  Created by Denis Bystruev on 21/05/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add world origin and feature points
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable plane detection
        configuration.planeDetection = [.horizontal]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let floor = createFloor(planeAnchor: planeAnchor)
        node.addChildNode(floor)
        
        let ship = createShip(planeAnchor: planeAnchor)
        node.addChildNode(ship)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        guard let planeNode = node.childNodes.first else { return }
        guard let plane = planeNode.geometry as? SCNPlane else { return }
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
        
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
    }
    
    /// Creates and returns horizontal plane
    ///
    /// - Parameter planeAnchor: ARPlaneAncchor for the plane
    /// - Returns: SCNNode for created plane
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let extent = planeAnchor.extent
        let width = CGFloat(extent.x)
        let height = CGFloat(extent.z)
        
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        
        let node = SCNNode(geometry: plane)
        node.eulerAngles.x = -.pi / 2
        node.opacity = 0.125
        
        return node
    }
    
    /// Create and return an SCNNode for ship
    ///
    /// - Parameter planeAnchor: plane anchor to place ship on
    /// - Returns: SCNNode created
    func createShip(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.clone()
        
        node.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        node.scale = SCNVector3(0.1, 0.1, 0.1)
        
        return node
    }
    
}
