//
//  ViewController.swift
//  CropFrame
//
//  Created by devgrishchenko@gmail.com on 05/23/2018.
//  Copyright (c) 2018 devgrishchenko@gmail.com. All rights reserved.
//

import UIKit
import CropFrame

class ViewController: UIViewController {

    var frame: UICropFrameView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.frame = UICropFrameView(frame: CGRect(x: 100, y: 100, width: 200, height: 300))
        self.view.addSubview(frame)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

