//
//  RotationAnim.swift
//  Suake3D
//
//  Created by dave on 17.04.18.
//  Copyright © 2018 DaVe Inc. All rights reserved.
//

import Foundation
import SceneKit

class RotationAnim {
    
    class func getRotationAnim()->CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(scnVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(Double.pi)*2))
        animation.duration = 3
        animation.repeatCount = MAXFLOAT //repeat forever
        return animation
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
