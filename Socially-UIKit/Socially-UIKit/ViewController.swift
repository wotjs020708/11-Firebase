//
//  ViewController.swift
//  Socially-UIKit
//
//  Created by 어재선 on 7/25/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feed"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "text.bubble"), tag: 0)
    }


}

