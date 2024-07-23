//
//  PostViewmodel.swift
//  SociallyApp
//
//  Created by 어재선 on 7/23/24.
//

import Combine
import FirebaseFirestore

class PostViewModel: ObservableObject {
    @Published var posts = [Post]()
    
    private var databaseReferance = Firestore.firestore().collection("Posts")
    
}
