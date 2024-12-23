//
//  UINavigationItem+XWUI.swift
//  XWKit
//
//  Created by Jay on 2024/5/18.
//

import Foundation

public extension UINavigationItem {
    var xwui_navigationBar: UINavigationBar? {
        // UINavigationItem 内部有个方法可以获取 navigationBar
        let selector = NSSelectorFromString("navigationBar")
        if self.responds(to: selector) {
            return self.perform(selector).takeRetainedValue() as? UINavigationBar
        }
        return nil
    }
    
    var xwui_navigationController: UINavigationController? {
        guard let navigationBar = xwui_navigationBar else { return nil }
        let navigationController = navigationBar.superview?.xwui_viewController
        if navigationController?.isKind(of: UINavigationController.self) ?? false {
            return navigationController as? UINavigationController
        }
        return nil
    }
    
    // 当前UINavigationItem对应显示的viewController
    var xwui_viewController: UIViewController? {
        guard let navigationBar = xwui_navigationBar,
                let navigationController = xwui_navigationController,
              let index = navigationBar.items?.firstIndex(of: self),
                index < navigationController.viewControllers.count else { return nil }
        return navigationController.viewControllers[index]
    }
    
    // 前一个UINavigationItem
    var xwui_previousItem: UINavigationItem? {
        guard let items = xwui_navigationBar?.items,
                items.count > 0,
                let index = items.firstIndex(of: self),
                index > 0 else { return nil }
        return items[index - 1]
        
    }
    
    // 后一个UINavigationItem
    var xwui_nextItem: UINavigationItem? {
        guard let items = xwui_navigationBar?.items,
                items.count > 0,
                let index = items.firstIndex(of: self),
              index < items.count - 1 else { return nil }
        return items[index + 1]
        
    }
}


