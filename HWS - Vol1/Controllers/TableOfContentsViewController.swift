//
//  TableOfContentsViewController.swift
//  HWS - Vol1
//
//  Created by Dilgir Siddiqui on 11/26/20.
//

import UIKit

class TableOfContentsViewController: UIViewController {

    @IBOutlet weak var contentsTableView: UITableView!
    
    var contentsTableViewDatasource = TableOfContentsDatasource()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the Table View
        contentsTableView.delegate = self
        contentsTableView.dataSource = contentsTableViewDatasource
        contentsTableView.reloadData()
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

extension TableOfContentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
