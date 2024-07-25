//
//  ViewController.swift
//  Socially-UIKit
//
//  Created by 어재선 on 7/25/24.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {
    enum Section {
        case main
    }
    
    private var db: Firestore!
    private var dataSource: UITableViewDiffableDataSource<Section, Post>!
    private var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feed"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "text.bubble"), tag: 0)
    }

    
    func configureTableview() {
        tableview = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(tableview)
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "feedCell")
        tableview.rowHeight = 280
    }
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Post>(tableView: tableview) {
            (tableview, indexPath, item) -> UITableViewCell? in
            let cell = tableview.dequeueReusableCell(withIdentifier: "PostCell")
            
            var config = cell?.defaultContentConfiguration()
            config?.text = item.description
            
            cell?.contentConfiguration = config
            
            return cell
        }
    }

}

