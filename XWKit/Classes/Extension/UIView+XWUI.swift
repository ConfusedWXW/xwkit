//
//  UIView+XW.swift
//  XWKit
//
//  Created by Jay on 2024/3/1.
//

import Foundation


public extension UIView {
    // 生成图片
    func xwui_toImage() -> UIImage {
        return UIImage.screenshot(fromView: self)
    }
    
    //将当前视图转为UIImage
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
}




public extension UIView {
    typealias FrameWillChangeBlock = (_ view: UIView, _ followingFrame: CGRect) -> CGRect
    typealias FrameDidChangeBlock = (_ view: UIView, _ precedingFrame: CGRect) -> Void
    
#if os(Linux)
#else
    fileprivate enum UIViewKeys: String {
        case viewController = "XWUI.KeyForXWUIViewController"
        case isControllerRootView = "XWUI.KeyForXWIsControllerRootView"
        case frameWillChangeBlock = "XWUI.KeyForXWFrameWillChangeBlock"
        case frameDidChangeBlock = "XWUI.KeyForXWFrameDidChangeBlock"
        case outsideEdge = "XWUI.KeyForOutsideEdge"
    }
#endif
    
    /// 响应区域需要改变的大小，负值表示往外扩大，正值表示往内缩小。
    /// 特别地，如果对 UISlider 使用，则扩大的是圆点的区域。
    /// 当你引入了 XWUINavigationButton，它会使 UIBarButtonItem.customView 也可使用 xwui_outsideEdge（默认不可以，因为 customView 的父容器和 customView 一样大，所以 UINavigationBar 感知不到 customView 有 qmui_outsideEdge）。
//    var xwui_outsideEdge: UIEdgeInsets {
//        get {
//            return getAssociatedValue<UIEdgeInsets>(key: UIViewKeys.outsideEdge.rawValue, object: self as AnyObject)
//        }
//        set {
//            set(associatedValue: newValue, key: UIViewKeys.outsideEdge.rawValue, object: self as AnyObject)
//        }
//    }
    
    /**
     判断当前的 view 是否属于可视（可视的定义为已存在于 view 层级树里，或者在所处的 UIViewController 的 [viewWillAppear, viewWillDisappear) 生命周期之间）
     */
    var xwui_visible: Bool {
        if self.isHidden || self.alpha <= 0.01 { return false }
        if self.window != nil { return true }
        if self.isKind(of: UIWindow.self), let window = self as? UIWindow {
            if #available(iOS 13.0, *) {
                return window.windowScene != nil
            } else {
                return false
            }
        }
        guard let viewController = self.xwui_viewController else { return false }
        return viewController.xwui_visibleState.rawValue >= XWUIViewControllerVisibleState.willAppear.rawValue && viewController.xwui_visibleState.rawValue < XWUIViewControllerVisibleState.willDisappear.rawValue
    }
    
    
    /**
     在 UIView 的 frame 变化前会调用这个 block，变化途径包括 setFrame:、setBounds:、setCenter:、setTransform:，你可以通过返回一个 rect 来达到修改 frame 的目的，最终执行 [super setFrame:] 时会使用这个 block 的返回值（除了 setTransform: 导致的 frame 变化）。
     @param view 当前的 view 本身，方便使用，省去 weak 操作
     @param followingFrame setFrame: 的参数 frame，也即即将被修改为的 rect 值
     @return 将会真正被使用的 frame 值
     @note 仅当 followingFrame 和 self.frame 值不相等时才会被调用
     */
    var xwui_frameWillChangeBlock: UIView.FrameWillChangeBlock? {
        get {
            return getAssociatedValue<UIView.FrameWillChangeBlock>(key: UIViewKeys.frameWillChangeBlock.rawValue, object: self as AnyObject)
        }
        set {
            set(associatedValue: newValue, key: UIViewKeys.frameWillChangeBlock.rawValue, object: self as AnyObject)
        }
    }
    
    /**
     在 UIView 的 frame 变化后会调用这个 block，变化途径包括 setFrame:、setBounds:、setCenter:、setTransform:，可用于监听布局的变化，或者在不方便重写 layoutSubviews 时使用这个 block 代替。
     @param view 当前的 view 本身，方便使用，省去 weak 操作
     @param precedingFrame 修改前的 frame 值
     */
    var xwui_frameDidChangeBlock: UIView.FrameDidChangeBlock? {
        get {
            return getAssociatedValue<UIView.FrameDidChangeBlock>(key: UIViewKeys.frameDidChangeBlock.rawValue, object: self as AnyObject)
        }
        set {
            set(associatedValue: newValue, key: UIViewKeys.frameDidChangeBlock.rawValue, object: self as AnyObject)
        }
    }
    
    
    var xwui_isControllerRootView: Bool {
        get {
            return getAssociatedValue<Bool>(key: UIViewKeys.isControllerRootView.rawValue, object: self as AnyObject) ?? false
        }
        set {
            set(associatedValue: newValue, key: UIViewKeys.isControllerRootView.rawValue, object: self as AnyObject)
        }
    }
    
    private(set) var xwui_viewController: UIViewController? {
        get {
            return getAssociatedValue<UIViewController>(key: UIViewKeys.viewController.rawValue, object: self as AnyObject)
        }
        set {
            set(weakAssociatedValue: newValue, key: UIViewKeys.viewController.rawValue, object: self as AnyObject)
        }
    }
    
    
    internal static let viewSwizzle: () = {
        _ = NothingToSeeHere.overrideImplementation(for: UIViewController.self, targetSelector: #selector(UIViewController.viewDidLoad), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return  { (selfObject) in
                // 调用原有实现
                typealias Imp  = @convention(c) (UIViewController?, Selector)->Void
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                oldImpBlock(selfObject, originCMD)
                
                selfObject.view.xwui_viewController = selfObject
            } as @convention(block) (UIViewController)->Void
        })
        
    }()
}

