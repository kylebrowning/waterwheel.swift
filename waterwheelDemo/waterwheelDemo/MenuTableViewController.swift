//
//  MenuTableViewController.swift
//  waterwheelDemo
//
//  Created by Kyle Browning on 8/24/16.
//  Copyright © 2016 Acquia. All rights reserved.
//

import UIKit

enum DrawerSection: Int {
    case ViewSelection
    case DrawerWidth
    case ShadowToggle
    case OpenDrawerGestures
    case CloseDrawerGestures
    case CenterHiddenInteraction
    case StretchDrawer
}

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
            print ("okay")

        default:
            print ("do nothing")
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
