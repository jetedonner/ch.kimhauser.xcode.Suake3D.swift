//
//  Helpers.swift
//  Normals
//
//  Created by Morgan Wilde on 03/12/2014.
//  Copyright (c) 2014 Morgan Wilde. All rights reserved.
//

import Foundation
import SceneKit

protocol Named {
    static var name: String { get }
}

extension Float: Named {
    static var name: String { return "Float" }
}

struct Float3: /*Printable,*/ Equatable {
    var x, y, z: GLfloat
    var description: String {
        return "Float3(\(x), \(y), \(z))"
    }
    func factor(factor: GLfloat) -> Float3 {
        let tempX = x * factor
        let tempY = y * factor
        let tempZ = z * factor
        
        return Float3(x: tempX, y: tempY, z: tempZ)
    }
    func add(to: Float3) -> Float3 {
        return Float3(x: x + to.x, y: y + to.y, z: z + to.z)
    }
    func add(to: Float3?) -> Float3 {
        if let toNotNil = to {
            return Float3(x: x + toNotNil.x, y: y + toNotNil.y, z: z + toNotNil.z)
        }
        return Float3(x: x, y: y, z: z)
    }
    func subtract(subtrahend: Float3) -> Float3 {
        return Float3(x: x - subtrahend.x, y: y - subtrahend.y, z: z - subtrahend.z)
    }
    func normalize() -> Float3 {
        let length = sqrt(x*x + y*y + z*z)
        if length != 0 {
            return Float3(x: x/length, y: y/length, z: z/length)
        }
        return Float3(x: 0, y: 0, z: 0)
    }
    func crossProductWith(v: Float3) -> Float3 {
        let xCross = y*v.z - z*v.y
        let yCross = z*v.x - x*v.z
        let zCross = x*v.y - y*v.x
        
        return Float3(x: xCross, y: yCross, z: zCross)
    }
}
// Operator overload
func ==(lhs: Float3, rhs: Float3) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}

enum Direction {
    case North
    case East
    case South
    case West
}

enum PlanarDirection {
    case NorthWest
    case NorthEast
    case SouthEast
    case SouthWest
    var cardinalDirections: (Direction, Direction) {
        switch self {
        case .NorthWest:
            return (.North, .West)
        case .NorthEast:
            return (.East, .North)
        case .SouthEast:
            return (.South, .East)
        case .SouthWest:
            return (.West, .South)
        }
    }
}

struct VertexArray {
    var array: [Float3] = []
    var continuesInX: Bool
    var continuesInY: Bool
    let width: Int
    let height: Int
    init(width: Int, height: Int) {
        self.continuesInX = false
        self.continuesInY = false
        self.width = width
        self.height = height
        self.array = []
        
        for vertical in (0..<height) {
            for horizontal in (0..<width) {
                array += [Float3(x: 0, y: 0, z: 0)]
            }
        }
        /*for var vertical = 0; vertical < height; vertical++ {
            for var horizontal = 0; horizontal < width; horizontal++ {
                array += [Float3(x: 0, y: 0, z: 0)]
            }
        }*/
    }
    func getVertexIndex(x: Int, _ y: Int) -> Int {
        return y *  width + x
    }
    func getVertexIndexCInt(x: Int, _ y: Int) -> CInt {
        return CInt(getVertexIndex(x: x, y))
    }
    func getVertex(x: Int, _ y: Int) -> Float3 {
        return array[getVertexIndex(x: x, y)]
    }
    func getAdjacentVertex(x: Int, y: Int, from direction: Direction) -> Float3? {
        let coordinate = getAdjacentVertexCoordinate(x: x, y: y, from: direction)

        if coordinate.0 >= 0 &&
            coordinate.0 < width &&
            coordinate.1 >= 0 &&
            coordinate.1 < height {
            return getVertex(x: coordinate.0, coordinate.1)
        }
        return nil
    }
    func getAdjacentVertexCoordinate(x: Int, y: Int, from direction: Direction) -> (Int, Int) {
        let modifierX = (direction == .East) ? 1 : (direction == .West) ? -1 : 0
        let modifierY = (direction == .North) ? -1 : (direction == .South) ? 1 : 0
        
        var coordinateX = x + modifierX
        var coordinateY = y + modifierY
        if continuesInX {
            coordinateX %= width
            if coordinateX == -1 {
                coordinateX = width - 1
            }
        }
        if continuesInY {
            coordinateY %= height
            if coordinateY == -1 {
                coordinateY = height - 1
            }
        }
        return (coordinateX, coordinateY)
    }
    func getAdjacentVertexIndex(x: Int, y: Int, from direction: Direction) -> Int {
        let coordinate = getAdjacentVertexCoordinate(x: x, y: y, from: direction)
        return coordinate.1 * width + coordinate.0
    }
    func getAdjacentVertexIndexCInt(x: Int, y: Int, from direction: Direction) -> CInt {
        return CInt(getAdjacentVertexIndex(x: x, y: y, from: direction))
    }
    func getCrossProduct(x: Int, y: Int, from planarDirection: PlanarDirection) -> Float3? {
        let u = getAdjacentVertex(x: x, y: y, from: planarDirection.cardinalDirections.0)
        let v = getAdjacentVertex(x: x, y: y, from: planarDirection.cardinalDirections.1)
        
        if let vNotNil = v {
            if let uNotNil = u {
                let from = getVertex(x: x, y)
                let toU = uNotNil.subtract(subtrahend: from)
                let toV = vNotNil.subtract(subtrahend: from)
                if continuesInX {
                    return toV.crossProductWith(v: toU)
                }
                return toU.crossProductWith(v: toV)
            }
        }
        return nil
    }
    func getNormal(x: Int, y: Int) -> Float3 {
        let crossNorthWest = getCrossProduct(x: x, y: y, from: .NorthWest)
        let crossNorthEast = getCrossProduct(x: x, y: y, from: .NorthEast)
        let crossSouthEast = getCrossProduct(x: x, y: y, from: .SouthEast)
        let crossSouthWest = getCrossProduct(x: x, y: y, from: .SouthWest)
        //println("(\(x), \(y)) -> crossNorthWest: \(crossNorthWest); crossNorthEast: \(crossNorthEast); crossSouthEast: \(crossSouthEast); crossSouthWest: \(crossSouthWest); ")
        var sum = Float3(x: 0, y: 0, z: 0).add(to: crossNorthWest).add(to: crossNorthEast).add(to: crossSouthEast).add(to: crossSouthWest)
        
        return sum.normalize()
    }
    mutating func setVertex(vertex: Float3, x: Int, y: Int) {
        array[getVertexIndex(x: x, y)] = vertex
    }
}
