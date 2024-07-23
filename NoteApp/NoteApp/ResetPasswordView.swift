//
//  ResetPasswordView.swift
//  NoteApp
//
//  Created by 어재선 on 7/23/24.
//

import SwiftUI

struct ResetPasswordView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var authModel: AuthViewModel
    
    @State private var emailAddress: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email", text: $emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                Section(footer: Text("Once sent, check your email to reset your password.")) {
                    Button(
                        action: {
                            authModel.resetPassword(emailAddress: emailAddress)
                        }) {
                            Text("Send email link").bold()
                        }
                }
            }.navigationTitle("Reset password")
                .toolbar {
                    ToolbarItemGroup(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    ResetPasswordView()
        .environmentObject(AuthViewModel())
}
