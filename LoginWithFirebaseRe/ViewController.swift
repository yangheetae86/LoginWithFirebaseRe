//
//  ViewController.swift
//  LoginWithFirebaseRe
//
//  Created by Y on 2020/04/09.
//  Copyright © 2020 HEETAE YANG. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD

struct User {
    let name: String
    let createdAt: Timestamp
    let email: String
    
    init(dic: [String: Any]) {
        self.name = dic["name"] as! String
        self.createdAt = dic["createdAt"] as! Timestamp
        self.email = dic["email"] as! String
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func tappedRegisterButton(_ sender: Any) {
        handleAuthToFirebase()
    }
    @IBAction func tappedAlreadyHaveAccountButton(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(identifier:
            "LoginViewController") as! LoginViewController
        navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    private func handleAuthToFirebase() {
    HUD.show(.progress, onView: view)
    guard let email = emailTextField.text else { return }
    guard let password = passwordTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (res, error) in
        if let err = error {
            print("보존실패 \(err)")
            HUD.hide() { (_) in
                HUD.flash(.success, delay: 1)
            }
            return
        }
            self.addUserInfoToFirestore(email: email)

        }
    }
    
    private func addUserInfoToFirestore(email: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let name = self.usernameTextField.text else { return }
        
        let docData = ["email": email,"name": name,"createdAt": Timestamp()] as [String: Any]
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.setData(docData) { (error) in
                if let err = error {
                    print("Firestore 에 보존 실패 \(err)")
                    HUD.hide() { (_) in
                        HUD.flash(.success, delay: 1)
                    }
                    return
                }
                print("Firestore 에 보존성공")

                userRef.getDocument { (snapshot, error) in
                if let err = error {
                    print("유저등록 실패\(err)")
                    HUD.hide() { (_) in
                        HUD.flash(.success, delay: 1)
                    }
                    return
                }
                
                    guard let data = snapshot?.data() else { return }
                    let user = User.init(dic: data)
                    
                    print("유저등록 성공 \(user.name)")
                    HUD.hide() { (_) in
//                        HUD.flash(.success, delay: 1)
                        HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                            self.presentToHomeViewController(user: user)
                        }
                    }
            }
        }
    }
    
    private func presentToHomeViewController(user: User) {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        homeViewController.user = user
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerButton.isEnabled = false
        registerButton.layer.cornerRadius = 10
        registerButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)

        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hidekeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    @objc func showKeyboard(notification: Notification) {
          let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
          
          guard let keyboardMinY = keyboardFrame?.minY else {return}
          let registerButtonMaxY = registerButton.frame.maxY
          let distance = registerButtonMaxY - keyboardMinY + 20
          
          let transform = CGAffineTransform(translationX: 0, y: -distance)
          
          UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
              self.view.transform = transform
          })
      }
    
    
     @objc func hidekeyboard() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = .identity
    })
}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension ViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? true

        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = UIColor.rgb(red: 255, green: 141, blue: 0)
        }
    }
}
