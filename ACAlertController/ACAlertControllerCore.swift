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
    func alertView(actions : [(ACAlertActionProtocol, UIEdgeInsets?)], width: CGFloat) -> ACAlertListViewProtocol
}

class ACAlertListView: ACAlertListViewProtocol {

    var contentHeight: CGFloat = 0
    var view: UIView = UIView()
    
    init(height: CGFloat, color: UIColor) {
        contentHeight = height
        view.backgroundColor = color
    }
}

class TabledItemsViewProvider: NSObject, ACAlertListViewProvider {
    func alertView(items: [(ACAlertItemProtocol, UIEdgeInsets)], width: CGFloat) -> ACAlertListViewProtocol {
        let views = items.map { (item, insets) in return (item.alertItemView, insets) }
//        return ACAlertListView(height: CGFloat(items.count) * 30, color: UIColor.green)
    }
    func alertView(actions: [(ACAlertActionProtocol, UIEdgeInsets?)], width: CGFloat) -> ACAlertListViewProtocol {
        return ACAlertListView(height: CGFloat(actions.count) * 45, color: UIColor.orange)
    }
}



    }
    }
    

    }
    }
}

class ACAlertControllerBase : UIViewController{

    fileprivate(set) open var items: [(ACAlertItemProtocol, UIEdgeInsets)] = []
    fileprivate(set) open var actions: [(ACAlertActionProtocol, UIEdgeInsets?)] = []
    
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
    
    open func addAction(_ action: ACAlertActionProtocol, inset: UIEdgeInsets? = nil) {
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
        set(width: alertWidth, view: view)
        
        // Is needed because of layoutMargins http://stackoverflow.com/questions/27421469/setting-layoutmargins-of-uiview-doesnt-work
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.layoutMargins = viewMargins
        contentView.translatesAutoresizingMaskIntoConstraints = false
        setEqual(view: view, subview: contentView)
        
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
        set(height: height1, view: itemsAlertList?.view)
        set(height: height2, view: actionsAlertList?.view)
        
        if let topSubview = itemsAlertList?.view ?? actionsAlertList?.view {
            view.addSubview(topSubview)
            topSubview.translatesAutoresizingMaskIntoConstraints = false
            
            setEqualTop(view: view, subview: topSubview)
            setEqualLeftAndRight(view: view, subview: topSubview)
            
            if let bottomSubview = actionsAlertList?.view, bottomSubview !== topSubview {
                view.addSubview(separatorView)
                separatorView.translatesAutoresizingMaskIntoConstraints = false

                setBottomToTop(topView: topSubview, bottomView: separatorView)
                setEqualLeftAndRight(view: view, subview: separatorView)
                set(height: separatorHeight, view: separatorView)

                view.addSubview(bottomSubview)
                bottomSubview.translatesAutoresizingMaskIntoConstraints = false

                setBottomToTop(topView: separatorView, bottomView: bottomSubview)
                setEqualLeftAndRight(view: view, subview: bottomSubview)
                setEqualBottom(view: view, subview: bottomSubview)
                
            } else {
                setEqualBottom(view: view, subview: topSubview)
            }
        }
    }
    
    func setEqual(view: UIView, subview: UIView) {
        NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: subview, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: subview, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: subview, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: subview, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func set(height: CGFloat?, view: UIView?) {
        guard let height = height, let view = view else { return }
        NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height).isActive = true
    }
    
    func set(width: CGFloat?, view: UIView?) {
        guard let width = width, let view = view else { return }
        NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width).isActive = true
    }
    
    func setEqualLeftAndRight(view: UIView, subview: UIView) {
        NSLayoutConstraint(item: view, attribute: .leftMargin, relatedBy: .equal, toItem: subview, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .rightMargin, relatedBy: .equal, toItem: subview, attribute: .right, multiplier: 1, constant: 0).isActive = true
    }
    
    func setEqualTop(view: UIView, subview: UIView) {
        NSLayoutConstraint(item: view, attribute: .topMargin, relatedBy: .equal, toItem: subview, attribute: .top, multiplier: 1, constant: 0).isActive = true
    }
    
    func setEqualBottom(view: UIView, subview: UIView) {
        NSLayoutConstraint(item: view, attribute: .bottomMargin, relatedBy: .equal, toItem: subview, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func setBottomToTop(topView: UIView, bottomView: UIView) {
        NSLayoutConstraint(item: topView, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1, constant: 0).isActive = true
    }
    
    var hasItems: Bool { return items.count > 0 }
    var hasActions: Bool { return actions.count > 0 }
    
    func elementsHeights() -> (itemsHeight: CGFloat?, actionsHeight: CGFloat?) {
        let max = maxViewHeight() - viewMargins.topPlusBottom
        
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
    
    func maxViewHeight() -> CGFloat {
        return UIScreen.main.bounds.height - 80
    }
}
