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
    
    private lazy var handleAppleButtonPress: UIAction = UIAction { [weak self] _ in
        if let self = self {
            AuthService.shared.performAppleSignIn(on: self) { result in
                switch result {
                case .success(let user):
                    print("Successfully signed in as user: \(user.uid)")
                case .failure(let error):
                    print("Error signing in: \(error.localizedDescription)")
                }
            }
        } else {
            print("Error self is nil")
        }
    }
    
    private lazy var handleLogout: UIAction = UIAction { [weak self] _ in
           AuthService.shared.signOut() { result in
               switch result {
               case .success:
                   self?.updateUI()
               case .failure(let error):
                   print("Error signing out: \(error.localizedDescription)")
               }
           }
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
        logoutButton.addAction(handleLogout, for: .touchUpInside)
        
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
    
}


extension ProfileViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = AuthService.shared.currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // 파이어베이스에 애플 인증 전달
            AuthService.shared.signInWithApple(idToken: idTokenString, rawNonce: nonce) { [weak self] result in
                switch result {
                case .success(let user):
                    print("Successfully signed in as user: \(user.uid)")
                    self?.updateUI()
                case .failure(let error):
                    print("Error signing in: \(error.localizedDescription)")
                    // 에러 처리
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
}

extension ProfileViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
