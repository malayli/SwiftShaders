import SceneKit

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
    
    func addTextureSamplerEffect() {
        let program = SCNProgram()
        program.vertexFunctionName = "textureSamplerVertex"
        program.fragmentFunctionName = "textureSamplerFragment"
        geometry?.firstMaterial?.program = program
        
        guard let customeTextureImage  = UIImage(named: "customTexture") else {
            return
        }
        let customeTextureImageProperty = SCNMaterialProperty(contents: customeTextureImage)
        geometry?.firstMaterial?.setValue(customeTextureImageProperty, forKey: "customTexture")
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
    
    func addTextureBrightnessSamplerEffect() {
        let program = SCNProgram()
        program.vertexFunctionName = "textureBrightnessSamplerVertex"
        program.fragmentFunctionName = "textureBrightnessSamplerFragment"
        geometry?.firstMaterial?.program = program
        
        guard let customeTextureImage  = UIImage(named: "customTexture") else {
            return
        }
        let customeTextureImageProperty = SCNMaterialProperty(contents: customeTextureImage)
        geometry?.firstMaterial?.setValue(customeTextureImageProperty, forKey: "customTexture")
        
        struct FragmentUniforms {
            var brightness: Float = 1.0
        }
        
        var myUniforms = FragmentUniforms()
        myUniforms.brightness = 2.0
        
        program.handleBinding(ofBufferNamed: "uniforms", frequency: .perFrame) { (bufferStream, node, shadable, renderer) in
            bufferStream.writeBytes(&myUniforms, count: MemoryLayout<FragmentUniforms>.stride)
        }
    }
}
