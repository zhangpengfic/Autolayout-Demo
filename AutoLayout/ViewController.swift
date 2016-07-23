//
//  ViewController.swift
//  AutoLayout
//
//  Created by H Hugo Falkman on 2015-03-06.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lastLoginLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    var loggedInUser: User? {didSet {updateUI()}}
    var secure: Bool = false { didSet {updateUI()}}
    
    private func updateUI() {
        passwordField.secureTextEntry = secure
        let password = NSLocalizedString("Password", comment: "Prompt for the user's password when it is not secure(i.e. plain text)")
        let securedPassword = NSLocalizedString("Secured Password", comment: "Prompt for an obscured (not plain text) password")
        passwordLabel.text = secure ? securedPassword: password
        nameLabel.text = loggedInUser?.name
        companyLabel.text = loggedInUser?.company
        image = loggedInUser?.image
        if let lastLogin = loggedInUser?.lastLogin {
            let dataFormatter = NSDateFormatter()
            dataFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            dataFormatter.dateStyle = NSDateFormatterStyle.NoStyle
            let time = dataFormatter.stringFromDate(lastLogin)
            let numberFormatter = NSNumberFormatter()
            let daysAgo = numberFormatter.stringFromNumber(-lastLogin.timeIntervalSinceNow/(60*60*24))!
            let lastLoginFormatString = NSLocalizedString("Last Login %@ days ago at %@", comment: "Reports the number of days ago and time that the user last logged in")
            lastLoginLabel.text=String.localizedStringWithFormat(lastLoginFormatString, daysAgo,time)
        }
    }

    private struct AlertStrings {
        struct LoginError {
            static let Title = NSLocalizedString("Login Error", comment: "Title of alert when user types in an incorrent user name or password")
            static let Message = NSLocalizedString("Invalid user name or password", comment: "Message in an alert when the user types in an incorrent user name or password")
            static let DismissButton = NSLocalizedString("Try Again", comment: "The onlu button available in an alert presented when the user types incorrent user name or password")
        }
    }
    
    @IBAction func login() {
        loggedInUser = User.login(loginField.text ?? "", password: passwordField.text ?? "")
        if loggedInUser == nil {
            let alert = UIAlertController(title: AlertStrings.LoginError.Title, message: AlertStrings.LoginError.Message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: AlertStrings.LoginError.DismissButton, style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func toggleSecurityi() {
        secure = !secure
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            if let constrainedView = imageView {
                if let newImage = newValue {
                    aspectRatioConstraint = NSLayoutConstraint(
                        item: constrainedView,
                        attribute:.Width,
                        relatedBy: .Equal,
                        toItem: constrainedView,
                        attribute: .Height,
                        multiplier: newImage.aspectRatio,
                        constant: 0)
                } else {aspectRatioConstraint = nil}
            }
        }
    }
    
    var aspectRatioConstraint: NSLayoutConstraint? {
        willSet {
            if let existingConstraint = aspectRatioConstraint {
                view.removeConstraint(existingConstraint)
            }
        }
        didSet {
            if let newConstraint = aspectRatioConstraint {
                view.addConstraint(newConstraint)
            }
        }
    }
}

extension User {
    var image: UIImage? {
        if let image = UIImage(named: login) {
            return image
        } else {
            return UIImage(named: "unknown_user")
        }
    }
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}