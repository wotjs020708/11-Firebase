//
//  SignUpView.swift
//  SociallyApp
//
//  Created by 어재선 on 7/23/24.
//
import SwiftUI
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalyticsSwift

struct SignUpView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    
    var body: some View {
        VStack {
            SignInWithAppleButton(onRequest: authModel.signInWithApple(request:),
                                              onCompletion: authModel.signInWithAppleCompletion(result:)) .signInWithAppleButtonStyle(.black)
            .frame(width: 290, height: 45, alignment: .center)
        }
        .analyticsScreen(name: "SignUpView")
    }
}

#Preview {
    SignUpView()
}
