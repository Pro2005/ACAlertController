//
//  AlertController.swift
//  ACAlertController
//
//  Created by Yury on 17/06/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

// MARK: Protocols and Extensions


// MARK: - UIAlertController compatibility

extension ACAlertController {
    
    override open var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    public var message: String? {
        get { return messageLabel.text }
        set { messageLabel.text = newValue }
    }
    
    public convenience init(title: String?, message: String?) {
        self.init()
        self.title = title
        self.message = message
    }
}

// MARK: -
open class ACAlertController : UIViewController {

    // MARK: Properties
    
    fileprivate(set) open var itemInsetPairs: [(ACAlertItemProtocol, UIEdgeInsets)] = []
    open var items: [ACAlertItemProtocol] { return itemInsetPairs.map{ $0.0 } }
    fileprivate(set) open var actions: [ACAlertActionProtocol] = []
    
    open var tintColor = UIColor.blue
    open var alertBackgroundColor = UIColor.white//UIColor(white: 248/256, alpha: 1)
    open var alertLinesColor = UIColor(red:220/256, green:220/256, blue:224/256, alpha:1.0)
    open var backgroundColor = UIColor.black.withAlphaComponent(0.4)
    open var buttonColor = UIColor.clear
    open var buttonHighlightColor = UIColor(white: 0.9, alpha: 1)
    
    open var viewMargins = UIEdgeInsets(top: 15, left: 8, bottom: 15, right: 8) // Applied to items and top/bottom margins of alert view
    open var buttonsMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8) // Applied to buttons
    open var defaultItemsMargins = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0) // Applied to items
    
    open var cornerRadius: CGFloat = 16
    open var defaultButtonHeight: CGFloat = 45
    open var alertWidth: CGFloat = 270
    
    open var nonMandatoryConstraintPriority: UILayoutPriority = 900 // Item's and action's constraints that could conflict with ACAlertController constraints should have priorities in [nonMandatoryConstraintPriority ..< 1000] range.

    
    // MARK: Private properties
    
    fileprivate var alertView: UIView!
    fileprivate var button2actionDict: [UIView: ACAlertActionProtocol] = [:]
    
    // UIAlertController compatibility
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    
    
    // MARK: Public methods
    open func addItem(_ item: ACAlertItemProtocol, inset: UIEdgeInsets? = nil) {
        guard isBeingPresented == false else {
            print("ACAlertController could not be modified if it is already presented")
            return
        }
        itemInsetPairs.append((item, inset ?? defaultItemsMargins))
    }
    
    open func addAction(_ action: ACAlertActionProtocol) {
        guard isBeingPresented == false else {
            print("ACAlertController could not be modified if it is already presented")
            return
        }
        actions.append(action)
    }
    
    // MARK: UIViewController
    public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
//        transitioningDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // WWDC 2014 session 228 "A look inside presentation controllers"
    open override func loadView() {

        view = UIView()
        view.backgroundColor = backgroundColor
        
        let v0 = UIView()
        v0.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        v0.frame = CGRect(x: 100, y: 270, width: 300, height: 100)
        view.addSubview(v0)
//#F9F9D8 
//#E9E9D4
//#EBEBDA
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        blurView.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
        v0.addSubview(blurView)
        
//        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
//        blurView.frame = CGRect(x: 100, y: 250, width: 300, height: 100)
//        view.addSubview(blurView)
        
//        let v1 = UIView()
//        v1.backgroundColor = UIColor.whiteColor()
//        v1.frame = CGRect(x: 50, y: 0, width: 50, height: 400)
//        blurView.addSubview(v1)
//        
//        let v2 = UIView()
//        v2.backgroundColor = UIColor.whiteColor()
//        v2.frame = CGRect(x: 150, y: 0, width: 50, height: 400)
//        blurView.contentView.addSubview(v2)
//        
//        let v3 = UIView()
//        v3.backgroundColor = UIColor.whiteColor()
//        v3.frame = CGRect(x: 250, y: 0, width: 50, height: 400)
//        view.addSubview(v3)
        
//        let v4 = UIView()
//        v4.backgroundColor = UIColor.greenColor()
//        v4.frame = CGRect(x: 100, y: 250, width: 100, height: 50)
//        view.addSubview(v4)
        
        return

//        alertView = addAlertView()
//        return
        
        var itemInsetPairs = self.itemInsetPairs
        if let _ = message { itemInsetPairs.insert((messageLabel, UIEdgeInsets()), at: 0) }
        if let _ = title { itemInsetPairs.insert((titleLabel, UIEdgeInsets()), at: 0) }
        
        var (lastView, nextItemOffset) = addItems(itemInsetPairs)
        lastView = addActions(actions, lastView: lastView, nextItemOffset: nextItemOffset)
        
        if let lastView = lastView {
            NSLayoutConstraint(item: alertView, attribute: .bottomMargin, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        }
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleRecognizer))
        recognizer.minimumPressDuration = 0.0
        recognizer.allowableMovement = CGFloat.greatestFiniteMagnitude
        recognizer.cancelsTouchesInView = false
        recognizer.delegate = self
        alertView.addGestureRecognizer(recognizer)
    }
    
    // MARK: Private methods
    
    fileprivate func addAlertView() -> UIView {
        
//        let alertView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))

        let alertView = UIView()
        view.addSubview(alertView)
        
        alertView.backgroundColor = alertBackgroundColor
        alertView.layoutMargins = viewMargins
        alertView.layer.cornerRadius = cornerRadius
        
        alertView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: alertView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: alertView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: alertView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: alertWidth).isActive = true
        
        NSLayoutConstraint(item: alertView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerRadius * 2).isActive = true
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        alertView.addSubview(blurView)
        alertView.insertSubview(blurView, at: 0)
//        blurView.opaque = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: blurView, attribute: .centerX, relatedBy: .equal, toItem: alertView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: blurView, attribute: .centerY, relatedBy: .equal, toItem: alertView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: blurView, attribute: .width, relatedBy: .equal, toItem: alertView, attribute: .width, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: blurView, attribute: .height, relatedBy: .equal, toItem: alertView, attribute: .height, multiplier: 1, constant: 0).isActive = true
        
//        return blurView.contentView
        return alertView
    }
    
    fileprivate func addHorisontalLine(_ topView: UIView?, nextItemOffset: CGFloat = 0) -> UIView? {
        
        guard let topView = topView else {
            assertionFailure("Error. Seems that addHorisontalLine is called for empty alert.")
            return nil
        }
        
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = alertLinesColor
        
        alertView.addSubview(lineView)
        
        NSLayoutConstraint(item: lineView, attribute: .leading, relatedBy: .equal, toItem: alertView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: lineView, attribute: .trailing, relatedBy: .equal, toItem: alertView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: lineView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0.5).isActive = true
        
        NSLayoutConstraint(item: lineView, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .bottom, multiplier: 1, constant: nextItemOffset).isActive = true
        
        return lineView
    }
    
    fileprivate func addVerticalLine(_ leftView: UIView?) -> UIView? {
        
        guard let leftView = leftView else {
            assertionFailure("Error. Seems that addHorisontalLine is called for empty alert.")
            return nil
        }
        
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = alertLinesColor
        
        alertView.addSubview(lineView)
        
        NSLayoutConstraint(item: lineView, attribute: .leading, relatedBy: .equal, toItem: leftView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: lineView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0.5).isActive = true
        
        NSLayoutConstraint(item: lineView, attribute: .top, relatedBy: .equal, toItem: leftView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: lineView, attribute: .bottom, relatedBy: .equal, toItem: alertView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        return lineView
    }
    
    fileprivate func addItems(_ itemInsetPairs: [(ACAlertItemProtocol, UIEdgeInsets)]) -> (lastView: UIView?, nextItemOffset: CGFloat) {
        
        var lastView: UIView?
        var nextItemOffset: CGFloat = 0
        
        for (item, inset) in itemInsetPairs
        {
            let itemView = item.alertItemView
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            alertView.addSubview(itemView)
            
            NSLayoutConstraint(item: itemView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: alertView, attribute: .leadingMargin, multiplier: 1, constant: inset.left).isActive = true
            
            NSLayoutConstraint(item: itemView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: alertView, attribute: .trailingMargin, multiplier: 1, constant: -inset.right).isActive = true
            
            let centerX = NSLayoutConstraint(item: itemView, attribute: .centerX, relatedBy: .equal, toItem: alertView, attribute: .centerXWithinMargins, multiplier: 1, constant: 0)
            centerX.priority = nonMandatoryConstraintPriority
            centerX.isActive = true
            
            NSLayoutConstraint(item: itemView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: lastView ?? alertView,
                               attribute: lastView == nil ? .topMargin : .bottom,
                               multiplier: 1,
                               constant: nextItemOffset + inset.top).isActive = true
            
            lastView = itemView
            nextItemOffset = inset.bottom
        }
        
        return (lastView, nextItemOffset)
    }
    
    fileprivate func addActions(_ actions: [ACAlertActionProtocol], lastView: UIView?, nextItemOffset: CGFloat = 0) -> UIView? {
        
        var lastView = lastView
        
        if actions.count == 2 {
            let button1 = buttonForAction(actions[0])
            let button2 = buttonForAction(actions[1])
            button1.layoutIfNeeded()
            button2.layoutIfNeeded()
            
            let maxReducedWidth = alertWidth / 2
            if button1.bounds.width < maxReducedWidth && button2.bounds.width < maxReducedWidth
            {
                lastView = addHorisontalLine(lastView, nextItemOffset: nextItemOffset)
                addButton(button1, lastView: lastView, leadingAttr: .leading, trailingAttr: .centerX)
                addButton(button2, lastView: lastView, leadingAttr: .centerX, trailingAttr: .trailing)
                NSLayoutConstraint(item: button1, attribute: .bottom, relatedBy: .equal, toItem: button2, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
                addVerticalLine(button1)
                lastView = button1
            }
            else {
                lastView = addWideActions(actions, lastView: lastView, nextItemOffset: nextItemOffset)
            }
        }
        else {
            lastView = addWideActions(actions, lastView: lastView, nextItemOffset: nextItemOffset)
        }
        
        return lastView
    }
    
    fileprivate func addWideActions(_ actions: [ACAlertActionProtocol], lastView: UIView?, nextItemOffset: CGFloat = 0) -> UIView? {
        
        var lastView = lastView
        var nextItemOffset = nextItemOffset
        
        for action in actions
        {
            lastView = addHorisontalLine(lastView, nextItemOffset: nextItemOffset)
            let button = buttonForAction(action)
            addButton(button, lastView: lastView)
            lastView = button
            nextItemOffset = 0
        }
        
        return lastView
    }
    
    fileprivate func buttonForAction(_ action: ACAlertActionProtocol) -> UIView {
        
        let actionView = action.alertView(tintColor)
        actionView.translatesAutoresizingMaskIntoConstraints = false
        actionView.isUserInteractionEnabled = false
        
        let button = UIView()
        button.layoutMargins = buttonsMargins
        button.addSubview(actionView)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: actionView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: button, attribute: .leadingMargin, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: actionView, attribute: .centerX, relatedBy: .equal, toItem: button, attribute: .centerXWithinMargins, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: actionView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: button, attribute: .topMargin, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: actionView, attribute: .centerY, relatedBy: .equal, toItem: button, attribute: .centerYWithinMargins, multiplier: 1, constant: 0).isActive = true
        
        button2actionDict[button] = action
        
        return button
    }
    
    fileprivate func addButton(_ button: UIView, lastView: UIView?, leadingAttr: NSLayoutAttribute = .leading, trailingAttr: NSLayoutAttribute = .trailing) {
        
        alertView.addSubview(button)
        
        NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: alertView, attribute: leadingAttr, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: alertView, attribute: trailingAttr, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: button,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: lastView ?? alertView,
                           attribute: lastView == nil ? .topMargin : .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        
        let height = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: defaultButtonHeight)
        height.priority = nonMandatoryConstraintPriority
        height.isActive = true
    }

    fileprivate func callAction(_ action: ACAlertActionProtocol) {

        presentingViewController?.dismiss(animated: true, completion: {
            DispatchQueue.main.async(execute: {
                action.call()
            })
        })
    }
    
// MARK: Touch recogniser
    @objc fileprivate func handleRecognizer(_ recognizer: ACTouchGestureRecognizer) {
        
        print(recognizer.state.rawValue)
        let point = recognizer.location(in: alertView)
        
        for (button, action) in button2actionDict
        {
            let isActive = button.frame.contains(point) && action.enabled
            let isHighlighted = isActive && (recognizer.state == .began || recognizer.state == .changed)
            
            button.backgroundColor = isHighlighted ? buttonHighlightColor : buttonColor
            action.highlight(isHighlighted)
            
            if isActive && recognizer.state == .ended {
                callAction(action)
            }
        }
    }
}

extension ACAlertController: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
        return ACAlertControllerAnimatedTransitioning(appearing: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
        return ACAlertControllerAnimatedTransitioning(appearing: false)
    }
}

extension ACAlertController: UIGestureRecognizerDelegate {
    
    // note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        print("shouldRecognizeSimultaneouslyWithGestureRecognizer \n\(gestureRecognizer)\n\(otherGestureRecognizer)")
        return true
    }
    
//    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        let point = gestureRecognizer.locationInView(alertView)
//        let subview = alertView.hitTest(point, withEvent: nil) as? UIControl
//        return subview == nil
//    }

    // called once per attempt to recognize, so failure requirements can be determined lazily and may be set up between recognizers across view hierarchies
    // return YES to set up a dynamic failure requirement between gestureRecognizer and otherGestureRecognizer
    //
    // note: returning YES is guaranteed to set up the failure requirement. returning NO does not guarantee that there will not be a failure requirement as the other gesture's counterpart delegate or subclass methods may return YES
//    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        print("shouldRequireFailureOfGestureRecognizer \n\(gestureRecognizer)\n\(otherGestureRecognizer)")
//        return true
//    }
//
//    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        print("shouldBeRequiredToFailByGestureRecognizer\n\(gestureRecognizer)\n\(otherGestureRecognizer)")
//        return true
//    }

}

