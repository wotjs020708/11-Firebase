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
    var path: String?
    @ServerTimestamp var datePublished: Date?
    
    init?(document: QueryDocumentSnapshot) {
        dump(document.data())
        self.id = document.documentID
        self.description = document.data()["description"] as? String
        if let url = document.data()["imageURL"] as? String {
            self.imageURL = url
        }
        if let path = document.data()["path"] as? String {
            self.path = path
        }
    }
    
    
    func checkImageURL(_ path: String) {
        let thumbRef = Storage.storage().reference().child("thumbs/\(path)_320x200")
        thumbRef.downloadURL { url, error in
            if  error != nil {
                print("thumbnail error: \(error?.localizedDescription ?? "")")
                return
            }
            
            if let url = url,
               let docId = self.id {
                Firestore.firestore().collection("Posts")
                    .document(docId)
                    .setData([
                        "paht": FieldValue.delete(),
                        "imageURL": url.absoluteString
                    ], merge: true)
            }
        }
        
    }
    
}
