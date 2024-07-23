//
//  SignUpView.swift
//  NoteApp
//
//  Created by 어재선 on 7/23/24.
//

import SwiftUI

struct SignUpView: View {
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var showingSheet = false
    
    @EnvironmentObject private var authModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email", text: $emailAddress)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                }
                
                Section {
                    Button(action: {
                        authModel.signUp(emailAddress: emailAddress,
                                         password: password)
                    }) {
                        Text("Sign Up").bold()
                    }
                }
                Section(header: Text("If you already have an account:")) {
                    Button(action: {
                        authModel.signIn(emailAddress: emailAddress,
                                         password: password)
                    }) {
                        Text("Sign In")
                    }
                }
            }
            .navigationTitle("Welcome")
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button {
                        showingSheet.toggle()
                    } label: {
                        Text("Forgot password?")
                    }
                    .sheet(isPresented: $showingSheet) {
                        ResetPasswordView()
                    }
                }
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
