//
//  DemoViewController.swift
//  ACAlertControllerDemo
//
//  Created by Yury on 17/06/16.
//  Copyright © 2016 Avtolic. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton(type: .System)
        button.frame = CGRect(x: 10, y: 200, width: 330, height: 100)
        button.setTitle("Normal", forState: .Normal)
        button.setTitle("Highlighted", forState: .Highlighted)
        button.backgroundColor = UIColor.yellowColor().colorWithAlphaComponent(0.5)
        view.addSubview(button)
        // Do any additional setup after loading the view.
    }
}

extension DemoViewController {
    
    func createLabel(text: String?, textColor: UIColor = UIColor.blackColor(), color: UIColor = UIColor.clearColor()) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 1
        label.font = UIFont.systemFontOfSize(15)
        label.textColor = textColor
        label.backgroundColor = color
//        label.sizeToFit()
        return label
    }
    
    func createTextField() -> UITextField {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.autocapitalizationType = .Words
        textField.returnKeyType = .Done
        textField.enablesReturnKeyAutomatically = true
        textField.borderStyle = .Line
        let width = NSLayoutConstraint(item: textField, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 270)
        width.priority = 995
        width.active = true
        textField.layoutMargins = UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 8)
        return textField
    }
    
    @IBAction func newOne() {
        let alert = ACAlertController(title: "Title", message: "Are you sure you want to Sign Out?")

        alert.addItem(createLabel("Short text"))
        alert.addItem(UIImageView(image: UIImage(named: "In History Icon")))
        alert.addItem(UIImageView(image: UIImage(named: "Out History Icon")))
        
        var margins1 = alert.defaultItemsMargins
        margins1.bottom = 0
        var margins2 = alert.defaultItemsMargins
        margins2.top = 0
        margins2.right = 20
        alert.addItem(createTextField(), inset: margins1)
        alert.addItem(createTextField(), inset: margins2)
        
        alert.addItem(createLabel("Short text", textColor: UIColor.magentaColor(), color: UIColor.yellowColor()))
        alert.addItem(createLabel("Some not very short but quite long text here. Hello world!",
            textColor: UIColor.cyanColor(), color: UIColor.orangeColor()))
        alert.addItem(createLabel("Some not very short but quite long text here. Hello world!",
            textColor: UIColor.magentaColor(), color: UIColor.yellowColor()))
        
        alert.addAction(ACAlertAction(view: UIImageView(image: UIImage(named: "Details Icon")), handler: { (_) in
            print("Action Details")
        }))
        let historyImageView = UIImageView(image: UIImage(named: "In History Icon"))
        historyImageView.setContentCompressionResistancePriority(995, forAxis: .Vertical)
        alert.addAction(ACAlertAction(view: historyImageView, handler: { (_) in
            print("Action History")
        }))
        
        let action = ACAlertActionNative(title: "Disabled title", style: .Default, handler: { (_) in
            print("Disabled")
        })
        action.enabled = false
        alert.addAction(action)

        alert.addAction(ACAlertActionNative(title: "A", style: .Default, handler: { (_) in
            print("Default")
        }))
        alert.addAction(ACAlertActionNative(title: "C", style: .Cancel, handler: { (_) in
            print("Cancel")
        }))
        alert.addAction(ACAlertActionNative(title: "Destructive title", style: .Destructive, handler: { (_) in
            print("Destructive")
        }))
        
        presentViewController(alert, animated: true){
            let v = alert.view
            print(v)
            print(v.backgroundColor)
            print(v.layer.cornerRadius)
        }
    }
    @IBAction func newTwo() {
    }
    @IBAction func newThree() {
    }
    @IBAction func newEdit() {
    }
}

extension DemoViewController {
    
    @IBAction func onOne() {
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: .Alert)
//        let yesAction = UIAlertAction(title: "Yes", style: .Default){ (action) in    }
//        alertController.addAction(yesAction)

//        let alertController = UIAlertController(title: "Title Lorem Ipsum bla bla bla very long title Lorem Ipsum bla bla bla very long title", message: "Are you sure you want to Sign Out?", preferredStyle: .Alert)
//        let yesAction = UIAlertAction(title: "Yes", style: .Default){ (action) in    }
//        alertController.addAction(yesAction)
        presentViewController(alertController, animated: true) {}
    }
    @IBAction func onTwo() {
        let alertController = UIAlertController(title: "Title", message: "Are you sure you want to Sign Out?", preferredStyle: .Alert)
        let noAction = UIAlertAction(title: "No", style: .Cancel){ (action) in }
        let yesAction = UIAlertAction(title: "Yes", style: .Default){ (action) in    }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        presentViewController(alertController, animated: true) {}
    }
    @IBAction func onThree() {
        let alertController = UIAlertController(title: "Title", message: "Are you sure you want to Sign Out?", preferredStyle: .Alert)
        let noAction = UIAlertAction(title: "No", style: .Cancel){ (action) in print("No") }
        let yesAction = UIAlertAction(title: "Yes", style: .Default){ (action) in print("Yes") }
        let destrAction = UIAlertAction(title: "Destr", style: .Destructive){ (action) in    }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        alertController.addAction(destrAction)
//        noAction.enabled = false
//        yesAction.enabled = false
//        destrAction.enabled = false
        presentViewController(alertController, animated: true) {
            let v = alertController.view
            print(v)
            print(v.backgroundColor)
            print(v.layer.cornerRadius)
        }
    }
    
    @IBAction func onEdit() {
        let alertController = UIAlertController(title: "Name the Song", message: "Song name not on the list?\nEnter it here.", preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .Words
            textField.returnKeyType = .Done
            textField.enablesReturnKeyAutomatically = true
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Name 2"
            textField.autocapitalizationType = .Words
            textField.returnKeyType = .Done
            textField.enablesReturnKeyAutomatically = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel){ (action) in }
        alertController.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default){ (action) in
            if let field = alertController.textFields?.first, let text = field.text where !text.isEmpty {
                print(text)
            }
        }
        alertController.addAction(submitAction)
        
        self.presentViewController(alertController, animated: true) {}
    }
}