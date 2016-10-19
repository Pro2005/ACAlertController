//
//  ACAlertAction.swift
//  ACAlertControllerDemo
//
//  Created by Yury on 21/09/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

public protocol ACAlertActionProtocol {
    
    func alertView(_ tintColor: UIColor) -> UIView
    func highlight(_ isHighlited: Bool)
    func call() -> Void
    var enabled: Bool { get }
}

extension ACAlertActionProtocol {
    
    public var enabled: Bool { return true }
    public func highlight(_ isHighlited: Bool) { }
}

// MARK: -

open class ACAlertAction<T:UIView>: ACAlertActionProtocol {
    
    open let alertView: T
    open let handler: ((ACAlertAction<T>) -> Void)?
    
    public init(view: T, handler: ((ACAlertAction<T>) -> Void)?) {
        self.alertView = view
        self.handler = handler
    }
    
    open func alertView(_ tintColor: UIColor) -> UIView {
        return alertView
    }
    
    open func call() {
        handler?(self)
    }
}

open class ACAlertActionNative: ACAlertActionProtocol {
    
    open let handler: ((ACAlertActionNative) -> Void)?
    
    open let title: String?
    open let style: UIAlertActionStyle
    open var enabled: Bool = true
    
    public init(title: String?, style: UIAlertActionStyle, handler: ((ACAlertActionNative) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    open func alertView(_ tintColor: UIColor) -> UIView {
        let label = UILabel()
        
        let fontSize: CGFloat = 17
        label.font = style == .cancel ? UIFont.boldSystemFont(ofSize: fontSize) :  UIFont.systemFont(ofSize: fontSize)
        label.minimumScaleFactor = 0.5
        
        let normalColor = enabled ? tintColor : UIColor.gray
        label.textColor = style == .destructive ? UIColor.red : normalColor
        
        label.text = title
        
        return label
    }
    
    open func call() {
        handler?(self)
    }
}
