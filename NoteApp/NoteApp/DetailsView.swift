//
//  DetailsView.swift
//  NoteApp
//
//  Created by 어재선 on 7/22/24.
//

import SwiftUI

struct DetailsView: View {
    var note: Note
    
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
        }
    }
}

#Preview {
    DetailsView(note: Note(title: "Test"))
}
