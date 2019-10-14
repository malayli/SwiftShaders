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
        
        // First Line: SceneKit Shaders
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(-6, 3, 0), shaders: [.surface: simpleHalfColoringFromScreenSizeSurfaceShader]))
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(-3, 3, 0), shaders: [.surface: simpleHalfColoringSurfaceShader]))
        
        let borgNode = cubeNode(position: SCNVector3(0, 3, 0), shaders: [.fragment: appearingFragmentShader])
        borgNode.addRevealAnimation()
        contentNode.addChildNode(borgNode)
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(3, 3, 0), shaders: [.surface: coloringSurfaceShader]))
        
        contentNode.addChildNode(cubeNode(position: SCNVector3(6, 3, 0), shaders: [.geometry: twistingGeometryShader]))
        
        // Second Line: Filters
        
        let texturedCubeNode = cubeNode(position: SCNVector3(-6, 0, 0), shaders: [:])
        texturedCubeNode.addTexture()
        contentNode.addChildNode(texturedCubeNode)
        
        let blurredCubeNode = cubeNode(position: SCNVector3(-3, 0, 0), shaders: [:])
        blurredCubeNode.addTexture()
        blurredCubeNode.addFilters(["CIGaussianBlur"])
        contentNode.addChildNode(blurredCubeNode)
        
        let pixellatedCubeNode = cubeNode(position: SCNVector3(0, 0, 0), shaders: [:])
        pixellatedCubeNode.addTexture()
        pixellatedCubeNode.addFilters(["CIPixellate"])
        contentNode.addChildNode(pixellatedCubeNode)
        
        let bloomCubeNode = cubeNode(position: SCNVector3(3, 0, 0), shaders: [:])
        bloomCubeNode.addTexture()
        bloomCubeNode.addFilters(["CIBloom"])
        contentNode.addChildNode(bloomCubeNode)
        
        let kaleidoscopeCubeNode = cubeNode(position: SCNVector3(6, 0, 0), shaders: [:])
        kaleidoscopeCubeNode.addTexture()
        kaleidoscopeCubeNode.addFilters(["CIThermal"])
        contentNode.addChildNode(kaleidoscopeCubeNode)
        
        // Third Line: Metal Shaders
        
//        let geometry = SCNGeometry.lineThrough(points: [SCNVector3(-10, 0,0), SCNVector3(-10, 10, 0), SCNVector3(10, 10, 0), SCNVector3(10, 0, 0)],
//                                               width: 20,
//                                               closed: false,
//                                               color: UIColor.red.cgColor)
//        let node = SCNNode(geometry: geometry)
//        contentNode.addChildNode(node)

//        let noNode = cubeNode(position: SCNVector3(-3, -3, 0), shaders: [:])
//        noNode.addTexture()
//        noNode.addNoEffect()
//        contentNode.addChildNode(noNode)

        let textureSamplerNode = cubeNode(position: SCNVector3(-3, -3, 0), shaders: [:])
        textureSamplerNode.addTextureSamplerEffect()
        contentNode.addChildNode(textureSamplerNode)
        
        let cloudNode = cubeNode(position: SCNVector3(0, -3, 0), shaders: [:])
        cloudNode.addCloudEffect()
        contentNode.addChildNode(cloudNode)
        
        let blurNode = cubeNode(position: SCNVector3(3, -3, 0), shaders: [:])
        blurNode.addTrianglesEffect()
        contentNode.addChildNode(blurNode)
        
        let nothingNode = cubeNode(position: SCNVector3(6, -3, 0), shaders: [:])
        nothingNode.addColorEffect()
        contentNode.addChildNode(nothingNode)
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
        geometry?.firstMaterial?.diffuse.contents = UIImage(named: "customTexture")
    }
    
    func addFilters(_ names: [String]) {
        names.forEach {
        if let filter = CIFilter(name: $0) {
            filter.name = $0
            filters = [filter]
        }
        }
    }
    
    func addCloudEffect() {
        let program = SCNProgram()
        program.vertexFunctionName = "cloudVertex"
        program.fragmentFunctionName = "cloudFragment"
        program.isOpaque = false
        geometry?.firstMaterial?.program = program
        
        let noiseImage  = UIImage(named: "art.scnassets/softNoise.png")!
        let noiseImageProperty = SCNMaterialProperty(contents: noiseImage)
        geometry?.firstMaterial?.setValue(noiseImageProperty, forKey: "noiseTexture")
        
        let intImage  = UIImage(named: "art.scnassets/sharpNoise.png")!
        let intImageProperty = SCNMaterialProperty(contents: intImage)
        geometry?.firstMaterial?.setValue(intImageProperty, forKey: "interferenceTexture")
    }
    
    func addTrianglesEffect() {
        let program = SCNProgram()
        program.vertexFunctionName = "trianglequiltVertex"
        program.fragmentFunctionName = "trianglequiltFragment"
        
        let gradientMaterial = SCNMaterial()
        gradientMaterial.program = program
        gradientMaterial.specular.contents = UIColor.black
        gradientMaterial.locksAmbientWithDiffuse = true
        geometry?.materials = [gradientMaterial]
        geometry?.firstMaterial?.lightingModel = .constant
    }
    
    func addTextureSamplerEffect() {
        let program = SCNProgram()
        program.vertexFunctionName = "textureSamplerVertex"
        program.fragmentFunctionName = "textureSamplerFragment"
        geometry?.firstMaterial?.program = program
        
        let noiseImage  = UIImage(named: "customTexture")!
        let noiseImageProperty = SCNMaterialProperty(contents: noiseImage)
        geometry?.firstMaterial?.setValue(noiseImageProperty, forKey: "customTexture")
    }
    
    func addColorEffect() {
        let program = SCNProgram()
        program.vertexFunctionName = "colorVertex"
        program.fragmentFunctionName = "colorFragment"
        geometry?.firstMaterial?.program = program
        
        struct FragmentUniforms {
            var color: Float = 1.0
        }
        
        var myUniforms = FragmentUniforms()
        myUniforms.color = 0.1
        
        program.handleBinding(ofBufferNamed: "uniforms", frequency: .perFrame) { (bufferStream, node, shadable, renderer) in
            bufferStream.writeBytes(&myUniforms, count: MemoryLayout<FragmentUniforms>.stride)
        }
    }
}

extension SCNGeometry {
    class func lineThrough(points: [SCNVector3], width:Int = 20, closed: Bool = false,  color: CGColor = UIColor.black.cgColor, mitter: Bool = false) -> SCNGeometry {
        
        // Becouse we cannot use geometry shaders in metal, every point on the line has to be changed into 4 verticles
        let vertices: [SCNVector3] = points.flatMap { p in [p, p, p, p] }
        
        // Create Geometry Source object
        let source = SCNGeometrySource(vertices: vertices)
        
        // Create Geometry Element object
        var indices = Array((0..<Int32(vertices.count)))
        if (closed) {
            indices += [0, 1]
        }
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangleStrip)
        
        // Prepare data for vertex shader
        // Format is line width, number of points, should mitter be included, should line create closed loop
        let lineData: [Int32] = [Int32(width), Int32(points.count), Int32(mitter ? 1 : 0), Int32(closed ? 1 : 0)]
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.setValue(Data(bytes: lineData, count: MemoryLayout<Int32>.size*lineData.count), forKeyPath: "lineData")
        
        // map verticles into float3
        let floatPoints = vertices.map { SIMD3<Float>($0) }
        geometry.setValue(NSData(bytes: floatPoints, length: MemoryLayout<SIMD3<Float>>.size * floatPoints.count), forKeyPath: "vertices")
        
        // map color into float
        let colorFloat = color.components!.map { Float($0) }
        geometry.setValue(NSData(bytes: colorFloat, length: MemoryLayout<simd_float1>.size * color.numberOfComponents), forKey: "color")
        
        // Set the shader program
        let program = SCNProgram()
        program.fragmentFunctionName = "thickLinesFragment"
        program.vertexFunctionName = "thickLinesVertex"
        geometry.program = program
        
        return geometry
    }
}
