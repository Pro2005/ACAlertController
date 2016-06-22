//
//  ACTouchGestureRecogniser.swift
//  CustomizableAlertController
//
//  Created by Yury on 21/06/16.
//  Copyright © 2016 Avtolic. All rights reserved.

import UIKit
import UIKit.UIGestureRecognizerSubclass

class ACTouchGestureRecogniser: UIGestureRecognizer {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if touches.count != 1 {
            state = .Failed
        }
        state = .Began
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)

        if state != .Failed {
            state = .Ended
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)

        if state != .Failed {
            state = .Changed
        }
    }
    
    override func reset() {
        super.reset()
        state = .Possible
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        state = .Cancelled // forward the cancel state
    }
}
