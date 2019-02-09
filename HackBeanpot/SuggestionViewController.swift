//
//  TableViewController.swift
//  HackBeanpot
//
//  Created by J. Lozano on 2/9/19.
//  Copyright © 2019 John Abreu. All rights reserved.
//

import Foundation
import UIKit
import TransitionButton

class SuggestionViewController: CustomTransitionViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tags: [String] = []
    
    var photosByTag: [[(String, String)]] = []
    var photosByLocation: [[(String, String)]] = []

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell") as! MainTableViewCell
        
        print("bitch why u a pussy ass hoe: \(tags[indexPath.row])")
        
        tableViewCell.tagLabel.text = tags[indexPath.row]
        tableViewCell.photos = photosByTag[indexPath.row]
        tableViewCell.configure()
        
        return tableViewCell
        
    }
    
    

}
