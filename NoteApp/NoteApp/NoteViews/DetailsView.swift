//
//  DetailsView.swift
//  NoteApp
//
//  Created by 어재선 on 7/22/24.
//

import SwiftUI

struct DetailsView: View {
    var note: Note
    @State private var presentAlert = false
    @State private var titleText = ""
    
    @ObservedObject var viewModel: NoteViewModel
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text(note.title ?? "")
                        .font(.system(size: 22, weight: .regular))
                        .padding()
                    Spacer()
                }
            }
            .navigationTitle("Details")
            .toolbar {
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button {
                        presentAlert.toggle()
                    } label: {
                        Text("Edit").bold()
                    }
                    .alert("Note",isPresented: $presentAlert) {
                        TextField("\(note.title ?? "" )", text: $titleText)
                        Button("Update") {
                            viewModel.updateData(title: titleText, id: note.id ?? "")
                        }
                        Button("Cancel",role: .cancel) {
                            presentAlert = false
                            titleText = ""
                        }
                        
                    } message: {
                        Text("write your new note")
                    }
                }
                
            }
        }
    }
}

#Preview {
    DetailsView(note: Note(title: "Test"), viewModel: NoteViewModel())
}
