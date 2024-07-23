//
//  FeedView.swift
//  SociallyApp
//
//  Created by 어재선 on 7/23/24.
//

import SwiftUI
import FirebaseFirestoreSwift

struct FeedView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    @FirestoreQuery(collectionPath: "Posts") var posts: [Post]
    
    var body: some View {
        NavigationStack {
            List(posts) { post in
                VStack(alignment: .leading) {
                    VStack{
                        Text(post.description ?? "")
                            .font(.headline)
                            .padding(12)
                        Text("Published on the \(post.datePublished?.formatted() ?? "")")
                            .font(.caption)
                    }
                }
                .frame(minWidth: 100, maxHeight: 350)
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        authModel.signOut()
                    } label: {
                        Text("Sign out")
                    }
                }
            }
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(PostViewModel())
}
