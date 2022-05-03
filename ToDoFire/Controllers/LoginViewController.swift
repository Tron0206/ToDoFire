//
//  ViewController.swift
//  ToDoFire
//
//  Created by Zhasur Sidamatov on 03/05/2022.
//

import UIKit
import Firebase

final class LoginViewController: UIViewController {
    
    private let segueIdentifier = "tasksSegue"
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        warnLabel.alpha = 0
        //
        FirebaseAuth.Auth.auth().addStateDidChangeListener { [weak self] asuth, user in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    
    //MARK: - Methods
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              email != "",
              password != "" else {
                  displayWarningLabel(withText: "Info is incorrect")
                  return
              }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if error != nil {
                self?.displayWarningLabel(withText: "Error occured")
                return
            }
            
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            }
            
            self?.displayWarningLabel(withText: "No such user")
        }
        
        
    }
    
    
    @IBAction func registerTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              email != "",
              password != "" else {
                  displayWarningLabel(withText: "Info is incorrect")
                  return
              }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil {
                if user != nil {
                    
                } else {
                    print("User is not created")
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    private func displayWarningLabel(withText text: String) {
        warnLabel.text = text
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            self?.warnLabel.alpha = 1
        } completion: { [weak self] complete in
            self?.warnLabel.alpha = 0
        }

    }
    
    //MARK: - Objective-C methods
    @objc private func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let scrollView = self.view as? UIScrollView else { return }
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height + keyboardSize.height)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        
    }
    
    @objc private func keyboardDidHide() {
        guard let scrollView = self.view as? UIScrollView else { return }
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
    }
    
}

