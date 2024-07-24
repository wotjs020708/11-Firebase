//
//  ProFileView.swift
//  SociallyApp
//
//  Created by 어재선 on 7/24/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authModel: AuthViewModel

    @State private var showSignUp: Bool = false

    var body: some View {
        VStack(alignment: .center) {
            if authModel.user != nil {
                Form {
                    Section("Your account") {
                        Text(authModel.user?.email ?? "")
                    }
                    Button {
                        authModel.signOut()
                    } label: {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                }
            } else {
                Form {
                    Section("Your account") {
                        Text("Seems like you are not logged in, create an account")
                    }
                    Button {
                        showSignUp.toggle()
                    } label: {
                        Text("Sign Up")
                            .foregroundColor(.blue)
                            .bold()
                    }
                    .sheet(isPresented: $showSignUp) {
                        SignUpView().presentationDetents([.height(100), .medium, .large])
                    }
                }
            }
        }
        .onAppear { authModel.listenToAuthState() }
    }
}

#Preview {
    ProfileView()
}
