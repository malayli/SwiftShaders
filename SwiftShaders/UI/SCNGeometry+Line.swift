import SceneKit

extension SCNGeometry {
    class func lineThrough(points: [SCNVector3], width:Int = 20, closed: Bool = false,  color: CGColor = UIColor.black.cgColor, mitter: Bool = false) -> SCNGeometry? {
        
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
        guard let components = color.components else {
            return nil
        }
        
        let colorFloat = components.map { Float($0) }
        
        geometry.setValue(NSData(bytes: colorFloat, length: MemoryLayout<simd_float1>.size * color.numberOfComponents), forKey: "color")
        
        // Set the shader program
        let program = SCNProgram()
        program.fragmentFunctionName = "thickLinesFragment"
        program.vertexFunctionName = "thickLinesVertex"
        geometry.program = program
        
        return geometry
    }
}
