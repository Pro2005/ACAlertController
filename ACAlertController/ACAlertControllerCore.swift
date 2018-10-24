//
//  ACAlertControllerCore.swift
//  ACAlertControllerDemo
//
//  Created by Yury on 21/09/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

public var alertLinesColor = UIColor(red:220/256, green:220/256, blue:224/256, alpha:1.0)

public protocol ACAlertListViewProtocol {
    var contentHeight: CGFloat { get }
    var view: UIView { get }
}

public protocol ACAlertListViewProvider {
    func set(alertView: UIView, itemsView: UIView?, actionsView: UIView?, callBlock: @escaping (ACAlertActionProtocolBase) -> Void) -> Void
    func alertView(items : [ACAlertItemProtocol], width: CGFloat) -> ACAlertListViewProtocol
    func alertView(actions : [ACAlertActionProtocolBase], width: CGFloat) -> ACAlertListViewProtocol
}

open class StackViewProvider: NSObject, ACAlertListViewProvider, UIGestureRecognizerDelegate {

    open func alertView(items: [ACAlertItemProtocol], width: CGFloat) -> ACAlertListViewProtocol {
        let views = items.map { $0.alertItemView }
        
        return ACStackAlertListView(views: views, width: width)
    }
    
    open func alertView(actions: [ACAlertActionProtocolBase], width: CGFloat) -> ACAlertListViewProtocol {
        
        buttonsAndActions = actions.map { (buttonView(action: $0), $0) }
        let views = buttonsAndActions.map { $0.0 }
        
        if views.count == 2 {
            let button1 = views[0]
            let button2 = views[1]
            button1.layoutIfNeeded()
            button2.layoutIfNeeded()
            
            let maxReducedWidth = (width - 1) / 2
            if button1.bounds.width < maxReducedWidth && button2.bounds.width < maxReducedWidth
            {
                Layout.set(width: maxReducedWidth, view: button1)
                Layout.set(width: maxReducedWidth, view: button2)
                return ACStackAlertListView3(views: [button1, separatorView2(), button2], width: width)
            }
        }
        
        let views2 = views.flatMap { [$0, separatorView()] }.dropLast()
        return ACStackAlertListView2(views: Array(views2), width: width)
    }
    
    open var actionsView: UIView!
    open var callBlock:((ACAlertActionProtocolBase) -> Void)!
    
    open func set(alertView: UIView, itemsView: UIView?, actionsView: UIView?, callBlock:@escaping (ACAlertActionProtocolBase) -> Void) -> Void {

        self.actionsView = actionsView
        self.callBlock = callBlock
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleRecognizer))
        recognizer.minimumPressDuration = 0.0
        recognizer.allowableMovement = CGFloat.greatestFiniteMagnitude
        recognizer.cancelsTouchesInView = false
        recognizer.delegate = self
        
        if let superRecognizers = actionsView?.gestureRecognizers {
            for r in superRecognizers {
                recognizer.require(toFail: r)
            }
        }
        if let superRecognizers = itemsView?.gestureRecognizers {
            for r in superRecognizers {
                recognizer.require(toFail: r)
            }
        }
        
        alertView.addGestureRecognizer(recognizer)
    }
    
    open var buttonsAndActions: [(UIView, ACAlertActionProtocolBase)] = []
    open var buttonHighlightColor = UIColor(white: 0.9, alpha: 1)
    
    // MARK: Touch recogniser
    @objc open func handleRecognizer(_ recognizer: UILongPressGestureRecognizer) {
        
        let point = recognizer.location(in: actionsView)
        
        for (button, action) in buttonsAndActions
        {
            let isActive = button.frame.contains(point) && action.enabled
            let isHighlighted = isActive && (recognizer.state == .began || recognizer.state == .changed)
            
            button.backgroundColor = isHighlighted ? buttonHighlightColor : UIColor.clear
            action.highlight(isHighlighted)
            
            if isActive && recognizer.state == .ended {
                callBlock(action)
            }
        }
    }

    open var buttonsMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8) // Applied to buttons
    open var defaultButtonHeight: CGFloat = 45
    
    open func buttonView(action: ACAlertActionProtocolBase) -> UIView {
        
        let actionView = action.alertView
        actionView.translatesAutoresizingMaskIntoConstraints = false
        actionView.isUserInteractionEnabled = false
        
        let button = UIView()
        button.layoutMargins = buttonsMargins
        button.addSubview(actionView)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        Layout.setInCenter(view: button, subview: actionView, margins: true)
        Layout.setOptional(height: defaultButtonHeight, view: button)
        
        return button
    }
    
    open func separatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = alertLinesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        Layout.set(height: 0.5, view: view)
        return view
    }

    open func separatorView2() -> UIView {
        let view = UIView()
        view.backgroundColor = alertLinesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        Layout.set(width: 0.5, view: view)
        return view
    }
}

open class ACStackAlertListView: ACAlertListViewProtocol {
    public var view: UIView { return scrollView }
    public var contentHeight: CGFloat
    
    public let stackView: UIStackView
    public let scrollView = UIScrollView()
    
    open var margins = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    
    public init(views: [UIView], width: CGFloat) {

        stackView = UIStackView(arrangedSubviews: views )
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        Layout.setEqual(view:scrollView, subview: stackView, margins: false)
        Layout.set(width: width, view: stackView)
        
        stackView.layoutMargins = margins
        stackView.isLayoutMarginsRelativeArrangement = true
        contentHeight = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
}

public class ACStackAlertListView2: ACAlertListViewProtocol {
    public var view: UIView { return scrollView }
    public var contentHeight: CGFloat
    
    public let stackView: UIStackView
    public let scrollView = UIScrollView()
    
    public var margins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    public init(views: [UIView], width: CGFloat) {
        
        stackView = UIStackView(arrangedSubviews: views )
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        Layout.setEqual(view:scrollView, subview: stackView, margins: false)
        Layout.set(width: width, view: stackView)
        
        stackView.layoutMargins = margins
        stackView.isLayoutMarginsRelativeArrangement = true
        contentHeight = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
}

public class ACStackAlertListView3: ACAlertListViewProtocol {
    public var view: UIView { return scrollView }
    public var contentHeight: CGFloat
    
    public let stackView: UIStackView
    public let scrollView = UIScrollView()
    
    public var margins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    public init(views: [UIView], width: CGFloat) {
        
        stackView = UIStackView(arrangedSubviews: views )
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        Layout.setEqual(view:scrollView, subview: stackView, margins: false)
        Layout.set(width: width, view: stackView)
        
        stackView.layoutMargins = margins
        stackView.isLayoutMarginsRelativeArrangement = true
        contentHeight = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
}

open class ACAlertController : UIViewController{

    fileprivate(set) open var items: [ACAlertItemProtocol] = []
    fileprivate(set) open var actions: [ACAlertActionProtocolBase] = []
    
//    open var items: [ACAlertItemProtocol] { return items.map{ $0.0 } }
//    fileprivate(set) open var actions: [ACAlertActionProtocol] = []
    
    open var backgroundColor = UIColor(white: 250/256, alpha: 1)
    
    open var viewMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)//UIEdgeInsets(top: 15, bottom: 15)
//    open var defaultItemsMargins = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0) // Applied to items
//    open var itemsMargins = UIEdgeInsets(top: 4, bottom: 4)
//    open var actionsMargins = UIEdgeInsets(top: 4, bottom: 4)
    
    open var alertWidth: CGFloat = 270
    open var cornerRadius: CGFloat = 16
    open var separatorHeight: CGFloat = 0.5
    
    open var alertListsProvider: ACAlertListViewProvider = StackViewProvider()
    
    open var itemsAlertList: ACAlertListViewProtocol?
    open var actionsAlertList: ACAlertListViewProtocol?
    
    open var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = alertLinesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Public methods
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func addItem(_ item: ACAlertItemProtocol) {
        guard isBeingPresented == false else {
            print("ACAlertController could not be modified if it is already presented")
            return
        }
        items.append(item)
    }
    
    open func addAction(_ action: ACAlertActionProtocolBase) {
        guard isBeingPresented == false else {
            print("ACAlertController could not be modified if it is already presented")
            return
        }
        actions.append(action)
    }
    
    override open func loadView() {
        view = UIView()
        view.backgroundColor = backgroundColor
        view.layer.cornerRadius = cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        Layout.set(width: alertWidth, view: view)
        
        // Is needed because of layoutMargins http://stackoverflow.com/questions/27421469/setting-layoutmargins-of-uiview-doesnt-work
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.layoutMargins = viewMargins
        contentView.translatesAutoresizingMaskIntoConstraints = false
        Layout.setEqual(view: view, subview: contentView, margins: false)
        
        setContentView(view: contentView)
    }
    
    open func setContentView(view: UIView) {
        
        if hasItems {
            itemsAlertList = alertListsProvider.alertView(items: items, width: alertWidth - viewMargins.leftPlusRight)
        }
        if hasActions {
            actionsAlertList = alertListsProvider.alertView(actions: actions, width: alertWidth - viewMargins.leftPlusRight)
        }
        
        let (height1, height2) = elementsHeights()
        if let h = height1, let v = itemsAlertList?.view {
            Layout.set(height: h, view: v)
        }
        if let h = height2, let v = actionsAlertList?.view {
            Layout.set(height: h, view: v)
        }
        
        if let topSubview = itemsAlertList?.view ?? actionsAlertList?.view {
            view.addSubview(topSubview)
            
            Layout.setEqualTop(view: view, subview: topSubview, margins: true)
            Layout.setEqualLeftAndRight(view: view, subview: topSubview, margins: true)
            
            if let bottomSubview = actionsAlertList?.view, bottomSubview !== topSubview {
                view.addSubview(separatorView)

                Layout.setBottomToTop(topView: topSubview, bottomView: separatorView)
                Layout.setEqualLeftAndRight(view: view, subview: separatorView, margins: true)
                Layout.set(height: separatorHeight, view: separatorView)

                view.addSubview(bottomSubview)

                Layout.setBottomToTop(topView: separatorView, bottomView: bottomSubview)
                Layout.setEqualLeftAndRight(view: view, subview: bottomSubview, margins: true)
                Layout.setEqualBottom(view: view, subview: bottomSubview, margins: true)
                
            } else {
                Layout.setEqualBottom(view: view, subview: topSubview, margins: true)
            }
        }
        
        alertListsProvider.set(alertView: view, itemsView: itemsAlertList?.view, actionsView: actionsAlertList?.view) { (action) in
            self.presentingViewController?.dismiss(animated: true, completion: {
                DispatchQueue.main.async(execute: {
                    action.call()
                })
            })
        }
    }
    
    open var hasItems: Bool { return items.count > 0 }
    open var hasActions: Bool { return actions.count > 0 }
    open var maxViewHeight: CGFloat { return UIScreen.main.bounds.height - 80 }
    
    open func elementsHeights() -> (itemsHeight: CGFloat?, actionsHeight: CGFloat?) {
        let max = maxViewHeight - viewMargins.topPlusBottom
        
        switch (itemsAlertList?.contentHeight, actionsAlertList?.contentHeight) {
        case (nil, nil):
            return (nil, nil)
            
        case (.some(let height1), nil):
            return (min(height1, max), nil)
            
        case (nil, .some(let height2)):
            return (nil, min(height2, max))
            
        case (.some(let height1), .some(let height2)):
            let max2 = max - separatorHeight
            
            if max2 >= height1 + height2 {
                return (height1, height2)
            } else if height1 < max2 * 0.75 {
                return (height1, max2 - height1)
            } else if height2 < max2 * 0.75 {
                return (max2 - height2, height2)
            }
            return (max2 / 2, max2 / 2)
        }
    }
}

extension ACAlertController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ACAlertControllerAnimatedTransitioningBase(appearing: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ACAlertControllerAnimatedTransitioningBase(appearing: false)
    }
}

public class Layout {
    
    public static var nonMandatoryConstraintPriority: UILayoutPriority = UILayoutPriority(rawValue: 700) // Item's and action's constraints that could conflict with ACAlertController constraints should have priorities in [nonMandatoryConstraintPriority ..< 1000] range.
    
    public class func set(width: CGFloat, view: UIView) {
        
        NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width).isActive = true
    }
    
    public class func set(height: CGFloat, view: UIView) {
        
        NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height).isActive = true
    }

    public class func setOptional(height: CGFloat, view: UIView) {
        
        let constraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        constraint.priority = nonMandatoryConstraintPriority
        constraint.isActive = true
    }
    
    public class func setOptional(width: CGFloat, view: UIView) {
        
        let constraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
        constraint.priority = nonMandatoryConstraintPriority
        constraint.isActive = true
    }
    
    public class func setInCenter(view: UIView, subview: UIView, margins: Bool) {
        
        NSLayoutConstraint(item: view, attribute: margins ? .leadingMargin : .leading, relatedBy: .lessThanOrEqual, toItem: subview, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: margins ? .trailingMargin : .trailing, relatedBy: .greaterThanOrEqual, toItem: subview, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: margins ? .topMargin : .top, relatedBy: .lessThanOrEqual, toItem: subview, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: margins ? .bottomMargin : .bottom, relatedBy: .greaterThanOrEqual, toItem: subview, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        let centerX = NSLayoutConstraint(item: view, attribute: margins ? .centerXWithinMargins : .centerX, relatedBy: .equal, toItem: subview, attribute: .centerX, multiplier: 1, constant: 0)
        centerX.priority = nonMandatoryConstraintPriority
        centerX.isActive = true
        
        let centerY = NSLayoutConstraint(item: view, attribute: margins ? .centerYWithinMargins : .centerY, relatedBy: .equal, toItem: subview, attribute: .centerY, multiplier: 1, constant: 0)
        centerY.priority = nonMandatoryConstraintPriority
        centerY.isActive = true
    }
    
    public class func setEqual(view: UIView, subview: UIView, margins: Bool) {
        
        NSLayoutConstraint(item: view, attribute: margins ? .leftMargin : .left, relatedBy: .equal, toItem: subview, attribute: .left, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: margins ? .rightMargin : .right, relatedBy: .equal, toItem: subview, attribute: .right, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: margins ? .topMargin : .top, relatedBy: .equal, toItem: subview, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: margins ? .bottomMargin: .bottom, relatedBy: .equal, toItem: subview, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }

    public class func setEqualLeftAndRight(view: UIView, subview: UIView, margins: Bool) {
        
        NSLayoutConstraint(item: view, attribute: margins ? .leftMargin : .left, relatedBy: .equal, toItem: subview, attribute: .left, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: margins ? .rightMargin : .right, relatedBy: .equal, toItem: subview, attribute: .right, multiplier: 1, constant: 0).isActive = true
    }
    
    public class func setEqualTop(view: UIView, subview: UIView, margins: Bool) {
        NSLayoutConstraint(item: view, attribute: margins ? .topMargin : .top, relatedBy: .equal, toItem: subview, attribute: .top, multiplier: 1, constant: 0).isActive = true
    }
    
    public class func setEqualBottom(view: UIView, subview: UIView, margins: Bool) {
        
        NSLayoutConstraint(item: view, attribute: margins ? .bottomMargin : .bottom, relatedBy: .equal, toItem: subview, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    public class func setBottomToTop(topView: UIView, bottomView: UIView) {
        
        NSLayoutConstraint(item: topView, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1, constant: 0).isActive = true
    }
}

public extension UIEdgeInsets {
    public var topPlusBottom: CGFloat { return top + bottom }
    public var leftPlusRight: CGFloat { return left + right }
    public init(top: CGFloat, bottom: CGFloat) {
        self.init(top: top, left: 0, bottom: bottom, right: 0)
    }
}

