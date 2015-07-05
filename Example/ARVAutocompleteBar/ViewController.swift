//
//  ViewController.swift
//  ARVAutocompleteBar
//
//  Created by Arvindh Sukumar on 07/05/2015.
//  Copyright (c) 2015 Arvindh Sukumar. All rights reserved.
//

import UIKit
import ARVAutocompleteBar

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        let view = UIView(frame: self.navigationController!.toolbar.bounds)
        view.backgroundColor = UIColor.redColor()

        ar
        
        self.navigationController?.toolbar.addSubview(view)
    }
}

