//
//  XylophonSceneController.swift
//  Book_Sources
//
//  Created by Renata Faria on 16/03/19.
//

import UIKit
import ARKit
import AVFoundation
import PlaygroundSupport

@objc(Book_Sources_XylophonSceneController)
public class XylophonSceneController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer, ARSCNViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var resizeButton: UIButton!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var moveButton: UIButton!
    // MARK: - Views from staff
    @IBOutlet weak var doMenor: UIView!
    @IBOutlet weak var re: UIView!
    @IBOutlet weak var mi: UIView!
    @IBOutlet weak var fa: UIView!
    @IBOutlet weak var sol: UIView!
    @IBOutlet weak var la: UIView!
    @IBOutlet weak var si: UIView!
    @IBOutlet weak var doMaior: UIView!
    @IBOutlet weak var staff: UIImageView!
    @IBOutlet weak var music: UIImageView!
    
    // MARK: - Variables
    var xylophonNode: SCNNode!
    var planes = [ARPlaneAnchor: Plane]()
    var currentAngleY: Float = 0.0 //for pan gesture
    var isEditingShape = false
    var player: AVAudioPlayer?
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: - Actions with outlets
    @IBAction func finishedButtonClicked(_ sender: UIButton) {
        setAllPlanes(hide: true)
        if !self.isEditingShape {
            guard let image = UIImage(named: "done") else { return }
            sender.setImage(image, for: .normal )
            resizeButton.isHidden = false
            rotateButton.isHidden = false
            moveButton.isHidden = false
            resetButton.isHidden = true
            self.staff.isHidden = true
            self.music.isHidden = true
            self.isEditingShape = true
        } else {
            guard let image = UIImage(named: "edit") else { return }
            sender.setImage(image, for: .normal )
            self.removeGestures()
            resizeButton.isHidden = true
            rotateButton.isHidden = true
            moveButton.isHidden = true
            resetButton.isHidden = false
            self.staff.isHidden = false
            self.music.isHidden = false
            self.isEditingShape = false
        }
    }
    @IBAction func resetButtonClicked(_ sender: UIButton) {
        self.xylophonNode.removeFromParentNode()
        self.removeGestures()
        self.removeGestures()
        self.finishButton.isHidden = true
        self.staff.isHidden = true
        self.music.isHidden = true
        setAllPlanes(hide: false)
    }
    @IBAction func rotateButtonClicked(_ sender: UIButton) {
        resizeButton.isHidden = false
        moveButton.isHidden = false
        rotateButton.isHidden = true
        setAllPlanes(hide: true)
        self.removeGestures()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        sceneView.addGestureRecognizer(panGesture)
    }
    @IBAction func resizeButtonClicked(_ sender: Any) {
        resizeButton.isHidden = true
        moveButton.isHidden = false
        rotateButton.isHidden = false
        setAllPlanes(hide: true)
        self.removeGestures()
        setAllPlanes(hide: true)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
    }
    @IBAction func moveButtonClicked(_ sender: UIButton) {
        resizeButton.isHidden = false
        moveButton.isHidden = true
        rotateButton.isHidden = false
        setAllPlanes(hide: false)
        self.removeGestures()
        let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(didMove(_:)))
        sceneView.addGestureRecognizer(moveGesture)
    }
    
    // MARK: - Actions without outlets
    func configureArScene() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        view.addSubview(sceneView)
        view.sendSubviewToBack(sceneView)
        sceneView.delegate = self
    }
    func configureButtons() {
        let buttons = [moveButton, resetButton, finishButton, rotateButton, resizeButton]
        for button in buttons {
            button?.imageView?.contentMode = .scaleAspectFit
        }
    }
    func setAllPlanes(hide: Bool) {
        for plane in planes.values {
            plane.setPlaneVisibility(hide)
        }
    }
    func removeGestures() {
        if let gestures = self.sceneView?.gestureRecognizers{
            for gesture in gestures {
                self.sceneView.removeGestureRecognizer(gesture)
            }
        }
    }
    func detectTouch(_ touch: UITouch) {
        if(touch.view == self.sceneView){
            let viewTouchLocation:CGPoint = touch.location(in: sceneView)
            guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {
                return
            }
            if let resultName = result.node.name {
                guard let url = Bundle.main.url(forResource: resultName, withExtension: "wav") else { return }
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)
                    player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                    guard let player = player else { return }
                    self.setViewVisible(resultName)
                    print(resultName)
                    player.play()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
        }
    }
    func setViewVisible(_ name: String) {
        self.setAllNoteViewsHidden()
        switch name {
        case "do-maior": doMaior.isHidden = false; break
        case "re": re.isHidden = false; break
        case "mi": mi.isHidden = false; break
        case "fa": fa.isHidden = false; break
        case "la": la.isHidden = false; break
        case "si": si.isHidden = false; break
        case "sol": sol.isHidden = false; break
        case "do-menor": doMenor.isHidden = false; break
        default: break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setAllNoteViewsHidden()
        }
    }
    func setAllNoteViewsHidden() {
        self.doMenor.isHidden = true
        self.re.isHidden = true
        self.mi.isHidden = true
        self.fa.isHidden = true
        self.sol.isHidden = true
        self.la.isHidden = true
        self.si.isHidden = true
        self.doMaior.isHidden = true
    }
    func createNode(_ touch: UITouch) {
        let tapLocation: CGPoint = touch.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.columns.3
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        xylophonNode.position = SCNVector3(x,y,z)
        sceneView.scene.rootNode.addChildNode(xylophonNode)
        self.setAllPlanes(hide: true)
        self.configureButtons()
    }
    
    // MARK: - Gesture Selectors
    @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
        guard let _ = xylophonNode else { return }
        var originalScale = xylophonNode?.scale
        switch gesture.state {
        case .began:
            originalScale = xylophonNode?.scale
            gesture.scale = CGFloat((xylophonNode?.scale.x)!)
        case .changed:
            guard var newScale = originalScale else { return }
            if gesture.scale < 0.5{ newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5) }else if gesture.scale > 2{
                newScale = SCNVector3(2, 2, 2)
            } else {
                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
            }
            xylophonNode?.scale = newScale
        case .ended:
            guard var newScale = originalScale else { return }
            if gesture.scale < 0.5{ newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5) } else if gesture.scale > 2{
                newScale = SCNVector3(2, 2, 2)
            } else{
                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
            }
            xylophonNode?.scale = newScale
            gesture.scale = CGFloat((xylophonNode?.scale.x)!)
        default:
            gesture.scale = 1.0
            originalScale = nil
        }
    }
    @objc func didPan(_ gesture: UIPanGestureRecognizer) {
        guard let _ = self.xylophonNode else { return }
        let translation = gesture.translation(in: gesture.view)
        var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
        
        newAngleY += currentAngleY
        xylophonNode?.eulerAngles.y = newAngleY
        
        if gesture.state == .ended{
            currentAngleY = newAngleY
        }
    }
    @objc func didMove(_ gesture: UIPanGestureRecognizer) {
        guard let _ = self.xylophonNode else { return }
        let point = gesture.location(in: self.sceneView)
        let result = sceneView.hitTest(point, options: nil)
        guard let resultPoint = result.first else { return }
        if let resultName = resultPoint.node.name {
            let allViews = [
                "do-maior", "do-menor", "baseWWDC",
                "re", "mi", "fa","sol", "la", "si"]
            if allViews.contains(resultName) {
                let arhitResult = sceneView.hitTest(point, types: .featurePoint)
                guard let arpoint = arhitResult.first else { return }
                let position = SCNVector3(
                    Float(arpoint.worldTransform.columns.3.x),
                    xylophonNode.position.y,
                    Float(arpoint.worldTransform.columns.3.z))
                xylophonNode.position = position
            }
        }
    }
    // MARK: - View Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.configureArScene()
        xylophonNode = SCNNode(named: "xylophon.scn")
        self.configureButtons()
    }
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureArScene()
        
    }
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if self.finishButton.isHidden {
            self.createNode(touch)
            self.staff.isHidden = false
            self.music.isHidden = false
            self.finishButton.isHidden = false
        } else if !isEditingShape {
            self.detectTouch(touch)
        }
    }
    // MARK: - Plane functions
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        let plane = Plane(anchor)
        node.addChildNode(plane)
        planes[anchor] = plane
    }
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.addPlane(node: node, anchor: planeAnchor)
                self.feedbackGenerator.impactOccurred()
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
            }
        }
    }
}


extension SCNNode {
    convenience init(named name: String) {
        self.init()
        
        guard let scene = SCNScene(named: name) else {
            return
        }
        
        for childNode in scene.rootNode.childNodes {
            addChildNode(childNode)
        }
    }
    
}
