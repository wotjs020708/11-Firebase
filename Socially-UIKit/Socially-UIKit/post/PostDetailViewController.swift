//
//  PostDetailViewController.swift
//  Socially-UIKit
//
//  Created by 어재선 on 7/26/24.
//

import UIKit

class PostDetailViewController: UIViewController {
    let post: Post

      init(post: Post) {
          self.post = post
          super.init(nibName: nil, bundle: nil)
      }

      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }

      override func viewDidLoad() {
          super.viewDidLoad()
          title = "Post Detail"
          self.navigationController?.navigationBar.prefersLargeTitles = true
          view.backgroundColor = .systemBackground


      }


      /*
      // MARK: - Navigation
      // In a storyboard-based application, you will often want to do a little preparation before navigation
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          // Get the new view controller using segue.destination.
          // Pass the selected object to the new view controller.
      }
      */

}
