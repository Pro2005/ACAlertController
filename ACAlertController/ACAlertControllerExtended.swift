//
//  ACAlertController.swift
//  ACAlertControllerDemo
//
//  Created by Yury on 23/10/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import Foundation
import UIKit

class ACAlertControllerExtended : ACAlertControllerBase {
    
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
}
