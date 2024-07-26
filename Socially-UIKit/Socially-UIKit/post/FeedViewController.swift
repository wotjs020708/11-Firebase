//
//  ViewController.swift
//  Socially-UIKit
//
//  Created by 어재선 on 7/25/24.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class FeedViewController: UIViewController {
    enum Section {
        case main
    }
    
    private var db: Firestore!
    private var dataSource: UITableViewDiffableDataSource<Section, Post>!
    private var tableview: UITableView!
    private var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feed"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .white
        db = Firestore.firestore()
        configureTableview()
        configureDataSource()
        startListeningToFirestore()
        
        let barItem = UIBarButtonItem(systemItem: .add,
                                      primaryAction: UIAction { [weak self] action in
            let newPostViewController = NewPostViewController()
            let navigationController = UINavigationController(rootViewController: newPostViewController)
            
            if let sheet = navigationController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
            
            self?.present(navigationController, animated: true, completion: nil)
        })
        
        navigationItem.rightBarButtonItem = barItem
    }
    
    
    func configureTableview() {
        tableview = UITableView(frame: view.bounds, style: .plain)
        let refreshControl = UIRefreshControl()
        refreshControl.addAction(UIAction { [weak self] _ in
            self?.reloadData()
        }, for: .valueChanged)
        tableview.refreshControl = refreshControl
        view.addSubview(tableview)
        tableview.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        tableview.rowHeight = 280
    }
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Post>(tableView: tableview) {
            (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
            
            cell.configureItem(with: item)
            
            let control = UIControl()
                        control.translatesAutoresizingMaskIntoConstraints = false
                        let cellAction = UIAction { [weak self] _ in                
                            let detailViewController = PostDetailViewController(post: item)
                            self?.navigationController?.pushViewController(detailViewController, animated: true)
                        }
                        control.addAction(cellAction, for: .touchUpInside)
                        cell.contentView.addSubview(control)

                        NSLayoutConstraint.activate([
                            control.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                            control.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
                            control.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                            control.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                        ])

            return cell
        }
    }
    
    func reloadData() {
        db.collection("Posts")
            .order(by: "datePublished", descending: true).getDocuments {
                [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                let posts = documents.compactMap { Post(document: $0) }
                posts.forEach { post in
                    if let path = post.path {
                        post.checkImageURL(path)
                    }
                }
                self?.updateDataSource(with: posts)
                self?.tableview.refreshControl?.endRefreshing()
            }
    }
    
    func startListeningToFirestore() {
        listener = db.collection("Posts")
            .order(by: "datePublished", descending: true)
            .addSnapshotListener {
                [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                let posts = documents.compactMap { Post(document: $0) }
                self?.updateDataSource(with: posts)
            }
    }
    
    
    func updateDataSource(with posts: [Post]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    deinit {
        listener?.remove()
    }
    
}

