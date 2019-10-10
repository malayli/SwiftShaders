import SceneKit

final class SwiftShadersScene: SCNScene {
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
        
        let texturedCubeNode = cubeNode(position: SCNVector3(-3, 0, 0), shaders: [:])
        texturedCubeNode.addTexture()
        contentNode.addChildNode(texturedCubeNode)
        
        let blurredCubeNode = cubeNode(position: SCNVector3(0, 0, 0), shaders: [:])
        blurredCubeNode.addTexture()
        let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
        gaussianBlurFilter?.name = "blur"
        blurredCubeNode.filters = [ gaussianBlurFilter! ]
        contentNode.addChildNode(blurredCubeNode)
        
        let cloudNode = cubeNode(position: SCNVector3(3, 0, 0), shaders: [:])
        let program = SCNProgram()
        program.vertexFunctionName = "cloudVertex"
        program.fragmentFunctionName = "cloudFragment"
        cloudNode.geometry?.firstMaterial?.program = program
        let noiseImage  = UIImage(named: "art.scnassets/softNoise.png")!
        let noiseImageProperty = SCNMaterialProperty(contents: noiseImage)
        cloudNode.geometry?.firstMaterial?.setValue(noiseImageProperty, forKey: "noiseTexture")
        let intImage  = UIImage(named: "art.scnassets/sharpNoise.png")!
        let intImageProperty = SCNMaterialProperty(contents: intImage)
        cloudNode.geometry?.firstMaterial?.setValue(intImageProperty, forKey: "interferenceTexture")
        contentNode.addChildNode(cloudNode)
        
        //        // Allocate enough memory to store three floats per vertex, ensuring we free it later
        //        let terrainBuffer = UnsafeMutableBufferPointer<Float>.allocate(capacity: 2)
        //        defer {
        //            terrainBuffer.deallocate()
        //        }
        //
        //        // Copy each element of each vector into the buffer
        //        terrainBuffer[0] = Float(0)
        //
        //        // Copy the buffer data into a Data object, as expected by SceneKit
        //        let terrainData = Data(buffer: terrainBuffer)
        //blurredCubeNode2.geometry?.firstMaterial?.setValue(terrainData, forKey: "attribute")
    }
}

private extension SwiftShadersScene {
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
    
    func addTexture() {
        geometry?.firstMaterial?.diffuse.contents = UIImage(named: "texture")
    }
}
