//
//  ViewController.swift
//  XWKit
//
//  Created by Jay on 03/01/2024.
//  Copyright (c) 2024 Jay. All rights reserved.
//

import UIKit
import XWKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let navVC = UINavigationController(rootViewController: OneViewController())
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: false)
    }
}

