//
//  HelixVertexArray.swift
//  Normals
//
//  Created by Morgan Wilde on 10/01/2015.
//  Copyright (c) 2015 Morgan Wilde. All rights reserved.
//

import Foundation
import SceneKit

class HelixVertexArray {
    // Helix appearance
    var circles                 = 340   // how many circles to stitch
    var circleSegments          = 100     // each circle is made up of # of points
    var circleRadius: Float     = 0.25     // how thick the helix is
    var pitchInherent: Float    = 0.75     // the greater the number, the further each rung is
    var pitchCurrent: Float     = 1
    var helixRadius: Float
    
    var width: GLfloat      // x
    var height: GLfloat     // y
    var depth: GLfloat      // z
    
    var vertexArray: VertexArray
    var normalArray: [Float3] = []
    var elementArray: [CInt] = []
    
    var vertexSource: SCNGeometrySource
    var normalSource: SCNGeometrySource
    var element: SCNGeometryElement
    var geometry: SCNGeometry
    
    var quality = true
    
    init(width: Float, height: Float, depth: Float, pitch: Float, quality: Bool) {
        
        if quality {
            circles = 70
            circleSegments = 40
        } else {
            circles = 40
            circleSegments = 4
        }
        
        self.width = width
        self.height = height
        self.depth = depth
        self.pitchCurrent = pitch
        self.helixRadius = self.width / 2
        
        // Initial position for the helix
        var x: Float
        var y: Float
        var z: Float
        var t = -height/pitchInherent/2
        let yIncrement: Float = (height * (1/pitchInherent)) / Float(circles)
        var helixAngle: Float = 0
        var circleNumber = 0
        
        // Vertex array
        vertexArray = VertexArray(width: circleSegments, height: circles)
        vertexArray.continuesInX = true
        for i in (0..<circles) {
        //for var i = 0; i < circles; i++ {
            x = helixRadius * cos(t)
            z = helixRadius * sin(t)
            y = pitchInherent * pitchCurrent * t
            t += yIncrement
            
            helixAngle = atan2(x, z)
            
            let circleCenter = Float3(x: x, y: y, z: z)
            
            let angleZenith: Float =  0 * Float(M_PI) / 180
            let angleInitial: Float = 90
            let angleAzimuth: Float = helixAngle + angleInitial * Float(M_PI) / 180
            
            let n = Float3(
                x: cos(angleZenith) * sin(angleAzimuth),
                y: sin(angleAzimuth) * sin(angleZenith),
                z: cos(angleAzimuth))
            let u = Float3(
                x: -sin(angleZenith),
                y: cos(angleZenith),
                z: 0)
            let nxu = Float3(
                x: cos(angleAzimuth) * cos(angleZenith),
                y: cos(angleAzimuth) * sin(angleZenith),
                z: -sin(angleAzimuth))
            
            var circleSegment: Float = 0
            for j in (0..<circleSegments) {
            //for var j = 0; j < circleSegments; j++ {
                let circleX: Float = circleRadius * cos(circleSegment)
                let circleY: Float = circleRadius * sin(circleSegment)
                
                let circleCoordinates = Float3(x: circleX, y: circleY, z: 0)
                
                let part1 = u.factor(factor: circleCoordinates.x)
                let part2 = nxu.factor(factor: circleCoordinates.y)
                
                let circleParameter = part1.add(to: part2).add(to: circleCenter)
                
                vertexArray.setVertex(vertex: circleParameter, x: j, y: circleNumber)
                circleSegment += Float(2*M_PI) / Float(circleSegments)
            }
            //circleNumber++
            circleNumber += 1
        }
        
        // Element array
        // Goes level by level stiching them together with triangles
        for v in (0..<vertexArray.height - 1) {
        //for var v = 0; v < vertexArray.height - 1; v++ {
            for h in (0..<vertexArray.width) {
            //for var h = 0; h < vertexArray.width; h++ {
                let pointTopCoordinate = (h, v)
                let pointBottomCoordinate = (h, v + 1)
                // Top
                let pointTop = vertexArray.getVertexIndexCInt(x: pointTopCoordinate.0, pointTopCoordinate.1)
                let pointTopRight = vertexArray.getAdjacentVertexIndexCInt(x: pointTopCoordinate.0, y: pointTopCoordinate.1, from: .East)
                // Bottom
                let pointBottom = vertexArray.getVertexIndexCInt(x: pointBottomCoordinate.0, pointBottomCoordinate.1)
                let pointBottomRight = vertexArray.getAdjacentVertexIndexCInt(x: pointBottomCoordinate.0, y: pointBottomCoordinate.1, from: .East)
                
                elementArray += [pointTop, pointTopRight, pointBottom]
                elementArray += [pointBottom, pointTopRight, pointBottomRight]
            }
        }
        
        // Normal array
        for v in (0..<vertexArray.height) {
        //for var v = 0; v < vertexArray.height; v++ {
            for h in (0..<vertexArray.width) {
            //for var h = 0; h < vertexArray.width; h++ {
                normalArray += [vertexArray.getNormal(x: h, y: v)]
            }
        }
        
        // Create the vertex source
        let vertexData = NSData(bytes: vertexArray.array, length: vertexArray.array.count * MemoryLayout<Float3>.size)
        vertexSource = SCNGeometrySource(
            data: vertexData as Data,
            //data: vertexData,
            semantic: SCNGeometrySource.Semantic.vertex,
            vectorCount: vertexArray.array.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<GLfloat>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<Float3>.size)
        
        // Create the normal source
        let normalData = NSData(bytes: normalArray, length: normalArray.count * MemoryLayout<Float3>.size)
        normalSource = SCNGeometrySource(
            data: normalData as Data,
            //data: normalData,
            semantic: SCNGeometrySource.Semantic.normal,
            vectorCount: normalArray.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<GLfloat>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<Float3>.size)
        
        // Create the only element for this geometry
        let elementData = NSData(bytes: elementArray, length: elementArray.count * MemoryLayout<CInt>.size)
        element = SCNGeometryElement(
            data: elementData as Data,
            //data: elementData,
            primitiveType: .triangles,
            primitiveCount: elementArray.count / 3,
            bytesPerIndex: MemoryLayout<CInt>.size)
        
        // Create the geometry itself
        geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
        materials = [SCNMaterial()]
        /*for i in (0..<elementArray.count){
            let material = SCNMaterial()
            /*if(i % 2 == 0){
                material.diffuse.contents = NSColor(red: 41.0 / 256.0, green: 16.0 / 256.0, blue: 0, alpha: 0.75 )
            }else{
                material.diffuse.contents = NSColor(red: 141.0 / 256.0, green: 16.0 / 256.0, blue: 0, alpha: 0.25 )
            }*/
            material.emission.contents = NSColor.cyan
            if(i > 10000){
                material.transparency = 0.25
            }
            materials.append(material)
        }*/
        //geometry.materials = materials
        geometry.firstMaterial?.diffuse.contents = NSColor.cyan
        geometry.firstMaterial?.isDoubleSided = true
    }
    
    var materials:[SCNMaterial] = [SCNMaterial()]
    
    func getNode() -> SCNNode {
        var node:SCNNode = SCNNode(geometry: geometry)
        node.geometry?.materials = materials
        return node
    }
}
