//
//  Vector3.swift
//  Helix
//
//  Created by Morgan Wilde on 14/01/2015.
//  Copyright (c) 2015 Morgan Wilde. All rights reserved.
//

import Foundation
import SceneKit

struct Vector3<T> {
    var x,
        y,
        z: T
    var description: String {
        return "Vector3(\(x), \(y), \(z))"
    }
}