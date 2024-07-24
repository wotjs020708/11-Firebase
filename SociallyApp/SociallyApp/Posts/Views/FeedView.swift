//
//  FeedView.swift
//  SociallyApp
//
//  Created by 어재선 on 7/23/24.
//

import SwiftUI
import FirebaseFirestoreSwift
import FirebaseAnalyticsSwift

struct FeedView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    @EnvironmentObject private var viewModel: PostViewModel
    
    @FirestoreQuery(
        collectionPath: "Posts",
        predicates: [.order(by: "description", descending: false),
                     .order(by: "datePublished", descending: true)]
    ) var posts: [Post]
    
    @State var showingPost: Bool = false
    
    var body: some View {
        NavigationStack {
            List(posts) { post in
                VStack(alignment: .leading) {
                    AsyncImage(url: URL(string: post.imageURL ?? "")) { phase in
                        switch phase {
                        case .empty:
                            EmptyView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 300, height: 200)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    VStack(alignment: .leading){
                        Text(post.description ?? "")
                            .font(.headline)
                            .padding([.bottom, .top], 6)
                        Text("Published on the \(post.datePublished?.formatted() ?? "")")
                            .font(.caption)
                    }
                }
                .frame(minWidth: 100, maxHeight: 350)
            }
            .navigationTitle("Feed")
            .analyticsScreen(name: "FeedView")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        authModel.signOut()
                    } label: {
                        Text("Sign out")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showingPost = true
                        
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingPost) {
                PostView().presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(PostViewModel())
}
