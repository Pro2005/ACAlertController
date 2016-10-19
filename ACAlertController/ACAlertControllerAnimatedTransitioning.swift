//
//  ACAlertControllerAnimatedTransitioning.swift
//  ACAlertController
//
//  Created by Yury on 22/06/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

class ACAlertControllerAnimatedTransitioning : NSObject, UIViewControllerAnimatedTransitioning {
    
    let animationDuration : TimeInterval = 0.16
    let appearing : Bool
    
    init(appearing: Bool) {
        self.appearing = appearing
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if appearing {
            let presentationView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view
            presentationView?.frame = containerView.bounds
            containerView.addSubview(presentationView!)
            presentationView?.alpha = 0
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveLinear, animations: { () -> Void in
                presentationView?.alpha = 1
            }) { (finished) -> Void in
                transitionContext.completeTransition(true)
            }
        } else {
            let presentationView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!.view
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveLinear, animations: { () -> Void in
                presentationView?.alpha = 0
            }) { (finished) -> Void in
                presentationView?.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}
