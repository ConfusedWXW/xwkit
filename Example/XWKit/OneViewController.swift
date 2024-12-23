//
//  OneViewController.swift
//  testIos
//
//  Created by Jay on 2024/5/24.
//

import UIKit
import XWKit

class OneViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let r = CGFloat(arc4random() % 255) / 255
        let g = CGFloat(arc4random() % 255) / 255
        let b = CGFloat(arc4random() % 255) / 255
        view.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1)
        
        
        
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 150, height: 44))
        btn.addTarget(self, action: #selector(aa), for: .touchUpInside)
        btn.backgroundColor = .white
        view.addSubview(btn)
    }
    

    @objc func aa() {
        print("😂😂😂2\(self.navigationController?.interactivePopGestureRecognizer?.delegate)")
        navigationController?.pushViewController(OneViewController(), animated: true)
    }

}


//extension OneViewController {
//    
////    func shouldPopViewControllerByBackButtonOrPopGesture(byPopGesture: Bool) -> Bool {
////        return false
////    }
//    
//}
