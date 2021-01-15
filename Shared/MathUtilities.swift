//
//  MathUtilities.swift
//  LifeLab
//
//  Created by Jonathan Attfield on 08/01/2021.
//

import simd

extension simd_float4 {
    var xyz : simd_float3 {
        return simd_float3(x, y, z)
    }
}

extension float4x4 {
    init(scaleBy s: Float) {
        self.init(simd_float4(s, 0, 0, 0),
                  simd_float4(0, s, 0, 0),
                  simd_float4(0, 0, s, 0),
                  simd_float4(0, 0, 0, 1))
    }

    init(rotationAbout axis: simd_float3, by angleRadians: Float) {
        let a = normalize(axis)
        let x = a.x, y = a.y, z = a.z
        let c = cosf(angleRadians)
        let s = sinf(angleRadians)
        let t = 1 - c
        self.init(simd_float4(t * x * x + c, t * x * y + z * s, t * x * z - y * s, 0),
                  simd_float4(t * x * y - z * s, t * y * y + c, t * y * z + x * z, 0),
                  simd_float4(t * x * z + y * s, t * y * z - x * s, t * z * z + c, 0),
                  simd_float4(0, 0, 0, 1))
    }
    
    init(translationBy t: simd_float3) {
        self.init(simd_float4(1, 0, 0, 0),
                  simd_float4(0, 1, 0, 0),
                  simd_float4(0, 0, 1, 0),
                  simd_float4(t[0], t[1], t[2], 1))
    }
    
    init(perspectiveProjectionFov fovRadians: Float, aspectRatio aspect: Float, nearZ: Float, farZ: Float) {
        let yScale = 1 / tan(fovRadians * 0.5)
        let xScale = yScale / aspect
        let zRange = farZ - nearZ
        let zScale = -(farZ + nearZ) / zRange
        let wzScale = -2 * farZ * nearZ / zRange
        
        self.init(simd_float4(xScale, 0, 0, 0),
                  simd_float4(0, yScale, 0, 0),
                  simd_float4(0, 0, zScale, -1),
                  simd_float4(0, 0, wzScale, 1))
    }
    
    var normalMatrix: float3x3 {
        let upperLeft = float3x3(self[0].xyz, self[1].xyz, self[2].xyz)
        return upperLeft.transpose.inverse
    }
}
