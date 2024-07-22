//
//  ContentView.swift
//  NoteApp
//
//  Created by 어재선 on 7/22/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showsheet = false
    @State private var postDetent = PresentationDetent.medium
    var body: some View {
        NavigationStack {
            List {
            
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Text("X notes")
                    Spacer()
                    Button {
                        showsheet.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .imageScale(.large)
                    .sheet(isPresented: $showsheet) {
                        FormView().presentationDetents([.large, .medium])
                    }
                }
                
        }
        }
    }
}

#Preview {
    ContentView()
}
