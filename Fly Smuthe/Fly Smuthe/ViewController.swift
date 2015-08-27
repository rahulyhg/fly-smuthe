//
//  ViewController.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 8/26/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func understandButtonClicked(sender: UIButton) {
        self.performSegueWithIdentifier("understandSegue", sender: self);
        return;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

