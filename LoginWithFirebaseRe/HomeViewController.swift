//
//  HomeViewController.swift
//  LoginWithFirebaseRe
//
//  Created by Y on 2020/04/10.
//  Copyright © 2020 HEETAE YANG. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class HomeViewController: UIViewController {
    
    var user: User? {
        didSet {
            print("user?.name: ", user?.name)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func tappedLogoutButton(_ sender: Any) {
        handleLogout()
    }
    
    private func handleLogout() {
        do {
            try Auth.auth().signOut()
            presentToMainViewController()
        } catch (let err) {
            print("로그아웃 실패 \(err)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.layer.cornerRadius = 10
        
        if let user = user{
            
            nameLabel.text = user.name+"님 환영합니다"
            emailLabel.text = user.email
            let dateString = dateFormatterForCreatedAt(date: user.createdAt.dateValue())
            dateLabel.text = "작성일: "+dateString
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        confirmLoggedInUser()
    }
    
    private func confirmLoggedInUser() {
        if Auth.auth().currentUser?.uid == nil || user == nil {
            presentToMainViewController()
            
        }
    }
    
    private func presentToMainViewController() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(identifier: "UIViewController")
            as! ViewController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    private func dateFormatterForCreatedAt(date: Date)->String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
