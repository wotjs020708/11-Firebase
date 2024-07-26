//
//  PostTableViewCell.swift
//  Socially-UIKit
//
//  Created by 어재선 on 7/25/24.
//

import UIKit
import Kingfisher

class PostTableViewCell: UITableViewCell {

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(postImageView)

        NSLayoutConstraint.activate([
            postImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            postImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            postImageView.widthAnchor.constraint(equalToConstant: 320),

            descriptionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 20),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 80),

            contentView.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20)

        ])
    }

    func configureItem(with item: Post) {
        descriptionLabel.text = item.description

        // Load the image asynchronously using Kingfisher
        let processor = DownsamplingImageProcessor(size: postImageView.bounds.size)
        postImageView.kf.indicatorType = .activity

        if let imageURL = item.imageURL {
            postImageView.kf.setImage(
                with: URL(string: imageURL)!,
                placeholder: UIImage(systemName: "photo.artframe"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            if let path = item.path {
                item.checkImageURL(path)
            }
                
            postImageView.image = UIImage(systemName: "photo.artframe")
        }
    }
}
