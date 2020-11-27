//
//  TableOfContentsDatasource.swift
//  HWS - Vol1
//
//  Created by Dilgir Siddiqui on 11/26/20.
//

import Foundation
import UIKit

class TableOfContentsDatasource: NSObject, UITableViewDataSource {
    
    var contents: [String] {
        get {
            return TableOfContents().contents
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.tableOfContentsCell.rawValue, for: indexPath)
        cell.textLabel?.text = contents[indexPath.row]
        return cell
    }
    
}
