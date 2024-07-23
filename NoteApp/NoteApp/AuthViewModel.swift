//
//  AuthViewModel.swift
//  NoteApp
//
//  Created by 어재선 on 7/23/24.
//

import SwiftUI
import FirebaseAuth

final class AuthViewModel: ObservableObject {
    @Published var user: User?
    
    func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [ weak self] _, user in
            self?.user = user
        }
    }
    
    func signIn(emailAddress: String, password: String) {
        Auth.auth().signIn(withEmail: emailAddress, password: password) { result, error in
            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }
            
        }
    }
    
    func signUp(emailAddress: String, password: String) {
        Auth.auth().createUser(withEmail: emailAddress, password: password) { result, error in
            if let error = error {
                print("create error: \(error.localizedDescription)")
                return
            }
            dump(result)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error sgining out %@", signOutError)
        }
    }
    
    func resetPassword(emailAddress: String) {
        Auth.auth().sendPasswordReset(withEmail: emailAddress) { error in
            if let error = error {
                print("error: \(error.localizedDescription)")
            }
            print("done")
        }
    }
}
