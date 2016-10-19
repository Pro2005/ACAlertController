//
//  ACAlertItem.swift
//  ACAlertControllerDemo
//
//  Created by Yury on 21/09/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

public protocol ACAlertItemProtocol {
    
    var alertItemView: UIView { get }
}

extension UIView: ACAlertItemProtocol {
    
    public var alertItemView: UIView { return self }
}
