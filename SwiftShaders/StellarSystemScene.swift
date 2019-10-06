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
        
        // Sun-group
        
        let sunGroupNode = SCNNode()
        sunGroupNode.castsShadow = false
        sunGroupNode.position = SCNVector3Make(0, 0, 0)
        sunGroupNode.addChildNode(sunNode)
        sunGroupNode.addChildNode(sunLightNode)
        sunGroupNode.addChildNode(earthRotationNode)
        sunGroupNode.addChildNode(testNode(position: SCNVector3(-3, 3, 0)))
        sunGroupNode.addChildNode(borgNode(position: SCNVector3(-3, -3, 0)))
        sunGroupNode.addChildNode(pyramidNode(position: SCNVector3(3, 3, 0)))
        sunGroupNode.addChildNode(alienNode(position: SCNVector3(3, -3, 0)))
        
        contentNode.addChildNode(sunGroupNode)
    }
}

private extension StellarSystemScene {
    private func testNode(position p: SCNVector3) -> SCNNode {
        let node = SCNNode(geometry: SCNPyramid(width: 1, height: 1, length: 1))
        node.position = p
        
        let shaders: [SCNShaderModifierEntryPoint: String] = [.surface: simpleHalfColoringSurfaceShader]
        
        let material = SCNMaterial()
        material.shaderModifiers = shaders
        material.lightingModel = .constant
        node.geometry?.materials = [material]
        node.castsShadow = false
        return node
    }
    
    private func pyramidNode(position p: SCNVector3) -> SCNNode {
        let node = SCNNode(geometry: SCNPyramid(width: 1, height: 1, length: 1))
        node.position = p
        
        let shaders: [SCNShaderModifierEntryPoint: String] = [.surface: coloringSurfaceShader, .geometry: twistingGeometryShader]
        
        let material = SCNMaterial()
        material.shaderModifiers = shaders
        material.lightingModel = .constant
        node.geometry?.materials = [material]
        
        node.castsShadow = false
        node.addAnimation(duration: 20.0, from: NSValue(scnVector4: SCNVector4Make(0, 1, 0, 0)), to: NSValue(scnVector4: SCNVector4Make(0, 1, 0, Float(Double.pi) * 2.0)), key: "pyramid rotation")
        return node
    }
    
    private func alienNode(position p: SCNVector3) -> SCNNode {
        let node = SCNNode(geometry: SCNTorus(ringRadius: 1, pipeRadius: 0.5))
        node.position = p
        
        let shaders: [SCNShaderModifierEntryPoint: String] = [.geometry: twistingGeometryShader]
        
        let material = SCNMaterial()
        material.shaderModifiers = shaders

        node.geometry?.materials = [material]
        node.castsShadow = false
        node.geometry?.firstMaterial?.lightingModel = .constant
        
        return node
    }
    
    private func borgNode(position p: SCNVector3) -> SCNNode {
        let node = SCNNode()
        node.position = p
        node.geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        
        if let noiseImage = UIImage(named: "noise") {
            node.geometry?.firstMaterial?.setValue(SCNMaterialProperty(contents: noiseImage), forKey: "noiseTexture")
        }
        
        node.geometry?.firstMaterial?.shaderModifiers = [.fragment: appearingFragmentShader]
        
        let revealAnimation = CABasicAnimation(keyPath: "revealage")
        revealAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        revealAnimation.beginTime = CACurrentMediaTime() + 5
        revealAnimation.duration = 2.5
        revealAnimation.fromValue = 0.0
        revealAnimation.toValue = 1.0
        revealAnimation.fillMode = .forwards
        revealAnimation.isRemovedOnCompletion = false
        
        let scnRevealAnimation = SCNAnimation(caAnimation: revealAnimation)
        node.geometry?.firstMaterial?.addAnimation(scnRevealAnimation, forKey: "Reveal")
        
        node.castsShadow = false
        node.geometry?.firstMaterial?.lightingModel = .constant
        node.addAnimation(duration: 20.0, from: NSValue(scnVector4: SCNVector4Make(0, 1, 0, 0)), to: NSValue(scnVector4: SCNVector4Make(0, 1, 0, Float(Double.pi) * 2.0)), key: "borg rotation")
        return node
    }
}

private extension StellarSystemScene {
    private var sunNode: SCNNode {
        let node = SCNNode(radius: 1.5, imageName: "sun")
        node.castsShadow = false
        node.geometry?.firstMaterial?.lightingModel = .constant
        node.addAnimation(duration: 20.0, from: NSValue(scnVector4: SCNVector4Make(0, 1, 0, 0)), to: NSValue(scnVector4: SCNVector4Make(0, 1, 0, Float(Double.pi) * 2.0)), key: "sun rotation")
        return node
    }
    
    private var sunLightNode: SCNNode {
        let sunLightNode = SCNNode()
        sunLightNode.castsShadow = false
        sunLightNode.light = SCNLight()
        sunLightNode.light?.castsShadow = true
        sunLightNode.light?.type = .spot
        sunLightNode.light?.color = UIColor.white
        sunLightNode.light?.spotInnerAngle = 0
        sunLightNode.light?.spotOuterAngle = 90
        sunLightNode.position = SCNVector3(0, 0, 0)
        sunLightNode.orientation = SCNQuaternion(0, 0, 0, 0)
        
        sunLightNode.addAnimation(duration: 20.0, from: NSValue(scnVector4: SCNVector4Make(0, 1, 0, -Float(Double.pi/2))), to: NSValue(scnVector4: SCNVector4Make(0, 1, 0, -Float(Double.pi/2) + Float(Double.pi) * 2.0)), key: "sun rotation")
        return sunLightNode
    }
}

private extension StellarSystemScene {
    private var earthNode: SCNNode {
        let earthNode = SCNNode(radius: 1.0, imageName: "earth")
        earthNode.castsShadow = true
        earthNode.position = SCNVector3Make(0, 0, 0)
        earthNode.geometry?.firstMaterial?.lightingModel = .lambert
        earthNode.addAnimation(duration: 4.0, from: NSValue(scnVector4: SCNVector4Make(0, 1, 0, 0)), to: NSValue(scnVector4: SCNVector4Make(0, 1, 0, Float(Double.pi) * 2.0)), key: "earth rotation")
        return earthNode
    }
    
    private func earthGroupNode(earthNode: SCNNode) -> SCNNode {
        let earthGroupNode = SCNNode()
        earthGroupNode.castsShadow = false
        earthGroupNode.position = SCNVector3Make(5, 0, 0)
        earthGroupNode.addChildNode(earthNode)
        return earthGroupNode
    }
    
    private var earthRotationNode: SCNNode {
        // Earth-group (will contain the Earth, and the Moon)
        let _earthGroupNode = earthGroupNode(earthNode: earthNode)
        _earthGroupNode.addChildNode(moonRotationNode(moonNode: moonNode))
        
        let earthRotationNode = SCNNode()
        earthRotationNode.castsShadow = false
        earthRotationNode.position = SCNVector3(0, 0, 0)
        earthRotationNode.addChildNode(_earthGroupNode)
        
        // Rotate the Earth around the Sun
        earthRotationNode.addAnimation(duration: 20, from: NSValue(scnVector4: SCNVector4Make(0, 2, 1, 0)), to: NSValue(scnVector4: SCNVector4Make(0, 2, 1, Float(Double.pi) * 2.0)), key: "earth rotation around the sun")
        
        return earthRotationNode
    }
}

private extension StellarSystemScene {
    private var moonNode: SCNNode {
        let moonNode = SCNNode(radius: 0.5, imageName: "moon")
        moonNode.castsShadow = true
        moonNode.position = SCNVector3Make(2, 0, 0)
        moonNode.geometry?.firstMaterial?.lightingModel = .lambert
        moonNode.addAnimation(duration: 4.0, from: NSValue(scnVector4: SCNVector4Make(0, 1, 0, 0)), to: NSValue(scnVector4: SCNVector4Make(0, 1, 0, Float(Double.pi) * 2.0)), key: "moon rotation")
        return moonNode
    }
    
    private func moonRotationNode(moonNode: SCNNode) -> SCNNode {
        // Moon-rotation (center of rotation of the Moon around the Earth)
        let moonRotationNode = SCNNode()
        moonRotationNode.castsShadow = false
        moonRotationNode.addChildNode(moonNode)
        // Rotate the moon around the earth
        moonRotationNode.addAnimation(duration: 20.0, from: NSValue(scnVector4: SCNVector4Make(0, 2, 1, 0)), to: NSValue(scnVector4: SCNVector4Make(0, 2, 1, Float(Double.pi) * 2.0)), key: "moon rotation around earth")
        
        return moonRotationNode
    }
}

private extension SCNNode {
    convenience init(radius: CGFloat, imageName: String) {
        self.init()
        geometry = SCNSphere(radius: radius)
        geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName)
    }
    
    func addAnimation(beginTime: CFTimeInterval = 0.0, duration: CFTimeInterval, from: NSValue, to: NSValue, key: String) {
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.beginTime = beginTime
        animation.duration = duration
        animation.fromValue = from
        animation.toValue = to
        animation.repeatCount = .greatestFiniteMagnitude
        addAnimation(animation, forKey: key)
    }
}
