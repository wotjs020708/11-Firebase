//
//  Post.swift
//  Socially-UIKit
//
//  Created by 어재선 on 7/25/24.
//


import Foundation
import FirebaseFirestore
import FirebaseStorage

struct Post: Hashable,Identifiable, Decodable {
    @DocumentID var id: String?
    var description: String?
    var imageURL: String?
    @ServerTimestamp var datePublished: Date?
    
    init?(document: QueryDocumentSnapshot) {
        dump(document.data())
        self.id = document.documentID
        self.description = document.data()["description"] as? String
        if let url = document.data()["imageURL"] as? String {
            self.imageURL = url
        } else if let path = document.data()["path"] as? String {
            let mutableSelf = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                mutableSelf.checkImageURL(path)
            }
        }
    }
    
    
    func checkImageURL(_ path: String) {
        let thumbRef = Storage.storage().reference().child("thumbs/\(path)_320x200")
        thumbRef.downloadURL { url, error in
            if let error = error {
                return
            }
            
            if let url = url,
               let docId = self.id {
                Firestore.firestore().collection("Posts")
                    .document(docId)
                    .setData(["imageURL": url], merge: true)
            }
        }
        
    }
    
}
