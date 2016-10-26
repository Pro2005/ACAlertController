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

        let button = UIButton(type: .system)
        button.frame = CGRect(x: 10, y: 200, width: 330, height: 100)
        button.setTitle("Normal", for: UIControlState())
        button.setTitle("Highlighted", for: .highlighted)
        button.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        view.addSubview(button)
        // Do any additional setup after loading the view.
    }
}

extension DemoViewController {
    
    func createLabel(_ text: String?, textColor: UIColor = UIColor.black, color: UIColor = UIColor.clear) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = textColor
        label.backgroundColor = color
        label.textAlignment = .center
//        label.sizeToFit()
        return label
    }
    
    func createTextField() -> UITextField {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.autocapitalizationType = .words
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.borderStyle = .line
        textField.backgroundColor = UIColor.white
        let width = NSLayoutConstraint(item: textField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 270)
        width.priority = 995
        width.isActive = true
        return textField
    }
    
    @IBAction func newOne() {
        
        let alert = ACAlertControllerBase()
        for _ in 1...1 {
            alert.addItem(createLabel("Short text"))
            alert.addItem(UIImageView(image: UIImage(named: "Details Icon")))
            alert.addItem(UIImageView(image: UIImage(named: "Checklist Icon OK")))
            alert.addItem(UIImageView(image: UIImage(named: "Details Icon")))
            alert.addItem(createLabel("Мой дядя самых честных правил !!!! когда не в шутку занемог, он уважать себя заставил и лучше выдумать не мог."))
            alert.addItem(UIImageView(image: UIImage(named: "Checklist Icon OK")))
        }
        
        alert.addAction(ACAlertAction(view: UIImageView(image: UIImage(named: "Checklist Icon OK")), handler: { (_) in
            print("Action Details")
        }))
        alert.addAction(ACAlertAction(view: UIImageView(image: UIImage(named: "Details Icon")), handler: { (_) in
            print("Action Details")
        }))
        let historyImageView = UIImageView(image: UIImage(named: "Details Icon"))
        historyImageView.setContentCompressionResistancePriority(995, for: .vertical)
        historyImageView.setContentHuggingPriority(995, for: .vertical)
        alert.addAction(ACAlertAction(view: historyImageView, handler: { (_) in
            print("Action History")
        }))

        let action = ACAlertActionNative(title: "Disabled title", style: .default, handler: { (_) in
            print("Disabled")
        })
        action.enabled = false
        alert.addAction(action)

        alert.addAction(ACAlertActionNative(title: "Destructive title", style: .destructive, handler: { (_) in
            print("Destructive")
        }))

        alert.addAction(ACAlertActionNative(title: "A", style: .default, handler: { (_) in
            print("Default")
        }))
        alert.addAction(ACAlertActionNative(title: "C", style: .cancel, handler: { (_) in
            print("Cancel")
        }))

        present(alert, animated: true)
        
//            view.addSubview(alert.view)
//            NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: alert.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
//            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: alert.view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        
//        let alert = ACAlertController(title: "Title", message: "Are you sure you want to Sign Out?")
//
//        alert.addItem(createLabel("Short text"))
//        alert.addItem(UIImageView(image: UIImage(named: "Checklist Icon OK")))
//        alert.addItem(UIImageView(image: UIImage(named: "Import Icon")))
//        
//        var margins1 = alert.defaultItemsMargins
//        margins1.bottom = 0
//        var margins2 = alert.defaultItemsMargins
//        margins2.top = 0
//        margins2.right = 20
//        alert.addItem(createTextField(), inset: margins1)
//        alert.addItem(createTextField(), inset: margins2)
//        alert.addItem(createTextField())
//        
//        alert.addItem(createLabel("Short text", textColor: UIColor.magenta, color: UIColor.yellow))
//        alert.addItem(createLabel("Some not very short but quite long text here. Hello world!",
//            textColor: UIColor.cyan, color: UIColor.orange))
//        alert.addItem(createLabel("Some not very short but quite long text here. Hello world!",
//            textColor: UIColor.magenta, color: UIColor.yellow))
//        
//        alert.addAction(ACAlertAction(view: UIImageView(image: UIImage(named: "Details Icon")), handler: { (_) in
//            print("Action Details")
//        }))
//        let historyImageView = UIImageView(image: UIImage(named: "Checklist Icon OK"))
//        historyImageView.setContentCompressionResistancePriority(995, for: .vertical)
//        alert.addAction(ACAlertAction(view: historyImageView, handler: { (_) in
//            print("Action History")
//        }))
//        
//        let action = ACAlertActionNative(title: "Disabled title", style: .default, handler: { (_) in
//            print("Disabled")
//        })
//        action.enabled = false
//        alert.addAction(action)
//
//        alert.addAction(ACAlertActionNative(title: "A", style: .default, handler: { (_) in
//            print("Default")
//        }))
//        alert.addAction(ACAlertActionNative(title: "C", style: .cancel, handler: { (_) in
//            print("Cancel")
//        }))
//        alert.addAction(ACAlertActionNative(title: "Destructive title", style: .destructive, handler: { (_) in
//            print("Destructive")
//        }))
//        
//        present(alert, animated: true){
//        }
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
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: .alert)
//        let yesAction = UIAlertAction(title: "Yes", style: .Default){ (action) in    }
//        alertController.addAction(yesAction)

//        let alertController = UIAlertController(title: "Title Lorem Ipsum bla bla bla very long title Lorem Ipsum bla bla bla very long title", message: "Are you sure you want to Sign Out?", preferredStyle: .Alert)
//        let yesAction = UIAlertAction(title: "Yes", style: .Default){ (action) in    }
//        alertController.addAction(yesAction)
        present(alertController, animated: true) {}
    }
    @IBAction func onTwo() {
        let alertController = UIAlertController(title: "Title", message: "Are you sure you want to Sign Out?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel){ (action) in }
        let yesAction = UIAlertAction(title: "Yes", style: .default){ (action) in    }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        let alertView = alertController.view
        alertView?.frame.origin = CGPoint(x: 100, y: 270)
        view.addSubview(alertView!)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(10) / Double(NSEC_PER_SEC)) {
            print("ggg")
            alertView?.frame.origin = CGPoint(x: 100, y: 270)
        }
//        presentViewController(alertController, animated: true) {}
    }
    @IBAction func onThree() {
        let alertController = UIAlertController(title: "Title", message: "Are you sure you want to Sign Out?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel){ (action) in print("No") }
        let yesAction = UIAlertAction(title: "Yes", style: .default){ (action) in print("Yes") }
        let destrAction = UIAlertAction(title: "Destructive", style: .destructive){ (action) in print("Destructive") }
        let disableAction = UIAlertAction(title: "Destr", style: .default){ (action) in    }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        alertController.addAction(destrAction)
//        alertController.addAction(disableAction)
//        for _ in 1...15 {
//            let noAction = UIAlertAction(title: "No", style: .destructive){ (action) in print("No") }
//            alertController.addAction(noAction)
//        }
        disableAction.isEnabled = false
//        noAction.enabled = false
//        yesAction.enabled = false
//        destrAction.enabled = false
        present(alertController, animated: true) {
        }
    }
    
    @IBAction func onEdit() {
        let alertController = UIAlertController(title: "Name the Song", message: "Song name not on the list?\nEnter it here.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
        }
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Name 2"
            textField.autocapitalizationType = .words
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
        }
        
        for i in 1...30 {
            alertController.addTextField { (textField) -> Void in
                textField.placeholder = "Name \(i)"
                textField.autocapitalizationType = .words
                textField.returnKeyType = .done
                textField.enablesReturnKeyAutomatically = true
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (action) in }
        alertController.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default){ (action) in
            if let field = alertController.textFields?.first, let text = field.text , !text.isEmpty {
                print(text)
            }
        }
        alertController.addAction(submitAction)
        
        for _ in 1...15 {
            let noAction = UIAlertAction(title: "No", style: .destructive){ (action) in print("No") }
            alertController.addAction(noAction)
        }
        
        self.present(alertController, animated: true) {
//            print(alertController.view.performSelector("recursiveDescription"))
//            print(alertController.view.gestureRecognizers)
//            alertController.view.removeGestureRecognizer(alertController.view.gestureRecognizers!.first!)

//            let recognizer = alertController.view.gestureRecognizers!.first! as! UILongPressGestureRecognizer
//            print(recognizer)
//            print(recognizer.minimumPressDuration)
//            print(recognizer.numberOfTapsRequired)
//            print(recognizer.numberOfTouchesRequired)
//            print(recognizer.allowableMovement)
//            print(recognizer.cancelsTouchesInView)
//            print(recognizer.delaysTouchesBegan)
//            print(recognizer.delaysTouchesEnded)
//            
//            print(recognizer.delegate)
//            let del = recognizer.delegate!
//            if let _ = del.gestureRecognizer?(recognizer, shouldBeRequiredToFailBy: recognizer) {
//                print("shouldBeRequiredToFailByGestureRecognizer")
//            }
//            if let _ = del.gestureRecognizer?(recognizer, shouldReceive: UIPress()) {
//                print("shouldReceivePress")
//            }
//            if let _ = del.gestureRecognizer?(recognizer, shouldReceive: UITouch()) {
//                print("shouldReceiveTouch")
//            }
//            if let _ = del.gestureRecognizer?(recognizer, shouldRecognizeSimultaneouslyWith: UIGestureRecognizer()) {
//                print("shouldRecognizeSimultaneouslyWithGestureRecognizer")
//            }
//            if let _ = del.gestureRecognizer?(recognizer, shouldRequireFailureOf: recognizer) {
//                print("shouldRequireFailureOfGestureRecognizer")
//            }
//            if let _ = del.gestureRecognizerShouldBegin?(recognizer) {
//                print("gestureRecognizerShouldBegin")
//            }
//        
        
        }
    }
}
