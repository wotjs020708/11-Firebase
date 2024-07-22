//
//  NoteViewmodel.swift
//  NoteApp
//
//  Created by 어재선 on 7/22/24.
//

import Foundation
import FirebaseFirestore

class NoteViewmodel: ObservableObject {
    @Published var notes = [Note]()
    
    private var databaseReference = Firestore.firestore().collection("Notes")
    
    func addData(title: String) {
        let docRef = databaseReference.addDocument(data: ["title": title])
        dump(docRef)
    }
    
}
