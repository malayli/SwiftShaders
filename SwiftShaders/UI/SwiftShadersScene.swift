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
        
        // Bum Mapping
        // Resources: http://planetpixelemporium.com/earth.html
        
        let earthGeometry = SCNSphere(radius: 1)
        //earthGeometry.firstMaterial?.diffuse.contents = UIImage(named: "diffuse")
        earthGeometry.firstMaterial?.normal.contents = UIImage(named: "normal")
        earthGeometry.firstMaterial?.lightingModel = .lambert
        let earthNode = SCNNode(geometry: earthGeometry)
        earthNode.castsShadow = false
        earthNode.position = SCNVector3(0, 4, 0)
        contentNode.addChildNode(earthNode)
        
        let lightNode = SCNNode()
        lightNode.castsShadow = false
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = UIColor.white
        lightNode.position = SCNVector3(0, 4, 10)
        lightNode.look(at: earthNode.position)
        contentNode.addChildNode(lightNode)
        
        // First Line: SceneKit Shaders
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(-6, 2, 0), shaders: [.surface: simpleHalfColoringFromScreenSizeSurfaceShader]))
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(-4, 2, 0), shaders: [.surface: simpleHalfColoringSurfaceShader]))
        
        let borgNode = cubeNode(position: SCNVector3(-2, 2, 0), shaders: [.fragment: appearingFragmentShader])
        borgNode.addRevealAnimation("noise")
        contentNode.addChildNode(borgNode)
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(0, 2, 0), shaders: [.surface: coloringSurfaceShader]))
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(2, 2, 0), shaders: [.geometry: twistingGeometryShader]))
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(4, 2, 0), shaders: [.fragment: coloringFragmentShader]))
        
        // Second Line: Filters
        
        let texturedCubeNode = cubeNode(position: SCNVector3(-6, 0, 0), shaders: [:])
        texturedCubeNode.addTexture("customTexture")
        contentNode.addChildNode(texturedCubeNode)
        
        let blurredCubeNode = cubeNode(position: SCNVector3(-4, 0, 0), shaders: [:])
        blurredCubeNode.addTexture("customTexture")
        blurredCubeNode.addFilters(["CIGaussianBlur"])
        contentNode.addChildNode(blurredCubeNode)
        
        let bloomCubeNode = cubeNode(position: SCNVector3(-2, 0, 0), shaders: [:])
        bloomCubeNode.addTexture("customTexture")
        bloomCubeNode.addFilters(["CIBloom"])
        contentNode.addChildNode(bloomCubeNode)
        
        let pixellatedCubeNode = cubeNode(position: SCNVector3(0, 0, 0), shaders: [:])
        pixellatedCubeNode.addTexture("customTexture")
        pixellatedCubeNode.addFilters(["CIPixellate"])
        contentNode.addChildNode(pixellatedCubeNode)
        
        let kaleidoscopeCubeNode = cubeNode(position: SCNVector3(2, 0, 0), shaders: [:])
        kaleidoscopeCubeNode.addTexture("customTexture")
        kaleidoscopeCubeNode.addFilters(["CIThermal"])
        contentNode.addChildNode(kaleidoscopeCubeNode)
        
        // Third Line: Metal Shaders
        
//        let geometry = SCNGeometry.lineThrough(points: [SCNVector3(-10, 0,0), SCNVector3(-10, 10, 0), SCNVector3(10, 10, 0), SCNVector3(10, 0, 0)],
//                                               width: 20,
//                                               closed: false,
//                                               color: UIColor.red.cgColor)
//        let node = SCNNode(geometry: geometry)
//        contentNode.addChildNode(node)
        
        let textureSamplerNode = cubeNode(position: SCNVector3(-6, -2, 0), shaders: [:])
        textureSamplerNode.addProgramWithTexture("customTexture")
        contentNode.addChildNode(textureSamplerNode)
        
        let blurNode = cubeNode(position: SCNVector3(-4, -2, 0), shaders: [:])
        blurNode.addGaussianBlurEffect("customTexture", blur: 4)
        contentNode.addChildNode(blurNode)
        
        let textureBrightnessSamplerNode = cubeNode(position: SCNVector3(-2, -2, 0), shaders: [:])
        textureBrightnessSamplerNode.addProgramWithTexture("customTexture", brightness: 2.0)
        contentNode.addChildNode(textureBrightnessSamplerNode)
        
        let cloudNode = cubeNode(position: SCNVector3(0, -2, 0), shaders: [:])
        cloudNode.addCloudEffect()
        contentNode.addChildNode(cloudNode)
        
        let trianglesNode = cubeNode(position: SCNVector3(2, -2, 0), shaders: [:])
        trianglesNode.addTrianglesEffect()
        contentNode.addChildNode(trianglesNode)
        
        let colorNode = cubeNode(position: SCNVector3(4, -2, 0), shaders: [:])
        colorNode.addColorEffect(red: 40, green: 80, blue: 160, alpha: 128)
        contentNode.addChildNode(colorNode)
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
