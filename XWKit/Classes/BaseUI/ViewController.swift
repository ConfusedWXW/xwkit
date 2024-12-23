//
//  ViewController.swift
//  XWKit
//
//  Created by Jay on 2024/3/2.
//

import UIKit

open class ViewController: UIViewController {
    
    open lazy var contentView: View = {
        let view = View()
        self.view.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        return view
    }()
    

    open lazy var stackView: StackView = {
        let subviews: [UIView] = []
        let view = StackView(arrangedSubviews: subviews)
        view.spacing = 0
        self.contentView.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return view
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()

        // 观察设备方向变化
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // 观察应用程序是否变为活动通知
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateUI()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    

    open func makeUI() {
        updateUI()
    }


    open func updateUI() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    @objc func orientationChanged() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {[weak self] in
            self?.updateUI()
        }
    }
    
    @objc func didBecomeActive() {
        self.updateUI()
    }

    
}
