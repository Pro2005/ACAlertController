//
//  ItemCustomView.swift
//  ACAlertControllerDemo
//
//  Created by Yury on 26/10/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

class ItemCustomView: UIView {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    class func newCustomView(text1: String, text2: String, text3: String) -> ItemCustomView? {
        guard let view = Bundle.main.loadNibNamed("ItemCustomView", owner: nil, options: nil)?.first as? ItemCustomView else {
            print("Cannot create ItemCustomView view")
            return nil
        }
        view.label1.text = text1
        view.label2.text = text2
        view.label3.text = text3
        view.translatesAutoresizingMaskIntoConstraints = false
        Layout.set(height: 45, view: view)
        Layout.setOptional(width: 500, view: view)
        return view
    }
}
