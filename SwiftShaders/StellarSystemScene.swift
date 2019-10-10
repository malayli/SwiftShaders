import SceneKit

final class StellarSystemScene: SCNScene {
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init () {
        super.init()
        
        rootNode.castsShadow = false
        
        // Content Node
        
        let contentNode = SCNNode()
        contentNode.castsShadow = false
        rootNode.addChildNode(contentNode)
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(-6, 3, 0), shaders: [.surface: simpleHalfColoringFromScreenSizeSurfaceShader]))
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(-3, 3, 0), shaders: [.surface: simpleHalfColoringSurfaceShader]))
        
        let borgNode = cubeNode(position: SCNVector3(0, 3, 0), shaders: [.fragment: appearingFragmentShader])
        borgNode.addRevealAnimation()
        contentNode.addChildNode(borgNode)
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(3, 3, 0), shaders: [.surface: coloringSurfaceShader]))
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(6, 3, 0), shaders: [.geometry: twistingGeometryShader]))
    }
}

private extension StellarSystemScene {
    private func cubeNode(position p: SCNVector3, shaders: [SCNShaderModifierEntryPoint: String]) -> SCNNode {
        let node = SCNNode()
        node.castsShadow = false
        node.position = p
        node.geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.shaderModifiers = shaders
        material.lightingModel = .constant
        node.geometry?.materials = [material]
        
        return node
    }
}

private extension SCNNode {
    func addAnimation(beginTime: CFTimeInterval = 0.0, duration: CFTimeInterval, from: NSValue, to: NSValue, key: String) {
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.beginTime = beginTime
        animation.duration = duration
        animation.fromValue = from
        animation.toValue = to
        animation.repeatCount = .greatestFiniteMagnitude
        addAnimation(animation, forKey: key)
    }
    
    func addRevealAnimation() {
        if let noiseImage = UIImage(named: "noise") {
            geometry?.firstMaterial?.setValue(SCNMaterialProperty(contents: noiseImage), forKey: "noiseTexture")
        }
        
        let revealAnimation = CABasicAnimation(keyPath: "revealage")
        revealAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        revealAnimation.beginTime = CACurrentMediaTime() + 5
        revealAnimation.duration = 2.5
        revealAnimation.fromValue = 0.0
        revealAnimation.toValue = 1.0
        revealAnimation.fillMode = .forwards
        revealAnimation.isRemovedOnCompletion = false
        
        let scnRevealAnimation = SCNAnimation(caAnimation: revealAnimation)
        geometry?.firstMaterial?.addAnimation(scnRevealAnimation, forKey: "Reveal")
    }
}
