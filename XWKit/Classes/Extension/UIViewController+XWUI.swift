//
//  UIViewController+XWUI.swift
//  XWKit
//
//  Created by Jay on 2024/6/3.
//

import Foundation

public enum XWUIViewControllerVisibleState: Int {
    case unknow               // 初始化完成但尚未触发 viewDidLoad
    case viewDidLoad        // 触发了 viewDidLoad
    case willAppear          // 触发了 viewWillAppear
    case didAppear           // 触发了 viewDidAppear
    case willDisappear      // 触发了 viewWillDisappear
    case didDisappear       // 触发了 viewDidDisappear
}



public extension UIViewController {
#if os(Linux)
#else
fileprivate enum UIViewControllerKeys: String {
    case dataLoaded = "XWUI.KeyForDataLoaded"
    case visibleState = "XWUI.KeyForVisibleState"
    case didAppearAndLoadDataBlock = "XWUI.KeyForDidAppearAndLoadDataBlock"
    case prefersHomeIndicatorAutoHiddenBlock = "XWUI.KeyForPrefersHomeIndicatorAutoHiddenBlock"
    case preferredStatusBarUpdateAnimationBlockBlock = "XWUI.KeyForPreferredStatusBarUpdateAnimationBlockBlock"
    case preferredStatusBarStyleBlock = "XWUI.KeyForPreferredStatusBarStyleBlock"
    case prefersStatusBarHiddenBlock = "XWUI.KeyForPrefersStatusBarHiddenBlock"
    case visibleStateDidChangeBlock = "XWUI.KeyForVisibleStateDidChangeBlock"
    case navigationControllerPopGestureRecognizerChanging = "XWUI.KeyForNavigationControllerPopGestureRecognizerChanging"
    case poppingByInteractivePopGestureRecognizer = "XWUI.KeyForPoppingByInteractivePopGestureRecognizer"
    case willAppearByInteractivePopGestureRecognizer = "XWUI.KeyForWillAppearByInteractivePopGestureRecognizer"
}
#endif
    
    static let appSizeWillChangeNotification = Notification.Name.init("AppSizeWillChangeNotification")
    static let precedingAppSizeUserInfoKey: String = "PrecedingAppSizeUserInfoKey"
    static let followingAppSizeUserInfoKey: String = "FollowingAppSizeUserInfoKey"
    
    typealias NoParameterAndReturnVoidBlock = () -> Void
    typealias NoParameterAndReturnBoolBlock = () -> Bool
    typealias PreferredStatusBarStyleBlockBlock = () -> UIStatusBarStyle
    typealias PreferredStatusBarUpdateAnimationBlock = () -> UIStatusBarAnimation
    typealias VisibleStateDidChangeBlock = (_ viewController: UIViewController, _ visibleState: XWUIViewControllerVisibleState) -> Void
    
    
    // 请在你的数据加载完成时手动修改这个属性为 YES，如果此时界面已经走过 viewDidAppear:，则 xwui_didAppearAndLoadDataBlock 会被立即执行，如果此时界面尚未走 viewDidAppear:，则等到 viewDidAppear: 时，xwui_didAppearAndLoadDataBlock 就会被自动执行。
    var xwui_dataLoaded: Bool {
        get {
            return getAssociatedValue<Bool>(key: UIViewControllerKeys.dataLoaded.rawValue, object: self as AnyObject) ?? false
        }
        set {
            set(associatedValue: newValue, key: UIViewControllerKeys.dataLoaded.rawValue, object: self as AnyObject)
            
            guard let block = xwui_didAppearAndLoadDataBlock, newValue, xwui_visibleState.rawValue > XWUIViewControllerVisibleState.didAppear.rawValue else { return }
            block()
            xwui_didAppearAndLoadDataBlock = nil
        }
    }
    
    // 当前 UIViewController.class 是否为系统默认的几个 container viewController（也即 UINavigationController、UITabBarController、UISplitViewController）。
    static var xwui_isSystemContainerViewController: Bool {
        let clzs = [UINavigationController.self, UITabBarController.self, UISplitViewController.self]
        for clz in clzs {
            if self.isSubclass(of: clz) {
                return true
            }
        }
       return false
    }
    
    // 当前 UIViewController 是否为系统默认的几个 container viewController（也即 UINavigationController、UITabBarController、UISplitViewController）。
    var xwui_isSystemContainerViewController: Bool {
        return Self.xwui_isSystemContainerViewController
    }
    
    // 当数据加载完（什么时候算是“加载完”需要通过属性 xwui_dataLoaded 来设置）并且界面已经走过 viewDidAppear: 时，这个 block 会被执行，执行结束后 block 会被清空，以避免重复调用。
    // @warning 注意，如果你在 viewWillAppear: 里设置该 block，则要留意在下一级界面手势返回触发后又取消，会触发前一个界面的 viewWillAppear:、viewDidDisappear:，过程中不会触发 viewDidAppear:，所以这次设置的 block 并没有人消费它。
    var xwui_didAppearAndLoadDataBlock: NoParameterAndReturnVoidBlock? {
        get {
            return getAssociatedValue<NoParameterAndReturnVoidBlock>(key: UIViewControllerKeys.didAppearAndLoadDataBlock.rawValue, object: self as AnyObject)
        }
        set {
            set(associatedValue: newValue, key: UIViewControllerKeys.didAppearAndLoadDataBlock.rawValue, object: self as AnyObject)
        }
    }
    
    // 获取当前 viewController 所处的的生命周期阶段（也即 viewDidLoad/viewWillApear/viewDidAppear/viewWillDisappear/viewDidDisappear）
    private(set) var xwui_visibleState: XWUIViewControllerVisibleState {
        get {
            return getAssociatedValue<XWUIViewControllerVisibleState>(key: UIViewControllerKeys.visibleState.rawValue, object: self as AnyObject) ?? .unknow
        }
        set {
            let valueChanged = xwui_visibleState != newValue
            let rowValue = newValue.rawValue
            set(associatedValue: newValue, key: UIViewControllerKeys.visibleState.rawValue, object: self as AnyObject)
            if valueChanged, let block = xwui_visibleStateDidChangeBlock {
                block(self, newValue)
            }
        }
    }
    
    // 在当前 viewController 生命周期发生变化的时候调用
    var xwui_visibleStateDidChangeBlock: VisibleStateDidChangeBlock? {
        get {
            return getAssociatedValue<VisibleStateDidChangeBlock>(key: UIViewControllerKeys.visibleStateDidChangeBlock.rawValue, object: self as AnyObject)
        }
        set {
            set(associatedValue: newValue, key: UIViewControllerKeys.visibleStateDidChangeBlock.rawValue, object: self as AnyObject)
        }
    }
    
    // 获取和自身处于同一个UINavigationController里的上一个UIViewController
    var xwui_previousViewController: UIViewController? {
        guard let viewControllers = self.navigationController?.viewControllers else { return nil }
        let index = viewControllers.firstIndex(of: self)
        if let index = index, index != NSNotFound, index > 0 {
            return viewControllers[index - 1]
        }
        return nil
    }
    
    // 获取上一个UIViewController的title，可用于设置自定义返回按钮的文字
    var xwui_previousViewControllerTitle: String? {
        if let previousViewController = self.xwui_previousViewController {
            return previousViewController.title ?? previousViewController.navigationItem.title
        }
        return nil;
    }
    
    // 获取当前controller里的最高层可见viewController（可见的意思是还会判断self.view.window是否存在）
    var xwui_visibleViewControllerIfExist: UIViewController? {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.xwui_visibleViewControllerIfExist
        }
        
        if self.isKind(of: UINavigationController.self), let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.xwui_visibleViewControllerIfExist
        }
        
        if self.isKind(of: UITabBarController.self), let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.xwui_visibleViewControllerIfExist
        }
        
        if self.xwui_isViewLoadedAndVisible {
            return self;
        }
        return nil;
    }
    
    // 当前 viewController 是否是被以 present 的方式显示的，是则返回 YES，否则返回 NO
    var xwui_isPresented: Bool {
        var viewController: UIViewController = self
        if let navigationController = self.navigationController {
            if navigationController.xwui_rootViewController != self { return false }
            viewController = navigationController
        }
        let result = viewController.presentingViewController?.presentedViewController == viewController
        return result;
    }
    
    // 是否应该响应一些UI相关的通知，例如 UIKeyboardNotification、UIMenuControllerNotification等，因为有可能当前界面已经被切走了（push到其他界面），但仍可能收到通知，所以在响应通知之前都应该做一下这个判断
    var xwui_isViewLoadedAndVisible: Bool {
        return self.isViewLoaded && self.view.xwui_visible
    }
    /**
     *  UINavigationBar 在 self.view 坐标系里的 maxY，一般用于 self.view.subviews 布局时参考用
     *  @warning 注意由于使用了坐标系转换的计算，所以要求在 self.view.window 存在的情况下使用才可以，因此请勿在 viewDidLoad 内使用，建议在 viewDidLayoutSubviews、viewWillAppear: 里使用。
     *  @warning 如果不存在 UINavigationBar，则返回 0
     */
    var xwui_navigationBarMaxYInViewCoordinator: CGFloat {
        guard self.isViewLoaded else { return 0 }
        // 手势返回过程中 self.navigationController 已经不存在了，所以暂时通过遍历 view 层级的方式去获取到 navigationController 的引用
        var navigationController = self.navigationController
        if navigationController == nil {
            let vc = self.view.superview?.superview?.xwui_viewController
            if vc?.isKind(of: UINavigationController.self) ?? false, let vc = vc as? UINavigationController {
                navigationController = vc
            }
        }
        
        if navigationController == nil { return 0 }
        guard let navigationBar = navigationController?.navigationBar else { return 0 }
        let barMinX = CGRectGetMinX(navigationBar.frame)
        let barPresentationMinX = navigationBar.layer.presentation() != nil ?  CGRectGetMinX(navigationBar.layer.presentation()!.frame) : 0
        let superviewX = self.view.superview != nil ? CGRectGetMinX(self.view.superview!.frame) : 0
        let superviewX2 = self.view.superview?.superview != nil ? CGRectGetMinX(self.view.superview!.superview!.frame) : 0
        
        if self.xwui_navigationControllerPoppingInteracted {
            if barMinX != 0, barMinX == barPresentationMinX {
                // 返回到无 bar 的界面
                return 0
            }else if barMinX > 0 {
                if self.xwui_willAppearByInteractivePopGestureRecognizer {
                    // 要手势返回去的那个界面隐藏了 bar
                    return 0
                }
            }else if barMinX < 0 {
                // 正在手势返回的这个界面隐藏了 bar
                if !self.xwui_willAppearByInteractivePopGestureRecognizer {
                    return 0;
                }
            } else {
                // 正在手势返回的这个界面隐藏了 bar
                if barPresentationMinX != 0, !self.xwui_willAppearByInteractivePopGestureRecognizer {
                    return 0;
                }
            }
            
        }else{
            if barMinX > 0 {
                // 正在 pop 回无 bar 的界面
                if superviewX2 <= 0 {
                    // 即将回到的那个无 bar 的界面
                    return 0;
                }
            } else if barMinX < 0 {
                if barPresentationMinX < 0 {
                    // 从无 bar push 进无 bar 的界面
                    return 0;
                }
                // 正在从有 bar 的界面 push 到无 bar 的界面（bar 被推到左边屏幕外，所以是负数）
                if superviewX >= 0 {
                    // 即将进入的那个无 bar 的界面
                    return 0;
                }
            } else {
                if superviewX < 0, barPresentationMinX != 0 {
                    // 无 bar push 进有 bar 的界面时，背后的那个无 bar 的界面
                    return 0;
                }
                if superviewX2 > 0, barPresentationMinX < 0 {
                    // 无 bar pop 回有 bar 的界面时，被 pop 掉的那个无 bar 的界面
                    return 0;
                }
            }
        }
        
        let navigationBarFrameInView = self.view.convert(navigationBar.frame, from: navigationBar.superview)
        let navigationBarFrame = CGRectIntersection(self.view.bounds, navigationBarFrameInView)
        
        // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
        let isNan = navigationBarFrame.origin.x.isNaN || navigationBarFrame.origin.y.isNaN || navigationBarFrame.size.width.isNaN || navigationBarFrame.size.height.isNaN
        let isinf = navigationBarFrame.origin.x.isInfinite || navigationBarFrame.origin.y.isInfinite || navigationBarFrame.size.width.isInfinite || navigationBarFrame.size.height.isInfinite
        if !CGRectIsNull(navigationBarFrame),
            !CGRectIsInfinite(navigationBarFrame),
           !isNan,
           !isinf {
            let result = CGRectGetMaxY(navigationBarFrame);
            return result;
        }
        return 0;
    }
    
    // 提供一个 block 可以方便地控制是否要隐藏状态栏，适用于无法重写父类方法的场景。默认不实现这个 block 则不干预显隐。
    var xwui_prefersStatusBarHiddenBlock: NoParameterAndReturnBoolBlock?{
        get {
            return getAssociatedValue<NoParameterAndReturnBoolBlock>(key: UIViewControllerKeys.prefersStatusBarHiddenBlock.rawValue, object: self as AnyObject)
        }
        set {
            set(associatedValue: newValue, key: UIViewControllerKeys.prefersStatusBarHiddenBlock.rawValue, object: self as AnyObject)
        }
    }
    
    // 提供一个 block 可以方便地控制状态栏样式，适用于无法重写父类方法的场景。默认不实现这个 block 则不干预样式。
    // @note iOS 13 及以后，自己显示的 UIWindow 无法盖住状态栏了，但 iOS 12 及以前的系统，以 UIWindow 显示的浮层是可以盖住状态栏的，请知悉。
    // @note 对于 QMUISearchController，这个 block 的返回值将会用于控制搜索状态下的状态栏样式
    var xwui_preferredStatusBarStyleBlock: PreferredStatusBarStyleBlockBlock? {
        get {
            return getAssociatedValue<PreferredStatusBarStyleBlockBlock>(key: UIViewControllerKeys.preferredStatusBarStyleBlock.rawValue, object: self as AnyObject)
        }
        set {
            set(associatedValue: newValue, key: UIViewControllerKeys.preferredStatusBarStyleBlock.rawValue, object: self as AnyObject)
        }
    }
    
    // 提供一个 block 可以方便地控制状态栏动画，适用于无法重写父类方法的场景。默认不实现这个 block 则不干预动画。
    var xwui_preferredStatusBarUpdateAnimationBlock: PreferredStatusBarUpdateAnimationBlock? {
        get {
            return getAssociatedValue<PreferredStatusBarUpdateAnimationBlock>(key: UIViewControllerKeys.preferredStatusBarUpdateAnimationBlockBlock.rawValue, object: self as AnyObject)
        }
        set {
            set(associatedValue: newValue, key: UIViewControllerKeys.preferredStatusBarUpdateAnimationBlockBlock.rawValue, object: self as AnyObject)
        }
    }
    
    // 提供一个 block 可以方便地控制全面屏设备屏幕底部的 Home Indicator 的显隐，适用于无法重写父类方法的场景。默认不实现这个 block 则不干预显隐。
    var xwui_prefersHomeIndicatorAutoHiddenBlock: NoParameterAndReturnBoolBlock? {
        get {
            return getAssociatedValue<NoParameterAndReturnBoolBlock>(key: UIViewControllerKeys.prefersHomeIndicatorAutoHiddenBlock.rawValue, object: self as AnyObject)
        }
        set {
            set(associatedValue: newValue, key: UIViewControllerKeys.prefersHomeIndicatorAutoHiddenBlock.rawValue, object: self as AnyObject)
        }
    }
    
    /**
     获取当前 viewController 的 statusBar 显隐状态，与系统 prefersStatusBarHidden 的区别在于，系统的方法在对 containerViewController（例如 UITabBarController、UINavigationController 等）调用时，返回的是 containerViewController 自身的 prefersStatusBarHidden 的值，但真正决定 statusBar 显隐的是该 containerViewController 的 childViewControllerForStatusBarHidden 的 prefersStatusBarHidden 的值，所以只有用 xwui_prefersStatusBarHidden 才能拿到真正的值。
     */
    var xwui_prefersStatusBarHidden: Bool {
        if let vc = self.childForStatusBarHidden {
            return vc.xwui_prefersStatusBarHidden
        }
        return self.prefersStatusBarHidden
    }
    
    /**
     获取当前 viewController 的 statusBar style，与系统 preferredStatusBarStyle 的区别在于，系统的方法在对 containerViewController（例如 UITabBarController、UINavigationController 等）调用时，返回的是 containerViewController 自身的 preferredStatusBarStyle 的值，但真正决定 statusBar style 的是该 containerViewController 的 childViewControllerForStatusBarHidden 的 preferredStatusBarStyle 的值，所以只有用 xwui_preferredStatusBarStyle 才能拿到真正的值。
     */
    var xwui_preferredStatusBarStyle: UIStatusBarStyle {
        if let vc = self.childForStatusBarStyle {
            return vc.xwui_preferredStatusBarStyle
        }
        return self.preferredStatusBarStyle
    }
    
    /**
     判断当前 viewController 是否具备显示 LargeTitle 的条件
     @warning 需要 viewController 在 navigationController 栈内才能正确判断
     */
    var xwui_prefersLargeTitleDisplayed: Bool {
        guard let navigationController = self.navigationController else { return false }
        let navigationBar = navigationController.navigationBar
        if !navigationBar.prefersLargeTitles { return false }
        if self.navigationItem.largeTitleDisplayMode == .always { return true }
        if self.navigationItem.largeTitleDisplayMode == .never { return false }
        if self.navigationItem.largeTitleDisplayMode == .automatic {
            if navigationController.viewControllers.first == self {
                return true
            }
            if let index = navigationController.viewControllers.firstIndex(of: self) {
                let previousViewController = navigationController.viewControllers[index - 1]
                return previousViewController.xwui_prefersLargeTitleDisplayed
            }
        }
        return false
    }
    
    
    // MARK: UINavigationController
    // 判断当前 viewController 是否处于手势返回中，仅对当前手势返回涉及到的前后两个 viewController 有效
    var xwui_navigationControllerPoppingInteracted: Bool {
        return self.xwui_poppingByInteractivePopGestureRecognizer || self.xwui_willAppearByInteractivePopGestureRecognizer
    }
    
    /// 基本与上一个属性 xwui_navigationControllerPoppingInteracted 相同，只不过 xwui_navigationControllerPoppingInteracted 是在 began 时就为 YES，而这个属性仅在 changed 时才为 YES。
    /// @note viewController 会在走完 viewWillAppear: 之后才将这个值置为 YES。
    var xwui_navigationControllerPopGestureRecognizerChanging: Bool {
        get {
            return getAssociatedValue<Bool>(key: UIViewControllerKeys.navigationControllerPopGestureRecognizerChanging.rawValue, object: self as AnyObject) ?? false
        }
        set {
            set(associatedValue: newValue, key: UIViewControllerKeys.navigationControllerPopGestureRecognizerChanging.rawValue, object: self as AnyObject)
        }
    }
    
    /// 当前 viewController 是否正在被手势返回 pop
    var xwui_poppingByInteractivePopGestureRecognizer: Bool {
        get {
            return getAssociatedValue<Bool>(key: UIViewControllerKeys.poppingByInteractivePopGestureRecognizer.rawValue, object: self as AnyObject) ?? false
        }
        set {
            set(associatedValue: newValue, key: UIViewControllerKeys.poppingByInteractivePopGestureRecognizer.rawValue, object: self as AnyObject)
        }
    }
    
    /// 当前 viewController 是否是手势返回中，背后的那个界面
    var xwui_willAppearByInteractivePopGestureRecognizer: Bool {
        get {
            return getAssociatedValue<Bool>(key: UIViewControllerKeys.willAppearByInteractivePopGestureRecognizer.rawValue, object: self as AnyObject) ?? false
        }
        set {
            set(associatedValue: newValue, key: UIViewControllerKeys.willAppearByInteractivePopGestureRecognizer.rawValue, object: self as AnyObject)
        }
    }
    
    
    //  判断当前 viewController 是否为传入的 viewController 本身，或是其“子控制器” （childViewController）、孙子控制器（即 childViewController 的 childViewController ...）
    func xwui_isDescendantOfViewController(viewController: UIViewController) -> Bool {
        var parentViewController: UIViewController? = self
        while (parentViewController != nil) {
            if (parentViewController == viewController) {
                return true
            }
            parentViewController = parentViewController?.parent
        }
        return false
    }
    
    
    
    
    
    internal static let viewControllerSwizzle: () = {
        // viewDidLoad
        let viewDidLoad = NothingToSeeHere.overrideImplementation(for: UIViewController.self, targetSelector: #selector(UIViewController.viewDidLoad), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject) in
                // 调用原有实现
                typealias Imp  = @convention(c) (UIViewController?, Selector)->Void
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                oldImpBlock(selfObject, originCMD)
                
                selfObject.xwui_visibleState = .viewDidLoad
            } as @convention(block) (UIViewController)->Void
        })
        if !viewDidLoad {
            UIViewController.vcSwizzleViewDidLoad
        }
        
        // viewWillAppear
        _ = NothingToSeeHere.overrideImplementation(for: UIViewController.self, targetSelector: #selector(UIViewController.viewWillAppear(_:)), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, animated) in
                // 调用原有实现
                typealias Imp  = @convention(c) (UIViewController?, Selector, Bool)->Void
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                oldImpBlock(selfObject, originCMD, animated)
                
                selfObject.xwui_visibleState = .willAppear
            } as @convention(block) (UIViewController, Bool)->Void
        })
        
        // viewDidAppear
        _ = NothingToSeeHere.overrideImplementation(for: UIViewController.self, targetSelector: #selector(UIViewController.viewDidAppear(_:)), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, animated) in
                // 调用原有实现
                typealias Imp  = @convention(c) (UIViewController?, Selector, Bool)->Void
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                oldImpBlock(selfObject, originCMD, animated)
                
                selfObject.xwui_visibleState = .didAppear
                
                if selfObject.xwui_dataLoaded, let block = selfObject.xwui_didAppearAndLoadDataBlock {
                    block()
                    selfObject.xwui_didAppearAndLoadDataBlock = nil
                }
            } as @convention(block) (UIViewController, Bool)->Void
        })
        
        // viewWillDisappear
        _ = NothingToSeeHere.overrideImplementation(for: UIViewController.self, targetSelector: #selector(UIViewController.viewWillDisappear(_:)), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, animated) in
                // 调用原有实现
                typealias Imp  = @convention(c) (UIViewController?, Selector, Bool)->Void
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                oldImpBlock(selfObject, originCMD, animated)
                
                selfObject.xwui_visibleState = .willDisappear
            } as @convention(block) (UIViewController, Bool)->Void
        })
        
        // viewDidDisappear
        _ = NothingToSeeHere.overrideImplementation(for: UIViewController.self, targetSelector: #selector(UIViewController.viewDidDisappear(_:)), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, animated) in
                // 调用原有实现
                typealias Imp  = @convention(c) (UIViewController?, Selector, Bool)->Void
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                oldImpBlock(selfObject, originCMD, animated)
                
                selfObject.xwui_visibleState = .didDisappear
            } as @convention(block) (UIViewController, Bool)->Void
        })
        
        // viewWillTransition(to:with:)
        _ = NothingToSeeHere.overrideImplementation(for: UIViewController.self, targetSelector: #selector(UIViewController.viewWillTransition(to:with:)), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, size, coordinator) in
                if selfObject == UIApplication.shared.delegate?.window??.rootViewController {
                    let originalSize = selfObject.view.frame.size
                    let sizeChanged = !CGSizeEqualToSize(originalSize, size)
                    if sizeChanged {
                        NotificationCenter.default.post(name: UIViewController.appSizeWillChangeNotification, object: nil, userInfo: [
                            precedingAppSizeUserInfoKey: originalSize,
                            followingAppSizeUserInfoKey: size
                        ])
                    }
                }
                
                
                // 调用原有实现
                typealias Imp  = @convention(c) (UIViewController?, Selector, CGSize, UIViewControllerTransitionCoordinator)->Void
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                oldImpBlock(selfObject, originCMD, size, coordinator)
            } as @convention(block) (UIViewController, CGSize, UIViewControllerTransitionCoordinator)->Void
        })
        
        
        // iOS 11 及以后不 override prefersStatusBarHidden 而是通过私有方法来实现，是因为系统会先通过 +[UIViewController doesOverrideViewControllerMethod:inBaseClass:] 方法来判断当前的 UIViewController 有没有重写 prefersStatusBarHidden 方法，有的话才会去调用 prefersStatusBarHidden，而如果我们用 swizzle 的方式去重写 prefersStatusBarHidden，系统依然会认为你没有重写该方法，于是不会调用，于是 block 无效。对于 iOS 10 及以前的系统没有这种逻辑，所以没问题。
        // 特别的，只有 hidden 操作有这种逻辑，而 style、animation 等操作不管在哪个 iOS 版本里都是没有这种逻辑的
        
        // _preferredStatusBarVisibility
        _ = NothingToSeeHere.overrideImplementation(for: UIViewController.self, targetSelector:  NSSelectorFromString("_preferredStatusBarVisibility"), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject) in
                // 为了保证重写 prefersStatusBarHidden 的优先级比 block 高，这里要判断一下 qmui_hasOverrideUIKitMethod 的值
                if selfObject.xwui_hasOverrideUIKitMethod(NSSelectorFromString("prefersStatusBarHidden")) == false,
                   let block = selfObject.xwui_prefersStatusBarHiddenBlock{
                    return block() ? 1 : 2 // 系统返回的 1 表示隐藏，2 表示显示，0 不清楚含义
                }
                
                // 调用原有实现
                typealias Imp  = @convention(c) (UIViewController?, Selector)->Int
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                return oldImpBlock(selfObject, originCMD)
            } as @convention(block) (UIViewController)->Int
        })
        
        // prefersHomeIndicatorAutoHidden
        _ = NothingToSeeHere.overrideImplementation(for: UIViewController.self, targetSelector: #selector(getter: UIViewController.prefersHomeIndicatorAutoHidden), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
                return { (selfObject) in
                    if let block = selfObject.xwui_prefersHomeIndicatorAutoHiddenBlock {
                        return block()
                    }
                    
                    // 调用原有实现
                    typealias Imp  = @convention(c) (UIViewController?, Selector)->Bool
                    let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                    return oldImpBlock(selfObject, originCMD)
                } as @convention(block) (UIViewController)->Bool
            })
        
        // preferredStatusBarUpdateAnimation
        _ = NothingToSeeHere.overrideImplementation(for: UIViewController.self, targetSelector: #selector(getter: UIViewController.preferredStatusBarUpdateAnimation), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
                return { (selfObject) in
                    if let block = selfObject.xwui_preferredStatusBarUpdateAnimationBlock {
                        return block()
                    }
                    
                    // 调用原有实现
                    typealias Imp  = @convention(c) (UIViewController?, Selector)->UIStatusBarAnimation
                    let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                    return oldImpBlock(selfObject, originCMD)
                } as @convention(block) (UIViewController)->UIStatusBarAnimation
            })
        
        // preferredStatusBarStyle
        _ = NothingToSeeHere.overrideImplementation(for: UIViewController.self, targetSelector: #selector(getter: UIViewController.preferredStatusBarStyle), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject) in
                if let block = selfObject.xwui_preferredStatusBarStyleBlock {
                    return block()
                }
            
                
                // 调用原有实现
                typealias Imp  = @convention(c) (UIViewController?, Selector)->UIStatusBarStyle
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                return oldImpBlock(selfObject, originCMD)
            } as @convention(block) (UIViewController)->UIStatusBarStyle
        })
        
    }()
    
    
    
    @objc private func vcSwizzleViewDidLoadMethod() {
        self.vcSwizzleViewDidLoadMethod()
        
        self.xwui_visibleState = .viewDidLoad
    }
    
    private static let vcSwizzleViewDidLoad: () = {
        let originalSelector = #selector(UIViewController.viewDidLoad)
        let swizzledSelector = #selector(UIViewController.vcSwizzleViewDidLoadMethod)
        NothingToSeeHere.swizzleMethod(for: UIViewController.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }()
    
    
    
    
    /**
     *  判断当前类是否有重写某个指定的 UIViewController 的方法
     *  @param selector 要判断的方法
     *  @return YES 表示当前类重写了指定的方法，NO 表示没有重写，使用的是 UIViewController 默认的实现
     */
    func xwui_hasOverrideUIKitMethod(_ selector: Selector)-> Bool {
        // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
        var viewControllerSuperclasses: [AnyClass] = [
            UIImagePickerController.self,
            UINavigationController.self,
            UITableViewController.self,
            UICollectionViewController.self,
            UITabBarController.self,
            UISplitViewController.self,
            UIPageViewController.self,
            UIViewController.self
        ]
        
        if let UIAlertController = NSClassFromString("UIAlertController") {
            viewControllerSuperclasses.append(UIAlertController)
        }
        
        if let UISearchController = NSClassFromString("UISearchController") {
            viewControllerSuperclasses.append(UISearchController)
        }
        
        for vcClass in viewControllerSuperclasses {
            if NothingToSeeHere.hasOverrideSuperclassMethod(aClass: vcClass, originalSelector: selector) {
                return true
            }
        }
        return false
    }
    
    /// 可用于对  View 执行一些操作， 如果此时处于转场过渡中，这些操作会跟随转场进度以动画的形式展示过程
    /// @param animation 要执行的操作
    /// @param completion 转场完成或取消后的回调
    /// @note 如果处于非转场过程中，也会执行 animation ，随后执行 completion，业务无需关心是否处于转场过程中。
    func xwui_animateAlongsideTransition(_ animation: ((UIViewControllerTransitionCoordinatorContext?) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext?) -> Void)?) {
        if let transitionCoordinator = self.transitionCoordinator {
            let animationQueuedToRun = transitionCoordinator.animate(alongsideTransition: animation, completion: completion)
            // 某些情况下传给 animateAlongsideTransition 的 animation 不会被执行，这时候要自己手动调用一下
            // 但即便如此，completion 也会在动画结束后才被调用，因此这样写不会导致 completion 比 animation block 先调用
            // 某些情况包含：从 B 手势返回 A 的过程中，取消手势，animation 不会被调用
            if !animationQueuedToRun {
                animation?(nil)
            }
        }else{
            animation?(nil)
            completion?(nil)
        }
    }
    
    
    /**
     * 获取当前应用里最顶层的可见viewController
     * @warning 注意返回值可能为nil，要做好保护
     */
    static func visibleViewController()-> UIViewController? {
        let rootViewController = UIApplication.shared.delegate?.window??.rootViewController
        let visibleViewController = rootViewController?.xwui_visibleViewControllerIfExist
        return visibleViewController
    }
}


