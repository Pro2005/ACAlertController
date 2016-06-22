//
//  AlertController.swift
//  CustomizableAlertController
//
//  Created by Yury on 17/06/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

// MARK: Protocols and Extensions

public protocol ACAlertItem {
    
    var alertItemView: UIView { get }
}

public protocol ACAlertActionProtocol {
    
    func alertView(tintColor: UIColor) -> UIView
    func highlight(isHighlited: Bool)
    func call() -> Void
    var enabled: Bool { get }
}

extension UIView: ACAlertItem {
    
    public var alertItemView: UIView { return self }
}

extension ACAlertActionProtocol {
    
    public var enabled: Bool { return true }
    public func highlight(isHighlited: Bool) { }
}

// MARK: - UIAlertController compatibility

extension ACAlertController {
    
    override public var title: String? {
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
public class ACAlertController : UIViewController {

    // MARK: Properties
    
    private(set) public var itemInsetPairs: [(ACAlertItem, UIEdgeInsets)] = []
    public var items: [ACAlertItem] { return itemInsetPairs.map{ $0.0 } }
    private(set) public var actions: [ACAlertActionProtocol] = []
    
    public var tintColor = UIColor.blueColor()
    public var alertBackgroundColor = UIColor(white: 248/256, alpha: 1)
    public var alertLinesColor = UIColor(red:220/256, green:220/256, blue:224/256, alpha:1.0)
    public var backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.5)
    public var buttonColor = UIColor.clearColor()
    public var buttonHighlightColor = UIColor(white: 0.9, alpha: 1)
    
    public var viewMargins = UIEdgeInsets(top: 15, left: 8, bottom: 15, right: 8) // Applied to items and top/bottom margins of alert view
    public var buttonsMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8) // Applied to buttons
    public var defaultItemsMargins = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0) // Applied to items
    
    public var cornerRadius: CGFloat = 16
    public var defaultButtonHeight: CGFloat = 45
    public var alertWidth: CGFloat = 270
    
    public var nonMandatoryConstraintPriority: UILayoutPriority = 900 // Item's and action's constraints that could conflict with ACAlertController constraints should have priorities in [nonMandatoryConstraintPriority ..< 1000] range.

    
    // MARK: Private properties
    
    private var alertView: UIView!
    private var button2actionDict: [UIView: ACAlertActionProtocol] = [:]
    
    // UIAlertController compatibility
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFontOfSize(17)
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(15)
        return label
    }()
    
    
    
    // MARK: Public methods
    public func addItem(item: ACAlertItem, inset: UIEdgeInsets? = nil) {
        guard isBeingPresented() == false else {
            print("ACAlertController could not be modified if it is already presented")
            return
        }
        itemInsetPairs.append((item, inset ?? defaultItemsMargins))
    }
    
    public func addAction(action: ACAlertActionProtocol) {
        guard isBeingPresented() == false else {
            print("ACAlertController could not be modified if it is already presented")
            return
        }
        actions.append(action)
    }
    
    // MARK: UIViewController
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {

        view = UIView()
        view.backgroundColor = backgroundColor
        
        alertView = addAlertView()
        
        var itemInsetPairs = self.itemInsetPairs
        if let _ = message { itemInsetPairs.insert((messageLabel, UIEdgeInsets()), atIndex: 0) }
        if let _ = title { itemInsetPairs.insert((titleLabel, UIEdgeInsets()), atIndex: 0) }
        
        var (lastView, nextItemOffset) = addItems(itemInsetPairs)
        lastView = addActions(actions, lastView: lastView, nextItemOffset: nextItemOffset)
        
        if let lastView = lastView {
            NSLayoutConstraint(item: alertView, attribute: .BottomMargin, relatedBy: .Equal, toItem: lastView, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        }
        
        alertView.addGestureRecognizer(ACTouchGestureRecogniser(target: self, action: #selector(handlePanRecognizer)))
    }
    
    // MARK: Private methods
    
    private func addAlertView() -> UIView {
        
        let alertView = UIView()
        view.addSubview(alertView)
        
        alertView.backgroundColor = alertBackgroundColor
        alertView.layoutMargins = viewMargins
        alertView.layer.cornerRadius = cornerRadius
        
        alertView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: alertView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: alertView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: alertView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: alertWidth).active = true
        
        NSLayoutConstraint(item: alertView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: cornerRadius * 2).active = true
        
        return alertView
    }
    
    private func addHorisontalLine(topView: UIView?, nextItemOffset: CGFloat = 0) -> UIView? {
        
        guard let topView = topView else {
            assertionFailure("Error. Seems that addHorisontalLine is called for empty alert.")
            return nil
        }
        
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = alertLinesColor
        
        alertView.addSubview(lineView)
        
        NSLayoutConstraint(item: lineView, attribute: .Leading, relatedBy: .Equal, toItem: alertView, attribute: .Leading, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: lineView, attribute: .Trailing, relatedBy: .Equal, toItem: alertView, attribute: .Trailing, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: lineView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0.5).active = true
        
        NSLayoutConstraint(item: lineView, attribute: .Top, relatedBy: .Equal, toItem: topView, attribute: .Bottom, multiplier: 1, constant: nextItemOffset).active = true
        
        return lineView
    }
    
    private func addVerticalLine(leftView: UIView?) -> UIView? {
        
        guard let leftView = leftView else {
            assertionFailure("Error. Seems that addHorisontalLine is called for empty alert.")
            return nil
        }
        
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = alertLinesColor
        
        alertView.addSubview(lineView)
        
        NSLayoutConstraint(item: lineView, attribute: .Leading, relatedBy: .Equal, toItem: leftView, attribute: .Trailing, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: lineView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0.5).active = true
        
        NSLayoutConstraint(item: lineView, attribute: .Top, relatedBy: .Equal, toItem: leftView, attribute: .Top, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: lineView, attribute: .Bottom, relatedBy: .Equal, toItem: alertView, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        
        return lineView
    }
    
    private func addItems(itemInsetPairs: [(ACAlertItem, UIEdgeInsets)]) -> (lastView: UIView?, nextItemOffset: CGFloat) {
        
        var lastView: UIView?
        var nextItemOffset: CGFloat = 0
        
        for (item, inset) in itemInsetPairs
        {
            let itemView = item.alertItemView
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            alertView.addSubview(itemView)
            
            NSLayoutConstraint(item: itemView, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: alertView, attribute: .LeadingMargin, multiplier: 1, constant: inset.left).active = true
            
            NSLayoutConstraint(item: itemView, attribute: .Trailing, relatedBy: .LessThanOrEqual, toItem: alertView, attribute: .TrailingMargin, multiplier: 1, constant: -inset.right).active = true
            
            let centerX = NSLayoutConstraint(item: itemView, attribute: .CenterX, relatedBy: .Equal, toItem: alertView, attribute: .CenterXWithinMargins, multiplier: 1, constant: 0)
            centerX.priority = nonMandatoryConstraintPriority
            centerX.active = true
            
            NSLayoutConstraint(item: itemView,
                               attribute: .Top,
                               relatedBy: .Equal,
                               toItem: lastView ?? alertView,
                               attribute: lastView == nil ? .TopMargin : .Bottom,
                               multiplier: 1,
                               constant: nextItemOffset + inset.top).active = true
            
            lastView = itemView
            nextItemOffset = inset.bottom
        }
        
        return (lastView, nextItemOffset)
    }
    
    private func addActions(actions: [ACAlertActionProtocol], lastView: UIView?, nextItemOffset: CGFloat = 0) -> UIView? {
        
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
                addButton(button1, lastView: lastView, leadingAttr: .Leading, trailingAttr: .CenterX)
                addButton(button2, lastView: lastView, leadingAttr: .CenterX, trailingAttr: .Trailing)
                NSLayoutConstraint(item: button1, attribute: .Bottom, relatedBy: .Equal, toItem: button2, attribute: .Bottom, multiplier: 1, constant: 0).active = true
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
    
    private func addWideActions(actions: [ACAlertActionProtocol], lastView: UIView?, nextItemOffset: CGFloat = 0) -> UIView? {
        
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
    
    private func buttonForAction(action: ACAlertActionProtocol) -> UIView {
        
        let actionView = action.alertView(tintColor)
        actionView.translatesAutoresizingMaskIntoConstraints = false
        actionView.userInteractionEnabled = false
        
        let button = UIView()
        button.layoutMargins = buttonsMargins
        button.addSubview(actionView)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: actionView, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: button, attribute: .LeadingMargin, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: actionView, attribute: .CenterX, relatedBy: .Equal, toItem: button, attribute: .CenterXWithinMargins, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: actionView, attribute: .Top, relatedBy: .GreaterThanOrEqual, toItem: button, attribute: .TopMargin, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: actionView, attribute: .CenterY, relatedBy: .Equal, toItem: button, attribute: .CenterYWithinMargins, multiplier: 1, constant: 0).active = true
        
        button2actionDict[button] = action
        
        return button
    }
    
    private func addButton(button: UIView, lastView: UIView?, leadingAttr: NSLayoutAttribute = .Leading, trailingAttr: NSLayoutAttribute = .Trailing) {
        
        alertView.addSubview(button)
        
        NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: alertView, attribute: leadingAttr, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: alertView, attribute: trailingAttr, multiplier: 1, constant: 0).active = true
        
        NSLayoutConstraint(item: button,
                           attribute: .Top,
                           relatedBy: .Equal,
                           toItem: lastView ?? alertView,
                           attribute: lastView == nil ? .TopMargin : .Bottom,
                           multiplier: 1,
                           constant: 0).active = true
        
        let height = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: defaultButtonHeight)
        height.priority = nonMandatoryConstraintPriority
        height.active = true
    }

    private func callAction(action: ACAlertActionProtocol) {

        presentingViewController?.dismissViewControllerAnimated(true, completion: {
            dispatch_async(dispatch_get_main_queue(), {
                action.call()
            })
        })
    }
    
// MARK: Touch recogniser
    @objc private func handlePanRecognizer(recognizer: UIPanGestureRecognizer) {
        
        let point = recognizer.locationInView(alertView)
        
        for (button, action) in button2actionDict
        {
            let isActive = button.frame.contains(point)
            let isHighlighted = isActive && (recognizer.state == .Began || recognizer.state == .Changed)
            
            button.backgroundColor = isHighlighted ? buttonHighlightColor : buttonColor
            action.highlight(isHighlighted)
            
            if isActive && recognizer.state == .Ended {
                callAction(action)
            }
        }
    }
}

extension ACAlertController: UIViewControllerTransitioningDelegate {

    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ACAlertContollerAnimatedTransitioning()
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ACAlertContollerAnimatedTransitioning(appearing: false)
    }
}

// MARK: -

public class ACAlertAction<T:UIView>: ACAlertActionProtocol {
    
    public let alertView: T
    public let handler: ((ACAlertAction<T>) -> Void)?
    
    public init(view: T, handler: ((ACAlertAction<T>) -> Void)?) {
        self.alertView = view
        self.handler = handler
    }
    
    public func alertView(tintColor: UIColor) -> UIView {
        return alertView
    }
    
    public func call() {
        handler?(self)
    }
}

public class ACAlertActionNative: ACAlertActionProtocol {
    
    public let handler: ((ACAlertActionNative) -> Void)?
    
    public let title: String?
    public let style: UIAlertActionStyle
    public var enabled: Bool = true
    
    public init(title: String?, style: UIAlertActionStyle, handler: ((ACAlertActionNative) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    public func alertView(tintColor: UIColor) -> UIView {
        let label = UILabel()
        
        let fontSize: CGFloat = 17
        label.font = style == .Cancel ? UIFont.boldSystemFontOfSize(fontSize) :  UIFont.systemFontOfSize(fontSize)
        label.minimumScaleFactor = 0.5
        
        let normalColor = enabled ? tintColor : UIColor.grayColor()
        label.textColor = style == .Destructive ? UIColor.redColor() : normalColor
        
        label.text = title
        
        return label
    }
    
    public func call() {
        handler?(self)
    }
}
