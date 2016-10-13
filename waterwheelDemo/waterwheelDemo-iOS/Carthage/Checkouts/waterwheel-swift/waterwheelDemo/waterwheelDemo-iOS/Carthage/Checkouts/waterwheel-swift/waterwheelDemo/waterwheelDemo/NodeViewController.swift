//
//  NodeViewController.swift
//  waterwheelDemo
//
//  Created by Kyle Browning on 8/26/16.
//  Copyright © 2016 Acquia. All rights reserved.
//

import UIKit


open class NodeViewController: UIViewController {

    @IBOutlet weak var labelTitle: UILabel!

    @IBOutlet weak var labelDate: UILabel!

    @IBOutlet weak var textViewBody: UITextView!


    open var object : FrontpageViewContent!

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.labelTitle.text = object.title
        self.labelDate.text = object.date
        self.textViewBody.text = object.body
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
