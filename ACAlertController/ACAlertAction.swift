//
//  ACAlertAction.swift
//  ACAlertControllerDemo
//
//  Created by Yury on 21/09/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

public protocol ACAlertActionProtocolBase {
    
    var alertView: UIView { get }
    var enabled: Bool { get }
    func highlight(_ isHighlited: Bool)
    func call() -> Void
}

extension ACAlertActionProtocolBase {
    
    public var enabled: Bool { return true }
    public func highlight(_ isHighlited: Bool) { }
}

public protocol ACAlertActionProtocol: ACAlertActionProtocolBase {
    
    func alertView(_ tintColor: UIColor) -> UIView
}

extension ACAlertActionProtocol {
    func alertView(_ tintColor: UIColor) -> UIView {
        return self.alertView
    }
}
// MARK: -

//open class ACAlertAction<T:UIView>: ACAlertActionProtocol {
//    
//    open let alertView: T
//    open let handler: ((ACAlertAction<T>) -> Void)?
//    
//    public init(view: T, handler: ((ACAlertAction<T>) -> Void)?) {
//        self.alertView = view
//        self.handler = handler
//    }
//    
//    open func alertView(_ tintColor: UIColor) -> UIView {
//        return alertView
//    }
//    
//    open func call() {
//        handler?(self)
//    }
//}

open class ACAlertActionNative: ACAlertActionProtocolBase {
    
    open let handler: ((ACAlertActionNative) -> Void)?
    
    open let title: String?
    open let style: UIAlertActionStyle
    open var enabled: Bool = true
    
    public init(title: String?, style: UIAlertActionStyle, handler: ((ACAlertActionNative) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    lazy open var alertView: UIView = {
        let label = UILabel()
        
        let fontSize: CGFloat = 17
        label.font = self.style == .cancel ? UIFont.boldSystemFont(ofSize: fontSize) :  UIFont.systemFont(ofSize: fontSize)
        label.minimumScaleFactor = 0.5
        
        let normalColor = self.enabled ? label.tintColor : UIColor.gray
        label.textColor = self.style == .destructive ? UIColor.red : normalColor
        
        label.text = self.title
        
        return label
    }()

    open func call() {
        handler?(self)
    }
}
