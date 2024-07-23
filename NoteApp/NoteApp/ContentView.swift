//
//  ContentView.swift
//  NoteApp
//
//  Created by 어재선 on 7/22/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authModel: AuthViewModel

    @State private var showsheet = false
    @State private var postDetent = PresentationDetent.medium
    
    @StateObject private var viewModel = NoteViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.notes, id: \.id) { note in
                    NavigationLink(destination: DetailsView(note: note, viewModel: viewModel)) {
                        VStack(alignment: .leading) {
                            Text(note.title ?? "")
                                .font(.system(size: 22, weight: .regular))
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteData(at:))
            }
            
            .onAppear {
                viewModel.fetchData()
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                               Button {
                                   authModel.signOut()
                               } label: {
                                   Text("Sign out")
                               }
                           }
                ToolbarItemGroup(placement: .bottomBar) {
                    Text("\(viewModel.notes.count) notes")
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
            .environmentObject(viewModel)
        }
    }
}

#Preview {
    ContentView()
}
