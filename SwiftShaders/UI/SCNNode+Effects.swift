import SceneKit

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
    
    func addRevealAnimation(_ imageName: String) {
        if let noiseImage = UIImage(named: imageName) {
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
    
    func addColorEffect(red: Float, green: Float, blue: Float) {
        let program = SCNProgram()
        program.vertexFunctionName = "colorVertex"
        program.fragmentFunctionName = "colorFragment"
        geometry?.firstMaterial?.program = program
        
        struct FragmentUniforms {
            var colorR: Float = 1.0
            var colorG: Float = 1.0
            var colorB: Float = 1.0
        }
        
        var uniforms = FragmentUniforms()
        uniforms.colorR = red/255.0
        uniforms.colorG = green/255.0
        uniforms.colorB = blue/255.0
        
        program.handleBinding(ofBufferNamed: "uniforms", frequency: .perFrame) { (bufferStream, node, shadable, renderer) in
            bufferStream.writeBytes(&uniforms, count: MemoryLayout<FragmentUniforms>.stride)
        }
    }
}

extension SCNNode {
    func addTextureSamplerEffect() {
        let program = SCNProgram()
        program.vertexFunctionName = "textureSamplerVertex"
        program.fragmentFunctionName = "textureSamplerFragment"
        geometry?.firstMaterial?.program = program
        
        guard let customTextureImage  = UIImage(named: "customTexture") else {
            return
        }
        let materialProperty = SCNMaterialProperty(contents: customTextureImage)
        geometry?.firstMaterial?.setValue(materialProperty, forKey: "customTexture")
    }
    
    func addTextureBrightnessSamplerEffect() {
        let program = SCNProgram()
        program.vertexFunctionName = "textureBrightnessSamplerVertex"
        program.fragmentFunctionName = "textureBrightnessSamplerFragment"
        geometry?.firstMaterial?.program = program
        
        guard let customTextureImage  = UIImage(named: "customTexture") else {
            return
        }
        let materialProperty = SCNMaterialProperty(contents: customTextureImage)
        geometry?.firstMaterial?.setValue(materialProperty, forKey: "customTexture")
        
        struct FragmentUniforms {
            var brightness: Float = 1.0
        }
        
        var uniforms = FragmentUniforms()
        uniforms.brightness = 2.0
        
        program.handleBinding(ofBufferNamed: "uniforms", frequency: .perFrame) { (bufferStream, node, shadable, renderer) in
            bufferStream.writeBytes(&uniforms, count: MemoryLayout<FragmentUniforms>.stride)
        }
    }
    
    func addGaussianBlurEffect() {
        let program = SCNProgram()
        program.vertexFunctionName = "gaussianBlurVertex"
        program.fragmentFunctionName = "gaussianBlurFragment"
        geometry?.firstMaterial?.program = program
        
        guard let customTextureImage  = UIImage(named: "customTexture") else {
            return
        }
        let materialProperty = SCNMaterialProperty(contents: customTextureImage)
        geometry?.firstMaterial?.setValue(materialProperty, forKey: "customTexture")
        
        struct FragmentUniforms {
            var blur: Float = 1.0
        }
        
        var uniforms = FragmentUniforms()
        uniforms.blur = 4.0
        
        program.handleBinding(ofBufferNamed: "uniforms", frequency: .perFrame) { (bufferStream, node, shadable, renderer) in
            bufferStream.writeBytes(&uniforms, count: MemoryLayout<FragmentUniforms>.stride)
        }
    }
}
