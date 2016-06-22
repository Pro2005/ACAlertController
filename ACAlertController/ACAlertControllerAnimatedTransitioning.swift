//
//  ACAlertControllerAnimatedTransitioning.swift
//  ACAlertController
//
//  Created by Yury on 22/06/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

class ACAlertControllerAnimatedTransitioning : NSObject, UIViewControllerAnimatedTransitioning {
    
    let animationDuration : NSTimeInterval = 0.16
    let appearing : Bool
    
    init(appearing: Bool) {
        self.appearing = appearing
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()!
        
        if appearing {
            let presentationView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!.view
            presentationView.frame = containerView.bounds
            containerView.addSubview(presentationView)
            presentationView.alpha = 0
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveLinear, animations: { () -> Void in
                presentationView.alpha = 1
            }) { (finished) -> Void in
                transitionContext.completeTransition(true)
            }
        } else {
            let presentationView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!.view
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveLinear, animations: { () -> Void in
                presentationView.alpha = 0
            }) { (finished) -> Void in
                presentationView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}
