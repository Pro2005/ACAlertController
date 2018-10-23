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

public class ACAlertAction: ACAlertActionProtocolBase {
    
    public let alertView: UIView
    public let handler: ((ACAlertAction) -> Void)?
    
    public init(view: UIView, handler: ((ACAlertAction) -> Void)?) {
        self.alertView = view
        self.handler = handler
    }
    
//    open func alertView(_ tintColor: UIColor) -> UIView {
//        return alertView
//    }
    
    open func call() {
        handler?(self)
    }
}

public class ACAlertActionNative: ACAlertActionProtocolBase {
    
    public let handler: ((ACAlertActionNative) -> Void)?
    
    public let title: String?
    public let style: UIAlertActionStyle
    public var enabled: Bool = true
    
    public init(title: String?, style: UIAlertActionStyle, handler: ((ACAlertActionNative) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    lazy open var alertView: UIView = {
        let label = UILabel()
        let blueColor = UIColor(red:0.31, green:0.75, blue:0.87, alpha:1.0)
        let redColor = UIColor(red:0.82, green:0.01, blue:0.11, alpha:1.0)
        
        let fontSize: CGFloat = 17
        label.font = self.style == .cancel ? UIFont.boldSystemFont(ofSize: fontSize) :  UIFont.systemFont(ofSize: fontSize)
        label.minimumScaleFactor = 0.5
        
        let normalColor = self.enabled ? blueColor : UIColor.gray
        label.textColor = self.style == .destructive ? redColor : normalColor
        
        label.text = self.title
        
        return label
    }()

    open func call() {
        handler?(self)
    }
}
