import SceneKit

// MARK: - Cube

extension SCNNode {
    convenience init(position p: SCNVector3, shaders: [SCNShaderModifierEntryPoint: String]) {
        self.init()
        
        castsShadow = false
        position = p
        geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.shaderModifiers = shaders
        material.lightingModel = .constant
        geometry?.materials = [material]
    }
}

// MARK: - Texture

extension SCNNode {
    func addTexture(_ imageName: String) {
        geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName)
    }
}

// MARK: - Animations

extension SCNNode {
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

// MARK: - CIFilter

extension SCNNode {
    func addFilters(_ names: [String]) {
        names.forEach {
        if let filter = CIFilter(name: $0) {
            filter.name = $0
            filters = [filter]
        }
        }
    }
}

// MARK: - Metal

extension SCNNode {
    func addCloudEffect() {
        let program = SCNProgram()
        program.vertexFunctionName = "cloudVertex"
        program.fragmentFunctionName = "cloudFragment"
        program.isOpaque = false
        geometry?.firstMaterial?.program = program
        
        guard let noiseImage  = UIImage(named: "art.scnassets/softNoise.png"),
            let intImage  = UIImage(named: "art.scnassets/sharpNoise.png") else {
            return
        }
        let noiseImageProperty = SCNMaterialProperty(contents: noiseImage)
        geometry?.firstMaterial?.setValue(noiseImageProperty, forKey: "noiseTexture")
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
    
    func addColorEffect(red: Float, green: Float, blue: Float, alpha: Float) {
        let program = SCNProgram()
        program.vertexFunctionName = "colorVertex"
        program.fragmentFunctionName = "colorFragment"
        program.isOpaque = false
        geometry?.firstMaterial?.program = program
        
        struct FragmentUniforms {
            var red: Float = 1.0
            var green: Float = 1.0
            var blue: Float = 1.0
            var alpha: Float = 1.0
        }
        
        var uniforms = FragmentUniforms()
        uniforms.red = red/255.0
        uniforms.green = green/255.0
        uniforms.blue = blue/255.0
        uniforms.alpha = alpha/255.0
        
        program.handleBinding(ofBufferNamed: "uniforms", frequency: .perFrame) { (bufferStream, node, shadable, renderer) in
            bufferStream.writeBytes(&uniforms, count: MemoryLayout<FragmentUniforms>.stride)
        }
    }
    
    func addProgramWithTexture(_ name: String) {
        let program = SCNProgram()
        program.vertexFunctionName = "textureSamplerVertex"
        program.fragmentFunctionName = "textureSamplerFragment"
        geometry?.firstMaterial?.program = program
        
        guard let customTextureImage  = UIImage(named: name) else {
            return
        }
        let materialProperty = SCNMaterialProperty(contents: customTextureImage)
        geometry?.firstMaterial?.setValue(materialProperty, forKey: "customTexture")
    }
    
    func addProgramWithTexture(_ name: String, key: String, brightness: Float) {
        let program = SCNProgram()
        program.vertexFunctionName = "textureBrightnessSamplerVertex"
        program.fragmentFunctionName = "textureBrightnessSamplerFragment"
        geometry?.firstMaterial?.program = program
        
        addMaterialWithTexture(name, for: key)
        
        struct FragmentUniforms {
            var brightness: Float = 1.0
        }
        
        var uniforms = FragmentUniforms()
        uniforms.brightness = brightness
        
        program.handleBinding(ofBufferNamed: "uniforms", frequency: .perFrame) { (bufferStream, node, shadable, renderer) in
            bufferStream.writeBytes(&uniforms, count: MemoryLayout<FragmentUniforms>.stride)
        }
    }
    
    func addMaterialWithTexture(_ name: String, for key: String) {
        guard let customTextureImage  = UIImage(named: name) else {
            return
        }
        let materialProperty = SCNMaterialProperty(contents: customTextureImage)
        geometry?.firstMaterial?.setValue(materialProperty, forKey: key)
    }
    
    func addGaussianBlurEffect(_ name: String, blur: Float) {
        let program = SCNProgram()
        program.vertexFunctionName = "gaussianBlurVertex"
        program.fragmentFunctionName = "gaussianBlurFragment"
        geometry?.firstMaterial?.program = program
        
        guard let customTextureImage  = UIImage(named: name) else {
            return
        }
        let materialProperty = SCNMaterialProperty(contents: customTextureImage)
        geometry?.firstMaterial?.setValue(materialProperty, forKey: "customTexture")
        
        struct FragmentUniforms {
            var blur: Float = 1.0
        }
        
        var uniforms = FragmentUniforms()
        uniforms.blur = blur
        
        program.handleBinding(ofBufferNamed: "uniforms", frequency: .perFrame) { (bufferStream, node, shadable, renderer) in
            bufferStream.writeBytes(&uniforms, count: MemoryLayout<FragmentUniforms>.stride)
        }
    }
}
