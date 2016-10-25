//
//  ACAlertControllerCore.swift
//  ACAlertControllerDemo
//
//  Created by Yury on 21/09/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

extension UIEdgeInsets {
    var topPlusBottom: CGFloat { return top + bottom }
    var leftPlusRight: CGFloat { return left + right }
    init(top: CGFloat, bottom: CGFloat) {
        self.init(top: top, left: 0, bottom: bottom, right: 0)
    }
}

protocol ACAlertListViewProtocol {
    var contentHeight: CGFloat { get }
    var view: UIView { get }
}

protocol ACAlertListViewProvider {
    func alertView(items : [(ACAlertItemProtocol, UIEdgeInsets)], width: CGFloat) -> ACAlertListViewProtocol
    func alertView(actions : [(ACAlertActionProtocolBase, UIEdgeInsets?)], width: CGFloat) -> ACAlertListViewProtocol
}

class ACAlertListView: ACAlertListViewProtocol {

    var contentHeight: CGFloat = 0
    var view: UIView = UIView()
    
    init(height: CGFloat, color: UIColor) {
        contentHeight = height
        view.backgroundColor = color
        view.translatesAutoresizingMaskIntoConstraints = false
    }
}

class TabledItemsViewProvider: NSObject, ACAlertListViewProvider {
    func alertView(items: [(ACAlertItemProtocol, UIEdgeInsets)], width: CGFloat) -> ACAlertListViewProtocol {
        let views = items.map { (item, insets) in return (item.alertItemView, insets) }
        
        return ACStackAlertListView(views: views, width: width)
    }
    func alertView(actions: [(ACAlertActionProtocolBase, UIEdgeInsets?)], width: CGFloat) -> ACAlertListViewProtocol {
        return ACAlertListView(height: CGFloat(actions.count) * 45, color: UIColor.orange)
    }
    
    open var buttonsMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8) // Applied to buttons
    
    fileprivate func buttonView(action: ACAlertActionProtocolBase) -> UIView {
        
        let actionView = action.alertView
        actionView.translatesAutoresizingMaskIntoConstraints = false
        actionView.isUserInteractionEnabled = false
        
        let button = UIView()
        button.layoutMargins = buttonsMargins
        button.addSubview(actionView)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        Layout.setInCenter(view: button, subview: actionView, margins: true)
        Layout.setOptional(height: 45, view: actionView)
        
        return button
    }
}

class ACStackAlertListView: ACAlertListViewProtocol {
    var view: UIView { return scrollView }
    var contentHeight: CGFloat
    
    let stackView: UIStackView
    let scrollView = UIScrollView()
    
    var margins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    
    init(views: [(UIView, UIEdgeInsets)], width: CGFloat) {

        stackView = UIStackView(arrangedSubviews: views.map { $0.0 } )
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
        contentHeight = stackView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
}

class ACAlertControllerBase : UIViewController{

    fileprivate(set) open var items: [(ACAlertItemProtocol, UIEdgeInsets)] = []
    fileprivate(set) open var actions: [(ACAlertActionProtocolBase, UIEdgeInsets?)] = []
    
//    open var items: [ACAlertItemProtocol] { return items.map{ $0.0 } }
//    fileprivate(set) open var actions: [ACAlertActionProtocol] = []
    
    open var backgroundColor = UIColor.brown//UIColor.white.withAlphaComponent(0.25)
    
    open var viewMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)//UIEdgeInsets(top: 15, bottom: 15)
    open var defaultItemsMargins = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0) // Applied to items
//    open var itemsMargins = UIEdgeInsets(top: 4, bottom: 4)
//    open var actionsMargins = UIEdgeInsets(top: 4, bottom: 4)
    
    open var alertWidth: CGFloat = 270
    open var cornerRadius: CGFloat = 16
    var separatorHeight: CGFloat = 0.5
    
    var alertListsProvider: ACAlertListViewProvider = TabledItemsViewProvider()
    
    var itemsAlertList: ACAlertListViewProtocol?
    var actionsAlertList: ACAlertListViewProtocol?
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.yellow
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Public methods
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        //        transitioningDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func addItem(_ item: ACAlertItemProtocol, inset: UIEdgeInsets? = nil) {
        guard isBeingPresented == false else {
            print("ACAlertController could not be modified if it is already presented")
            return
        }
        items.append((item, inset ?? defaultItemsMargins))
    }
    
    open func addAction(_ action: ACAlertActionProtocolBase, inset: UIEdgeInsets? = nil) {
        guard isBeingPresented == false else {
            print("ACAlertController could not be modified if it is already presented")
            return
        }
        actions.append(action, inset)
    }
    
    override func loadView() {
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
    
    func setContentView(view: UIView) {
        
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
    }
    
    var hasItems: Bool { return items.count > 0 }
    var hasActions: Bool { return actions.count > 0 }
    var maxViewHeight: CGFloat { return UIScreen.main.bounds.height - 80 }
    
    func elementsHeights() -> (itemsHeight: CGFloat?, actionsHeight: CGFloat?) {
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

class Layout {
    
    open static var nonMandatoryConstraintPriority: UILayoutPriority = 900 // Item's and action's constraints that could conflict with ACAlertController constraints should have priorities in [nonMandatoryConstraintPriority ..< 1000] range.
    
    class func set(width: CGFloat, view: UIView) {
        
        NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width).isActive = true
    }
    
    class func set(height: CGFloat, view: UIView) {
        
        NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height).isActive = true
    }

    class func setOptional(height: CGFloat, view: UIView) {
        
        let constraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        constraint.priority = nonMandatoryConstraintPriority
        constraint.isActive = true
    }
    
    class func setInCenter(view: UIView, subview: UIView, margins: Bool) {
        
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
    
    class func setEqual(view: UIView, subview: UIView, margins: Bool) {
        
        NSLayoutConstraint(item: view, attribute: margins ? .leftMargin : .left, relatedBy: .equal, toItem: subview, attribute: .left, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: margins ? .rightMargin : .right, relatedBy: .equal, toItem: subview, attribute: .right, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: margins ? .topMargin : .top, relatedBy: .equal, toItem: subview, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: margins ? .bottomMargin: .bottom, relatedBy: .equal, toItem: subview, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }

    class func setEqualLeftAndRight(view: UIView, subview: UIView, margins: Bool) {
        
        NSLayoutConstraint(item: view, attribute: margins ? .leftMargin : .left, relatedBy: .equal, toItem: subview, attribute: .left, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: view, attribute: margins ? .rightMargin : .right, relatedBy: .equal, toItem: subview, attribute: .right, multiplier: 1, constant: 0).isActive = true
    }
    
    class func setEqualTop(view: UIView, subview: UIView, margins: Bool) {
        NSLayoutConstraint(item: view, attribute: margins ? .topMargin : .top, relatedBy: .equal, toItem: subview, attribute: .top, multiplier: 1, constant: 0).isActive = true
    }
    
    class func setEqualBottom(view: UIView, subview: UIView, margins: Bool) {
        
        NSLayoutConstraint(item: view, attribute: margins ? .bottomMargin : .bottom, relatedBy: .equal, toItem: subview, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    class func setBottomToTop(topView: UIView, bottomView: UIView) {
        
        NSLayoutConstraint(item: topView, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1, constant: 0).isActive = true
    }
}
