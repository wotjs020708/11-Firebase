//
//  PostService.swift
//  Socially-UIKit
//
//  Created by 어재선 on 7/26/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class PostService {
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()

    func updatePost(post: Post, newDescription: String, completion: @escaping (Result<Post,Error>) -> Void) {
        if let postId = post.id {
            db.document("Posts/\(postId)").setData(["description": newDescription],
                                                   merge: true) { error in
                if let error = error {
                    print("update error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                self.db.document("Posts/\(postId)").getDocument { document, error in
                    if let error = error {
                        print("get doc error: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    if let document = document,
                       let data = document.data(),
                       let description = data["description"] as? String,
                       let imageUrl = data["imageURL"] as? String,
                       let datePublished = (data["datePublished"] as? Timestamp)?.dateValue() {
                        let updatedPost = Post(id: document.documentID,
                                               description: description,
                                               imageURL: imageUrl,
                                               datePublished: datePublished)
                        completion(.success(updatedPost))
                    }
                }
            }
        }
    }

    func deletePost(post: Post, completion: @escaping (Result<Void,Error>) -> Void) {
        if let postId = post.id {
            db.collection("Posts").document(postId).delete { error in
                if let error = error {
                    print("delete error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                if let imageURL = post.imageURL {
                    let imageRef = Storage.storage().reference(forURL: imageURL)
                    imageRef.delete { error in
                        if let error = error {
                            print("delete image error: \(error.localizedDescription)")
                            completion(.failure(error))
                            return
                        }
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
