//
//  ProfileViewController.swift
//  Socially-UIKit
//
//  Created by 어재선 on 7/26/24.
//

import UIKit
import AuthenticationServices


class ProfileViewController: UIViewController {
    
    // 로그인 이전
    private let signInButton = ASAuthorizationAppleIDButton()
    
    // 로그인 이후
    private let userInfoLabel = UILabel()
    private let logoutButton = UIButton(type: .system)
    
    private let handleAppleButtonPress: UIAction = UIAction { _ in
        
    }
    
    private let handlelogout: UIAction = UIAction { _ in
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        setupUI()
        
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        updateUI()

    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 애플 로그인 버튼 설정
        signInButton.addAction(handleAppleButtonPress, for: .touchUpInside)
        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 사용자 정보 레이블 설정
        userInfoLabel.numberOfLines = 0
        userInfoLabel.textAlignment = .center
        view.addSubview(userInfoLabel)
        userInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 로그아웃 버튼 설정
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.addAction(handlelogout, for: .touchUpInside)
        
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInButton.widthAnchor.constraint(equalToConstant: 300),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            
            userInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userInfoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            userInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: userInfoLabel.bottomAnchor, constant: 20),
            logoutButton.widthAnchor.constraint(equalToConstant: 100),
            logoutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func updateUI() {
        if let user = AuthService.shared.currentUser {
            // 로그인 상태
            signInButton.isHidden = true
            userInfoLabel.isHidden = false
            logoutButton.isHidden = false
            
            userInfoLabel.text = """
                        이메일: \(user.email ?? "N/A")
                        UID: \(user.uid)
                        """
        } else {
            // 로그아웃 상태
            signInButton.isHidden = false
            userInfoLabel.isHidden = true
            logoutButton.isHidden = true
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
