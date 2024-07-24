//
//  AuthViewModel.swift
//  SociallyApp
//
//  Created by 어재선 on 7/23/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AuthenticationServices
import CryptoKit

class AuthViewModel: ObservableObject {
    @Published var user: User?
    var currentNonce: String?
    
    
    func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    // MARK: - Profile Image
    func uploadProfileImage(_ imageData: Data) {
        let storageReference = Storage.storage().reference().child("\(UUID().uuidString)")
        
        // Firebase Storage에 이미지 데이터를 업로드합니다.
        // 'imageData'는 업로드할 이미지의 데이터, 'metadata'는 추가 정보인데 여기서는 사용하지 않습니다.
        storageReference.putData(imageData, metadata: nil) { metadata, error in
            // 업로드 중 에러가 발생했는지 확인합니다.
            if let error = error {
                // 에러가 있다면 함수를 여기서 종료합니다.
                return
            }
            
            // 업로드된 이미지의 다운로드 URL을 가져옵니다.
            storageReference.downloadURL { url, error in
                // 다운로드 URL을 성공적으로 가져왔고, 현재 인증된 사용자가 있는지 확인합니다.
                if let imageURL = url,
                   let user = Auth.auth().currentUser {
                    // 사용자 프로필 변경 요청을 생성합니다.
                    let changeRequest = user.createProfileChangeRequest()
                    // 프로필 사진 URL을 방금 업로드한 이미지의 URL로 설정합니다.
                    changeRequest.photoURL = imageURL
                    // 변경 사항을 Firebase에 커밋(저장)합니다.
                    changeRequest.commitChanges {
                        error in
                        // 프로필 업데이트 중 에러가 발생했는지 확인합니다.
                        if let error = error {
                            // 에러가 있다면 콘솔에 출력하고 함수를 종료합니다.
                            print("\(error.localizedDescription)")
                            return
                        }
                        // 프로필 업데이트가 성공했다면, 현재 사용자 정보를 새로고침합니다.
                        self.user = Auth.auth().currentUser                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: - Sign in with Apple Methods
    func signInWithApple(request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.email]
        request.nonce = sha256(nonce)
    }
    
    func signInWithAppleCompletion(result: Result<ASAuthorization, any Error>) {
        switch result {
        case .success(let authResults):
            switch authResults.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    print("signed in")
                    guard let user = authResult?.user else { return }
                    
                    let userData = ["email": user.email, "uid": user.uid]
                    Firestore.firestore().collection("User")
                        .document(user.uid)
                        .setData(userData as [String : Any]) { _ in
                            print("DEBUG: Did upload user data.")
                        }
                }
                print("\(String(describing: Auth.auth().currentUser?.uid))")
            default:
                break
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - Private Methods
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}
