//
//  PostViewmodel.swift
//  SociallyApp
//
//  Created by 어재선 on 7/23/24.
//

import Combine
import FirebaseFirestore
import FirebaseStorage


class PostViewModel: ObservableObject {
    private var databaseReference = Firestore.firestore().collection("Posts")
    
    
    func addData(description: String, datePublished: Date, data: Data, completion: @escaping (Error?) -> Void) {
        let fileUUID = UUID().uuidString
        let storageReference = Storage.storage().reference().child("\(fileUUID)")
        // 파일 타입 및 MIME 타입 감지
        let mimeType = detectMimeType(from: data)
        
        // 메타데이터 설정
        let metadata = StorageMetadata()
        metadata.contentType = mimeType
        
        storageReference.putData(data, metadata: metadata) { metadata, error in
            if let error = error {
                completion(error)
                return
            }
            
            // 임의로 10초 대기 ( 썸네일 생성 시간 )
            Thread.sleep(forTimeInterval: 10)
            
            let thumbRef = Storage.storage().reference().child("thumbs/\(fileUUID)_320x200")
            
            thumbRef.downloadURL { url, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let downloadURL = url else {
                    completion(NSError(domain: "URLError", code: 0, userInfo: nil))
                    return
                }
                
                self.databaseReference.addDocument(data: [
                    "description": description,
                    "datePublished": datePublished,
                    "imageURL": downloadURL.absoluteString
                ]) { error in
                    completion(error)
                }
            }
        }
    }
    func detectMimeType(from data: Data) -> String {
        var c: UInt8 = 0
        data.copyBytes(to: &c, count: 1)
        
        switch c {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x49, 0x4D:
            return "image/tiff"
        case 0x25:
            return "application/pdf"
        case 0xD0:
            return "application/vnd"
        case 0x46:
            return "text/plain"
        default:
            // 기본값으로 application/octet-stream 사용
            return "application/octet-stream"
        }
    }
    
    
}
