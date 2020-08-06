//
//  FurnitureListVC.swift
//  ARKeaApp
//
//  Created by Rathod on 7/27/20.
//  Copyright © 2020 Rathod. All rights reserved.
//

import UIKit

class FurnitureListVC: UITableViewController, Storyboarded {

    @IBOutlet var tblList: UITableView! {
        didSet {
            tblList.backgroundColor = .white
        }
    }
    
    let dataSource: [[String: String]] = [["title": "Chairs", "image": "chair"],
                                          ["title": "Tables", "image": "Table"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblList.tableFooterView = UIView()
        tblList.register(UINib(nibName: "FurnitureCell", bundle: Bundle.main), forCellReuseIdentifier: "FurnitureCell")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FurnitureCell", for: indexPath) as! FurnitureCell
        cell.lblTitle.text = dataSource[indexPath.row]["title"]
        cell.imgView.image = UIImage(named: dataSource[indexPath.row]["image"]!)
        cell.cellType = dataSource[indexPath.row]["title"] ?? ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FurnitureCell
        let vc = ViewController.instantiate()
        vc.objectType = cell.cellType
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
