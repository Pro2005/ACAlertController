//
//  ACAlertControllerAnimatedTransitioning.swift
//  ACAlertController
//
//  Created by Yury on 22/06/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

class ACAlertControllerAnimatedTransitioningBase : NSObject, UIViewControllerAnimatedTransitioning {
    
    let animationDuration : TimeInterval = 0.16
    let appearing : Bool
    open var backgroundColor = UIColor.black.withAlphaComponent(0.4)
    
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
            guard let presentationView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
                NSLog("ACAlertController: Error getting view for key UITransitionContextViewKey.to")
                transitionContext.completeTransition(false)
                return
            }
            let backgroundView = UIView()
            backgroundView.backgroundColor = backgroundColor
            backgroundView.frame = containerView.bounds
            backgroundView.alpha = 0
            containerView.addSubview(backgroundView)
            
            presentationView.frame = backgroundView.bounds
            backgroundView.addSubview(presentationView)
            
            NSLayoutConstraint(item: backgroundView, attribute: .centerX, relatedBy: .equal, toItem: presentationView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: backgroundView, attribute: .centerY, relatedBy: .equal, toItem: presentationView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true

            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveLinear, animations: { () -> Void in
                backgroundView.alpha = 1
            }) { (finished) -> Void in
                transitionContext.completeTransition(true)
            }
        } else {
            guard let presentationView = transitionContext.view(forKey: UITransitionContextViewKey.from)
                , let backgroundView = presentationView.superview else {
                NSLog("ACAlertController: Error getting view for key UITransitionContextViewKey.from")
                transitionContext.completeTransition(false)
                return
            }
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveLinear, animations: { () -> Void in
                backgroundView.alpha = 0
            }) { (finished) -> Void in
                presentationView.removeFromSuperview()
                backgroundView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}

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
