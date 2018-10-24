//
//  ACTouchGestureRecogniser.swift
//  ACAlertController
//
//  Created by Yury on 21/06/16.
//  Copyright © 2016 Avtolic. All rights reserved.

import UIKit
import UIKit.UIGestureRecognizerSubclass

class ACTouchGestureRecognizer: UIGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        
        
        var expectedState = UIGestureRecognizer.State.failed
        if touches.count != 1 {
            expectedState = .failed
        }
        expectedState = .began

        print("Expected state \(expectedState.rawValue)")
        
        super.touchesBegan(touches, with: event)
        print("Original state \(state.rawValue)")
//        if touches.count != 1 {
//            state = .Failed
//        }
//        state = .Began
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)

        if state != .failed {
            state = .ended
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        if state != .failed {
            state = .changed
        }
    }
    
    override func reset() {
        super.reset()
        state = .possible
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = .cancelled // forward the cancel state
    }
}
