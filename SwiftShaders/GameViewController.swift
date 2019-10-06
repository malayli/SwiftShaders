import UIKit
import SpriteKit
import GameplayKit
import SceneKit

final class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        addScene()
    }
    
    private func addScene() {
        guard let scnView = view as? SCNView else {
            return
        }
        
        scnView.scene = StellarSystemScene() as StellarSystemScene

        let camera = SCNCamera()
        camera.wantsHDR = true
        camera.bloomThreshold = 0.8
        camera.bloomIntensity = 2
        camera.bloomBlurRadius = 16.0
        camera.wantsExposureAdaptation = false
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        cameraNode.camera = camera
        
        scnView.pointOfView = cameraNode
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = true // allows the user to manipulate the camera
        scnView.showsStatistics = true // show statistics such as fps and timing information
        scnView.backgroundColor = .clear
        //scnView.scene?.background.contents = UIImage(named: "galaxy")
        scnView.play(nil)
    }
    
    @IBAction func pause(_ sender: Any?) {
        guard let scnView = view as? SCNView, let scene = scnView.scene else {
            return
        }
        scene.isPaused = !scene.isPaused
    }
    
    func shouldAutorotate() -> Bool {
        return true
    }
    
    func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func supportedInterfaceOrientations() -> Int {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return Int(UIInterfaceOrientationMask.allButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.all.rawValue)
        }
    }
}
