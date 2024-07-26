//
//  NewPostViewController.swift
//  Socially-UIKit
//
//  Created by 어재선 on 7/25/24.
//

import UIKit
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

class NewPostViewController: UIViewController, UITextViewDelegate, PHPickerViewControllerDelegate {
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private let selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select a picture", for: .normal)
        button.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        return button
    }()
    
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.text = "Description"
        tv.textColor = .placeholderText
        return tv
    }()
    
    private let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    private var selectedImageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Post"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        
        
        setupUI()
        setupConstraints()
        
        selectImageButton.addAction(UIAction { [weak self] action in
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .images
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            self?.present(picker, animated: true)
        }, for: .touchUpInside)
        
        postButton.addAction(UIAction { [weak self] action in
            guard let imageData = self?.selectedImageData,
                  let description = self?.descriptionTextView.text,
                  description != "Description" else {
                // Show an alert if image or description is missing
                return
            }
            
            self?.postButton.isEnabled = false
            self?.addData(description: description,
                          datePublished: Date(), data: imageData) { [weak self] error in
                DispatchQueue.main.async {
                    self?.postButton.isEnabled = true
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        // Show an error alert
                        return
                    }
                    print("Upload & post done")
                    self?.dismiss(animated: true)
                }
            }
        }, for: .touchUpInside)
        
        descriptionTextView.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "New Post"
        
        view.addSubview(imageView)
        view.addSubview(selectImageButton)
        view.addSubview(descriptionTextView)
        view.addSubview(postButton)
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        selectImageButton.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        postButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            selectImageButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            selectImageButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
            descriptionTextView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            postButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            postButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            postButton.widthAnchor.constraint(equalToConstant: 200),
            postButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    //  MARK: - UITextFieldDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = .placeholderText
        }
    }
    
    // MARK: - PHPickerViewControllerDelgate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage else { return }
                    self.imageView.image = image
                    self.selectedImageData = image.jpegData(compressionQuality: 0.8)
                    self.selectImageButton.isHidden = true
                }
            }
        }
    }
    
    
    // MARK: - Methods
    func addData(description: String, datePublished: Date, data: Data, completion: @escaping (Error?) -> Void) {
        let path = UUID().uuidString
        let fileRef = storage.child(path)
        
        // 파일 타입 및 MIME 타입 감지
        let mimeType = detectMimeType(from: data)
        
        // 메타데이터 설정
        let metadata = StorageMetadata()
        metadata.contentType = mimeType
        
        fileRef.putData(data, metadata: metadata) { metadata, error in
            if let error = error {
                completion(error)
                return
            }
            
            Thread.sleep(forTimeInterval: 10)
            let thumbRef = Storage.storage().reference().child("thumbs/\(path)_320x200")
            
            thumbRef.downloadURL { url, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let url = url else {
                    completion(NSError(domain: "PostViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"]))
                    return
                }
                
                let post = [
                    "description": description,
                    "datePublished": datePublished,
                    "imageURL": url.absoluteString,
                    "path": path,
                ]
                
                self.db.collection("Posts").addDocument(data: post) { error in
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
