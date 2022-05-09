//
//  ViewController.swift
//  ToDoFire
//
//  Created by Zhasur Sidamatov on 03/05/2022.
//

import UIKit
import Firebase

final class LoginViewController: UIViewController {
    
    //MARK: Properties
    
    private let segueIdentifier = "tasksSegue"
    var ref: DatabaseReference!
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference(withPath: "users")
        addNotifications()
        setupView()
        checkCurrentUser()
        addGesture()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    //MARK: - @IBAction
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              email != "",
              password != "" else {
                  displayWarningLabel(withText: "Info is incorrect")
                  return
              }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if error != nil {
                self?.displayWarningLabel(withText: "Error occured")
                return
            }
            if result?.user != nil {
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
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard error == nil, result?.user != nil else {
                self?.displayWarningLabel(withText: error!.localizedDescription)
                return
            }
            
            let userRef = self?.ref.child((result?.user.uid)!)
            userRef?.setValue(["email" : result?.user.email])
        }
        
    }
    
    //MARK: - Methods
    
    private func displayWarningLabel(withText text: String) {
        warnLabel.text = text
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            self?.warnLabel.alpha = 1
        } completion: { [weak self] complete in
            self?.warnLabel.alpha = 0
        }
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardMoving(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardMoving(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    private func checkCurrentUser() {
        FirebaseAuth.Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
            }
        }
    }
    
    private func setupView() {
        warnLabel.alpha = 0
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnScreen))
        view.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Objective-C methods
    
    @objc private func keyboardMoving(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let scrollView = self.view as? UIScrollView else { return }
        
        if notification.name == UIResponder.keyboardDidShowNotification {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        } else if notification.name == UIResponder.keyboardDidHideNotification {
            UIView.animate(withDuration: 1) {
                scrollView.contentInset = .zero
                scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
            }
        }
    }
    
    @objc private func tappedOnScreen() {
        view.endEditing(true)
    }
}


//MARK: - Extensions

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

