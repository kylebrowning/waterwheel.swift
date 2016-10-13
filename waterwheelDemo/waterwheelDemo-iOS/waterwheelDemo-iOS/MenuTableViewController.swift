//
//  MenuTableViewController.swift
//  waterwheelDemo
//
//  Created by Kyle Browning on 8/24/16.
//  Copyright © 2016 Acquia. All rights reserved.
//

import UIKit
import waterwheel
import ObjectMapper
// NO such module error? run `carthage update`

/**
 Provide an enum to handle our rows

 - Authentication:  login Auth Action
 - Logout: logout Auth Action
 */
enum TableViewRows: String {
    case Authentication = "Authentication"
    case Views          = "Views"

    static let allValues = [Authentication, Views]
    var index : Int {
        return TableViewRows.allValues.index(of: self)!
    }
}
public struct FrontpageViewContent: Mappable {
    var title: String?
    var body:  String?
    var contentType: String?
    var date: String?

    public init?(map: Map) {

    }

    mutating public func mapping(map: Map) {
        title     <- map["title"]
        body  <- map["body"]
        contentType <- map["type"]
        date <- map["created"]
    }
}
final class ExampleCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




class MenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableViewRows.allValues.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel!.text = TableViewRows.allValues[(indexPath as NSIndexPath).row].rawValue

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        switch (indexPath as NSIndexPath).row {
        case TableViewRows.Authentication.index :
            let loginVc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(loginVc, animated: true)
            break;
        case TableViewRows.Views.index :
            let frontpageTableVC = waterwheelViewTableViewController(viewPath: "frontpage", configure: { (cell: ExampleCell, responseRow: FrontpageViewContent) in
                cell.textLabel?.text = responseRow.title
                cell.detailTextLabel?.text = responseRow.contentType
            })

            frontpageTableVC.title = "Frontpage"
            frontpageTableVC.didSelect = { selection in
                let nodeVC = storyboard.instantiateViewController(withIdentifier: "NodeViewController") as! NodeViewController
                nodeVC.object = selection
                print(selection)
                
                self.navigationController?.pushViewController(nodeVC, animated: true)
            }
            self.navigationController?.pushViewController(frontpageTableVC, animated: true)

        default:
            print ("do nothing")
        }
    }

    final class ExampleCell: UITableViewCell {
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
