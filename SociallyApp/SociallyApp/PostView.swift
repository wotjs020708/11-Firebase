//
//  PostView.swift
//  SociallyApp
//
//  Created by 어재선 on 7/23/24.
//

import SwiftUI

struct PostView: View {
    @EnvironmentObject private var viewModel: PostViewModel
    
    @State private var description = ""
    
    
    var body: some View {
        NavigationStack {
            Section{
                TextField("Description", text: $description)
            }
            
            Section {
                Button{
                    //MARK: Post data to Firestore
                    Task {
                        await self.viewModel.addData(description:description,
                                                     datePublished:Date())
                    }
                    
                } label: {
                    Text("Post")
                }
            }
            .navigationTitle("New Psot")
        }
    }
}

#Preview {
    PostView()
        .environmentObject(PostViewModel())
}
