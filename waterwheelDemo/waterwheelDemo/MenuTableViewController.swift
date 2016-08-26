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
        return TableViewRows.allValues.indexOf(self)!
    }
}
public struct FrontpageViewContent: Mappable {
    var title: String?
    var body:  String?
    var contentType: String?
    var date: String?

    public init?(_ map: Map) {

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
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableViewRows.allValues.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        cell.textLabel!.text = TableViewRows.allValues[indexPath.row].rawValue

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        switch indexPath.row {
        case TableViewRows.Authentication.index :
            let loginVc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(loginVc, animated: true)
            break;
        case TableViewRows.Views.index :
            let frontpageTableVC = waterwheelViewTableViewController(viewPath: "frontpage", configure: { (cell: ExampleCell, responseRow: FrontpageViewContent) in
                cell.textLabel?.text = responseRow.title
                cell.detailTextLabel?.text = responseRow.contentType
            })

            frontpageTableVC.title = "Frontpage"
            frontpageTableVC.didSelect = { selection in
                let nodeVC = storyboard.instantiateViewControllerWithIdentifier("NodeViewController") as! NodeViewController
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
            super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
