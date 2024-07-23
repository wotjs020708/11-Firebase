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
    
}
