//
//  FormView.swift
//  NoteApp
//
//  Created by 어재선 on 7/22/24.
//

import SwiftUI

struct FormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: NoteViewModel
    
    @State var titleText = ""
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $titleText)
                        .frame(minHeight: 200)
                }
                Section {
                    Button {
                        viewModel.addData(title: titleText)
                        titleText = ""
                        dismiss()
                    } label: {
                        Text("Save now")
                    }
                    .foregroundStyle(.yellow)
                    .disabled(titleText.isEmpty)
                }
            }
            .navigationTitle("Publish")
            .toolbar {
                ToolbarItemGroup(placement: .destructiveAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
            }
        }
    }
}

#Preview {
    FormView()
}
