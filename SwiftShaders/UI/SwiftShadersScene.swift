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
        
        contentNode.addChildNode(SCNNode(position: SCNVector3(-6, 2, 0), shaders: [.surface: simpleHalfColoringFromScreenSizeSurfaceShader]))
        
        contentNode.addChildNode(SCNNode(position: SCNVector3(-4, 2, 0), shaders: [.surface: simpleHalfColoringSurfaceShader]))
        
        let borgNode = SCNNode(position: SCNVector3(-2, 2, 0), shaders: [.fragment: appearingFragmentShader])
        borgNode.addMaterialWithTexture("noiseTexture", for: "noiseTexture")
        borgNode.addRevealAnimation()
        contentNode.addChildNode(borgNode)
        
        contentNode.addChildNode(SCNNode(position: SCNVector3(0, 2, 0), shaders: [.surface: coloringSurfaceShader]))
        
        contentNode.addChildNode(SCNNode(position: SCNVector3(2, 2, 0), shaders: [.geometry: twistingGeometryShader]))
        
        contentNode.addChildNode(SCNNode(position: SCNVector3(4, 2, 0), shaders: [.fragment: coloringFragmentShader]))
        
        let discoveringCubeNode = SCNNode(position: SCNVector3(6, 2, 0), shaders: [.fragment: discoveringFragment])
        discoveringCubeNode.addTexture("customTexture")
        contentNode.addChildNode(discoveringCubeNode)
        
        let gaussianBlurredCubeNode = SCNNode(position: SCNVector3(8, 2, 0), shaders: [.fragment: gaussianFragment])
        gaussianBlurredCubeNode.addTexture("customTexture")
        contentNode.addChildNode(gaussianBlurredCubeNode)
        
        let wavedCubeNode = SCNNode(position: SCNVector3(10, 2, 0), shaders: [.fragment: wavingFragment])
        wavedCubeNode.addTexture("customTexture")
        contentNode.addChildNode(wavedCubeNode)
        
        let dropEffectCubeNode = SCNNode(position: SCNVector3(12, 2, 0), shaders: [.fragment: dropEffectFragment])
        contentNode.addChildNode(dropEffectCubeNode)
        
        // Second Line: Filters
        
        let texturedCubeNode = SCNNode(position: SCNVector3(-6, 0, 0), shaders: [:])
        texturedCubeNode.addTexture("customTexture")
        contentNode.addChildNode(texturedCubeNode)
        
        let blurredCubeNode = SCNNode(position: SCNVector3(-4, 0, 0), shaders: [:])
        blurredCubeNode.addTexture("customTexture")
        blurredCubeNode.addFilters(["CIGaussianBlur"])
        contentNode.addChildNode(blurredCubeNode)
        
        let bloomCubeNode = SCNNode(position: SCNVector3(-2, 0, 0), shaders: [:])
        bloomCubeNode.addTexture("customTexture")
        bloomCubeNode.addFilters(["CIBloom"])
        contentNode.addChildNode(bloomCubeNode)
        
        let pixellatedCubeNode = SCNNode(position: SCNVector3(0, 0, 0), shaders: [:])
        pixellatedCubeNode.addTexture("customTexture")
        pixellatedCubeNode.addFilters(["CIPixellate"])
        contentNode.addChildNode(pixellatedCubeNode)
        
        let kaleidoscopeCubeNode = SCNNode(position: SCNVector3(2, 0, 0), shaders: [:])
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
        
        let textureSamplerNode = SCNNode(position: SCNVector3(-6, -2, 0), shaders: [:])
        textureSamplerNode.addProgramWithTexture("customTexture")
        contentNode.addChildNode(textureSamplerNode)
        
        let blurNode = SCNNode(position: SCNVector3(-4, -2, 0), shaders: [:])
        blurNode.addGaussianBlurEffect("customTexture", blur: 4)
        contentNode.addChildNode(blurNode)
        
        let textureBrightnessSamplerNode = SCNNode(position: SCNVector3(-2, -2, 0), shaders: [:])
        textureBrightnessSamplerNode.addProgramWithTexture("customTexture", key: "customTexture", brightness: 2.0)
        contentNode.addChildNode(textureBrightnessSamplerNode)
        
        let cloudNode = SCNNode(position: SCNVector3(0, -2, 0), shaders: [:])
        cloudNode.addCloudEffect()
        contentNode.addChildNode(cloudNode)
        
        let trianglesNode = SCNNode(position: SCNVector3(2, -2, 0), shaders: [:])
        trianglesNode.addTrianglesEffect()
        contentNode.addChildNode(trianglesNode)
        
        let colorNode = SCNNode(position: SCNVector3(4, -2, 0), shaders: [:])
        colorNode.addColorEffect(red: 40, green: 80, blue: 160, alpha: 128)
        contentNode.addChildNode(colorNode)
    }
}
