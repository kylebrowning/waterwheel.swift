//
//  waterwheelViewTableViewController.swift
//  waterwheel
//
//  Copyright © 2016 Kyle Browning. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

public struct ViewResponseRow: Mappable {
    var title: String?
    var body:  String?

    public init?(_ map: Map) {

    }

    mutating public func mapping(map: Map) {
        title     <- map["title"]
        body  <- map["body"]
    }
}

public class waterwheelViewTableViewController<Row: Mappable, Cell: UITableViewCell>: UITableViewController {
    public var rows: [Row] = []

    public let reuseIdentifier = "Cell"
    public let configure: (Cell, Row) -> ()
    public var didSelect: (Row) -> () = { _ in }
    public var didFinish: (JSON?, waterwheelViewTableViewController) -> () = { _ in }

    init(items: [Row], configure: (Cell, Row) -> ()) {
        self.configure = configure
        super.init(style: .Plain)
        self.rows = items
    }

    public convenience init(viewPath: (String), configure: (Cell, Row) -> ()) {
        self.init(items: [], configure: configure)
        waterwheel.viewGet(viewPath: viewPath, completionHandler:  { (success, response, json, error) in
            self.didFinish(json, self)

            if (success) {
                var items: [Row] = []
                for (_, subJson):(String, JSON) in json! {
                    let responseRow = Mapper<Row>().map(subJson.rawString())
                    items.append(responseRow!)
                }
                self.rows = items
                self.tableView.reloadData()
            } else {
                print("waterwheel Error fetching view: " + error.localizedDescription)
            }
        })

    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(Cell.self, forCellReuseIdentifier: reuseIdentifier)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = rows[indexPath.row]
        didSelect(item)
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! Cell
        let item = rows[indexPath.row]
        configure(cell, item)
        return cell
    }
}

