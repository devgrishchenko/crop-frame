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

    
    @IBOutlet var cropFrameView: UICropFrameView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let image: UIImage = self.cropFrameView.crop
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
