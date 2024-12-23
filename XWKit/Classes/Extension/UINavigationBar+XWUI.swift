//
//  UINavigationBar+XWUI.swift
//  XWKit
//
//  Created by Jay on 2024/6/1.
//

import Foundation

public extension UINavigationBar {
    
    internal static let navigationBarSwizzle: () = {
        
        // [UIKit Bug] Xcode 14 编译的 App 在 iOS 16.0 上可能存在顶部标题布局错乱
        if #available(iOS 16.0, *) {
            if #available(iOS 16.1, *) {
                // iOS 16.1 系统已修复
            }else{
                _ = NothingToSeeHere.overrideImplementation(for: UINavigationItem.self, targetSelector: #selector(setter: UINavigationItem.titleView), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
                    return { (selfObject, firstArgv) in
                        // 调用原有实现
                        typealias Imp  = @convention(c) (UINavigationItem?, Selector, Any?)->Void
                        let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                        oldImpBlock(selfObject, originCMD, firstArgv)
                        
                        if firstArgv ==  nil { return }
                        selfObject.xwui_navigationBar?.xwuinb_fixTitleViewLayoutInIOS16()
                    } as @convention(block) (UINavigationItem, Any?)->Void
                })
                
                _ = NothingToSeeHere.overrideImplementation(for: UINavigationBar.self, targetSelector: #selector(UINavigationBar.pushItem(_:animated:)), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
                    return { (selfObject, navigationItem, animated) in
                        if !animated, selfObject.topItem?.titleView == nil, navigationItem.titleView != nil {
                            selfObject.xwuinb_fixTitleViewLayoutInIOS16()
                        }
                        
                        // 调用原有实现
                        typealias Imp  = @convention(c) (UINavigationBar?, Selector, Any, Bool)->Void
                        let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                        oldImpBlock(selfObject, originCMD, navigationItem, animated)
                    } as @convention(block) (UINavigationBar, UINavigationItem, Bool)->Void
                })
                
                _ = NothingToSeeHere.overrideImplementation(for: UINavigationBar.self, targetSelector: #selector(UINavigationBar.setItems(_:animated:)), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
                    return { (selfObject, items, animated) in
                        
                        if !animated, selfObject.topItem?.titleView == nil, items.last?.titleView != nil {
                            selfObject.xwuinb_fixTitleViewLayoutInIOS16()
                        }
                        
                        // 调用原有实现
                        typealias Imp  = @convention(c) (UINavigationBar?, Selector, Any, Bool)->Void
                        let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                        oldImpBlock(selfObject, originCMD, items, animated)
                    } as @convention(block) (UINavigationBar, [UINavigationItem], Bool)->Void
                })
                
                
                
                
            }
        }
    }()
    
    
    /**
     UINavigationBar 在 iOS 11 下所有的 item 都会由 contentView 管理，只要在 UINavigationController init 完成后就能拿到 qmui_contentView 的值
     */
    var xwui_contentView: UIView? {
        return self.value(forKeyPath: "visualProvider.contentView") as? UIView
    }
    
    // [UIKit Bug] Xcode 14 编译的 App 在 iOS 16.0 上可能存在顶部标题布局错乱处理
    private func xwuinb_fixTitleViewLayoutInIOS16() {
        guard let titleControlClass = NSClassFromString("_UINavigationBarTitleControl") else { return }
        let titleControl = xwui_contentView?.subviews.first(where: { $0.isKind(of: titleControlClass) })
        titleControl?.xwui_frameWillChangeBlock = { (view, followingFrame) -> CGRect in
            guard let superview = view.superview else { return followingFrame }
            return CGRectSetY(followingFrame, CGRectGetMinYVerticallyCenterInParentRect(superview.bounds, followingFrame))
        }
    }
    
    
}

