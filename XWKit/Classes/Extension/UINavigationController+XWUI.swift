//
//  UINavigationController+XW.swift
//  XWKit
//
//  Created by Jay on 2024/5/17.
//

import Foundation
import UIKit

public enum XWUINavigationAction: Int {
    // 初始、各种动作的 completed 之后都会立即转入 unknown 状态，此时的 appearing、disappearingViewController 均为 nil
    case unknow
    // push 方法被触发，但尚未进行真正的 push 动作
    case willPush
    // 系统的 push 已经执行完，viewControllers 已被刷新
    case didPush
    // push 动画结束（如果没有动画，则在 did push 后立即进入 completed）
    case pushCompleted
    
    // pop 方法被触发，但尚未进行真正的 pop 动作
    case willPop
    // 系统的 pop 已经执行完，viewControllers 已被刷新（注意可能有 pop 失败的情况）
    case didPop
    // pop 动画结束（如果没有动画，则在 did pop 后立即进入 completed）
    case popCompleted
    
    // setViewControllers 方法被触发，但尚未进行真正的 set 动作
    case willSet
    // 系统的 setViewControllers 已经执行完，viewControllers 已被刷新
    case didSet
    // setViewControllers 动画结束（如果没有动画，则在 did set 后立即进入 completed）
    case setCompleted
}

public typealias XWUINavigationActionDidChangeClosure = (_ action: XWUINavigationAction, _ animated: Bool, _ weakNavigationController: UINavigationController?, _ appearingViewController: UIViewController?, _ disappearingViewControllers: [UIViewController]?)->Void


public extension UINavigationController {
#if os(Linux)
#else
    fileprivate enum UINavigationControllerKeys: String {
        case navigationAction = "XWUI.KeyForXWUINavigationAction"
        case interactivePopGestureRecognizerDelegate = "XWUI.KeyForInteractivePopGestureRecognizerDelegate"
        case interactiveGestureDelegator = "XWUI.KeyForInteractiveGestureDelegator"
        case navigationActionDidChangeBlocks = "XWUI.KeyForNavigationActionDidChangeBlocks"
        case endedTransitionTopViewController = "XWUI.KeyForEndedTransitionTopViewController"
        case alwaysInvokeAppearanceMethods = "XWUI.KeyForAlwaysInvokeAppearanceMethods"
    }
#endif
    
    /// 系统的设定是当 UINavigationController 不可见时（例如上面盖着一个 present vc，或者切到别的 tab），push/pop 操作均不会调用 vc 的生命周期方法（viewDidLoad 也是在 nav 恢复可视时才触发），所以提供这个属性用于当你希望这种情况下依然调用生命周期方法时，你可以打开它。默认为 NO。
    /// @warning 由于强制在 push/pop 时触发生命周期方法，所以会导致 vc 的 viewDidLoad 等方法比系统默认的更早调用，知悉即可。
    var xwui_alwaysInvokeAppearanceMethods: Bool {
        get {
            return getAssociatedValue<Bool>(key: UINavigationControllerKeys.alwaysInvokeAppearanceMethods.rawValue, object: self as AnyObject) ?? false
        }
        set {
            set(associatedValue: newValue, key: UINavigationControllerKeys.alwaysInvokeAppearanceMethods.rawValue, object: self as AnyObject)
        }
    }
    
    /// 是否在 push 的过程中
    var xwui_isPushing: Bool {
        guard let navigationAction = xwui_navigationAction else { return false }
        if navigationAction == .didPush || navigationAction == .pushCompleted { return true }
        return false
    }
    
    /// 是否在 pop 的过程中，包括手势、以及代码触发的 pop
    var xwui_isPopping: Bool {
        guard let navigationAction = xwui_navigationAction else { return false }
        if navigationAction == .didPop || navigationAction == .popCompleted { return true }
        return false
    }
    
    
    /// 获取顶部的 ViewController，相比于系统的方法，这个方法能获取到 pop 的转场过程中顶部还没有完全消失的 ViewController （请注意：这种情况下，获取到的 topViewController 已经不在栈内）
    var xwui_topViewController: UIViewController? {
        if xwui_isPushing {
            return topViewController
        }
        
        return xwui_endedTransitionTopViewController ?? topViewController
    }
    
    var xwui_rootViewController: UIViewController? {
        return self.viewControllers.first
    }
    
    
    
    /// XWUI 会修改 UINavigationController.interactivePopGestureRecognizer.delegate 的值，因此提供一个属性用于获取系统原始的值
    private(set) var xwui_interactivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate? {
        get {
            return getAssociatedValue<UIGestureRecognizerDelegate>(key: UINavigationControllerKeys.interactivePopGestureRecognizerDelegate.rawValue, object: self as AnyObject)
        }
        set {
            set<UIGestureRecognizerDelegate>(weakAssociatedValue: newValue, key: UINavigationControllerKeys.interactivePopGestureRecognizerDelegate.rawValue, object: self as AnyObject)
        }
    }
    
    /// XWUI 自定义接管系统手势返回处理
    private var xwui_interactiveGestureDelegator: _XWUINavigationInteractiveGestureDelegator? {
        get {
            return getAssociatedValue<_XWUINavigationInteractiveGestureDelegator>(key: UINavigationControllerKeys.interactiveGestureDelegator.rawValue, object: self as AnyObject)
        }
        set {
            set(associatedValue: newValue, key: UINavigationControllerKeys.interactiveGestureDelegator.rawValue, object: self as AnyObject)
        }
    }
    
    private(set) var xwuinc_navigationActionDidChangeBlocks: [XWUINavigationActionDidChangeClosure]? {
        get {
            return getAssociatedValue<[XWUINavigationActionDidChangeClosure]>(key: UINavigationControllerKeys.navigationActionDidChangeBlocks.rawValue, object: self as AnyObject)
        }
        set {
            set(associatedValue: newValue, key: UINavigationControllerKeys.navigationActionDidChangeBlocks.rawValue, object: self as AnyObject)
        }
    }
    
    private(set) var xwui_navigationAction: XWUINavigationAction? {
        get {
            return getAssociatedValue<XWUINavigationAction>(key: UINavigationControllerKeys.navigationAction.rawValue, object: self as AnyObject)
        }
        set {
            set(associatedValue: newValue, key: UINavigationControllerKeys.navigationAction.rawValue, object: self as AnyObject)
        }
    }
    
    private var xwui_endedTransitionTopViewController: UIViewController? {
        get {
            return getAssociatedValue<UIViewController>(key: UINavigationControllerKeys.endedTransitionTopViewController.rawValue, object: self as AnyObject)
        }
        set {
            set<UIViewController>(weakAssociatedValue: newValue, key: UINavigationControllerKeys.endedTransitionTopViewController.rawValue, object: self as AnyObject)
        }
    }
    
    
    
    
    
    @objc func didInitialize() { }
    
    /**
     添加一个 block 用于监听当前 UINavigationController 的 push/pop/setViewControllers 操作，在即将进行、已经进行、动画已完结等各种状态均会回调。
     block 参数里的 appearingViewController 表示即将显示的界面。
     disappearingViewControllers 表示即将消失的界面，数组形式是因为可能一次性 pop 掉多个（例如 popToRootViewController、setViewControllers），此时只有 disappearingViewControllers.lastObject 可以看到 pop 动画。由于 pop 可能失败，所以 will 动作里的 disappearingViewControllers 最终不一定真的会被移除。
     weakNavigationController 是便于你引用 self 而避免循环引用（因为这个方法会令 self retain 你传进来的 block，而 block 内部如果直接用 self，就会 retain self，产生循环引用，所以这里给一个参数规避这个问题）。
     @note 无法添加一个只监听某个 QMUINavigationAction 的 block，每一个添加的 block 在任何一个 action 变化时都会被调用，需要 block 内部自己区分当前的 action。
     */
    func xwui_addNavigationActionDidChange(_ block: @escaping XWUINavigationActionDidChangeClosure) {
        if xwuinc_navigationActionDidChangeBlocks == nil {
            xwuinc_navigationActionDidChangeBlocks = []
        }
        xwuinc_navigationActionDidChangeBlocks?.append(block)
    }
    
    
    
    internal static let navigationControllerSwizzle: () = {
        // MARK: - init(nibName:bundle:)
        _ = NothingToSeeHere.overrideImplementation(for: UINavigationController.self, targetSelector:  #selector(UINavigationController.init(nibName:bundle:)), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, firstArgv, secondArgv) -> UINavigationController in
                // 调用原有实现
                typealias Imp  = @convention(c) (UINavigationController?, Selector, String?, Bundle?)->UINavigationController
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                let result = oldImpBlock(selfObject, originCMD, firstArgv, secondArgv)
                
                selfObject.didInitialize()
                return result
            } as @convention(block) (UINavigationController, String?, Bundle?)->UINavigationController
        })
        
        // MARK: - init(coder:)
        _ = NothingToSeeHere.overrideImplementation(for: UINavigationController.self, targetSelector: #selector(UINavigationController.init(coder:)), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject,  firstArgv) -> UINavigationController in
                // 调用原有实现
                typealias Imp  = @convention(c) (UINavigationController?, Selector, NSCoder)->UINavigationController
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                let result = oldImpBlock(selfObject, originCMD, firstArgv)
                
                selfObject.didInitialize()
                return result
            } as @convention(block) (UINavigationController, NSCoder)->UINavigationController
        })
       
        // MARK: - init(navigationBarClass:toolbarClass:)
        _ = NothingToSeeHere.overrideImplementation(for: UINavigationController.self, targetSelector:  #selector(UINavigationController.init(navigationBarClass:toolbarClass:)), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, firstArgv, secondArgv) -> UINavigationController in
                // 调用原有实现
                typealias Imp  = @convention(c) (UINavigationController?, Selector, AnyClass, AnyClass)->UINavigationController
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                let result = oldImpBlock(selfObject, originCMD, firstArgv, secondArgv)
                
                selfObject.didInitialize()
                return result
            } as @convention(block) (UINavigationController, AnyClass, AnyClass)->UINavigationController
        })
        
        // MARK: - init(rootViewController:)
        _ = NothingToSeeHere.overrideImplementation(for: UINavigationController.self, targetSelector: #selector(UINavigationController.init(rootViewController:)), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject,  firstArgv) -> UINavigationController in
                // 调用原有实现
                typealias Imp  = @convention(c) (UINavigationController?, Selector, UIViewController)->UINavigationController
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                let result = oldImpBlock(selfObject, originCMD, firstArgv)
                
                selfObject.didInitialize()
                return result
            } as @convention(block) (UINavigationController, UIViewController)->UINavigationController
        })
        
        // MARK: - viewDidLoad
        let viewDidLoad = NothingToSeeHere.overrideImplementation(for: UINavigationController.self, targetSelector: #selector(UINavigationController.viewDidLoad), implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject) in
                // 调用原有实现
                typealias Imp  = @convention(c) (UINavigationController?, Selector)->Void
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                oldImpBlock(selfObject, originCMD)
                
                selfObject.xwui_interactivePopGestureRecognizerDelegate = selfObject.interactivePopGestureRecognizer?.delegate
                selfObject.xwui_interactiveGestureDelegator = _XWUINavigationInteractiveGestureDelegator(parentViewController: selfObject)
                selfObject.interactivePopGestureRecognizer?.delegate = selfObject.xwui_interactiveGestureDelegator
            } as @convention(block) (UINavigationController)->Void
        })
        if !viewDidLoad {
            UINavigationController.navSwizzleViewDidLoad
        }
        
        // MARK: - 拦截系统默认返回按钮事件
        if let navigationBarContentView = NSClassFromString("_UINavigationBarContentView") {
            _ = NothingToSeeHere.overrideImplementation(for: navigationBarContentView, 
                                                        targetSelector: NSSelectorFromString("__backButtonAction:"), 
                                                        implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
                return { (selfObject,  firstArgv) in
                    // 根据相应界面判断是否继续返回
                    if let bar = selfObject.superview as? UINavigationBar {
                        if let navController = bar.delegate as? UINavigationController {
                            let canPopViewController = navController.canPopViewController(viewController: navController.topViewController, byPopGesture: false)
                            if !canPopViewController { return }
                        }
                    }
                    
                    // 调用原有实现
                    typealias Imp  = @convention(c) (UIView?, Selector, Any)->Void
                    let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                    oldImpBlock(selfObject, originCMD, firstArgv)
                } as @convention(block) (UIView, Any)->Void
            })
        }
        
        // MARK: - navigationTransitionView:didEndTransition:fromView:toView:
        _ = NothingToSeeHere.overrideImplementation(for: UINavigationController.self,
                                                    targetSelector: NSSelectorFromString("navigationTransitionView:didEndTransition:fromView:toView:"),
                                                    implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, transitionView, transition, fromView, toView) in
                // 调用原有实现
                typealias Imp  = @convention(c) (UINavigationController, Selector, UIView, Int, UIView, UIView)->Void
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                oldImpBlock(selfObject, originCMD, transitionView, transition, fromView, toView)
                
                selfObject.xwui_endedTransitionTopViewController = selfObject.topViewController
                
            } as @convention(block) (UINavigationController, UIView, Int, UIView, UIView)->Void
        })
        
        // MARK: - pushViewController:animated:
        _ = NothingToSeeHere.overrideImplementation(for: UINavigationController.self,
                                                    targetSelector: #selector(UINavigationController.pushViewController(_:animated:)),
                                                    implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, viewController, animated) in
                var shouldInvokeAppearanceMethod = false
                
                if selfObject.isViewLoaded, selfObject.view.window == nil {
                    debugPrint("push 的时候 navigationController 不可见（例如上面盖着一个 present vc，或者切到别的 tab，可能导致 vc 的生命周期方法或者 UINavigationControllerDelegate 不会被调用")
                    if selfObject.xwui_alwaysInvokeAppearanceMethods {
                        shouldInvokeAppearanceMethod = true
                    }
                }
                
                // "不允许重复 push 相同的 viewController 实例，会产生 crash"
                if selfObject.viewControllers.contains(viewController) { return  }
                
                // 调用原有实现
                let callSuperBlock = {
                    typealias Imp  = @convention(c) (UINavigationController, Selector, UIViewController, Bool)->Void
                    let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                    oldImpBlock(selfObject, originCMD, viewController, animated)
                }
                
                let willPushActually: Bool = (viewController.isKind(of: UITabBarController.self)) == false
                
                if !willPushActually {
                    callSuperBlock()
                    return
                }
                
                let appearingViewController = viewController
                let disappearingViewControllers: [UIViewController]? = selfObject.topViewController != nil ? [selfObject.topViewController!] : nil
                selfObject.setXwui_navigationAction(action: .willPush, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                
                if shouldInvokeAppearanceMethod {
                    disappearingViewControllers?.last?.beginAppearanceTransition(false, animated: animated)
                    appearingViewController.beginAppearanceTransition(true, animated: animated)
                }
                
                callSuperBlock()
                
                
                selfObject.setXwui_navigationAction(action: .didPush, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                
                selfObject.xwui_animateAlongsideTransition(nil) { context in
                    selfObject.setXwui_navigationAction(action: .pushCompleted, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                    
                    selfObject.setXwui_navigationAction(action: .unknow, animated: animated, appearingViewController: nil, disappearingViewControllers: nil)
                    
                    if shouldInvokeAppearanceMethod {
                        disappearingViewControllers?.last?.endAppearanceTransition()
                        appearingViewController.endAppearanceTransition()
                    }
                }
                
            } as @convention(block) (UINavigationController, UIViewController, Bool)->Void
        })
        
        // MARK: - popViewControllerAnimated:
        _ = NothingToSeeHere.overrideImplementation(for: UINavigationController.self,
                                                    targetSelector: #selector(UINavigationController.popViewController(animated:)),
                                                    implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, animated) in
                // 调用原有实现
                let callSuperBlock = { () ->  UIViewController? in
                    typealias Imp  = @convention(c) (UINavigationController, Selector, Bool)->UIViewController?
                    let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                    let result = oldImpBlock(selfObject, originCMD, animated)
                    return result
                }
                
                let action = selfObject.xwui_navigationAction
                if action != .unknow {
                    debugPrint("popViewController 时上一次的转场尚未完成，系统会忽略本次 pop，等上一次转场完成后再重新执行 pop")
                }
                // 系统文档里说 rootViewController 是不能被 pop 的，当只剩下 rootViewController 时当前方法什么事都不会做
                let willPopActually = selfObject.viewControllers.count > 1 && action == .unknow
                
                if willPopActually == false {
                    return callSuperBlock()
                }
                
                var shouldInvokeAppearanceMethod = false
                if selfObject.isViewLoaded, selfObject.view.window == nil {
                    debugPrint("pop 的时候 navigationController 不可见（例如上面盖着一个 present vc，或者切到别的 tab，可能导致 vc 的生命周期方法或者 UINavigationControllerDelegate 不会被调用")
                    if selfObject.xwui_alwaysInvokeAppearanceMethods {
                        shouldInvokeAppearanceMethod = true
                    }
                }
                
                let appearingViewController = selfObject.viewControllers[selfObject.viewControllers.count - 2]
                var disappearingViewControllers: [UIViewController]? = selfObject.viewControllers.last != nil ? [selfObject.viewControllers.last!] : nil
                
                selfObject.setXwui_navigationAction(action: .willPop, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                
                if shouldInvokeAppearanceMethod {
                    disappearingViewControllers?.last?.beginAppearanceTransition(false, animated: animated)
                    appearingViewController.beginAppearanceTransition(true, animated: animated)
                }
                let result = callSuperBlock()
                
                // UINavigationController 不可见时 return 值可能为 nil
                disappearingViewControllers = result != nil ? [result!] : disappearingViewControllers
                
                selfObject.setXwui_navigationAction(action: .didPop, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                
                let transitionCompletion = {
                    selfObject.setXwui_navigationAction(action: .popCompleted, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                    selfObject.setXwui_navigationAction(action: .unknow, animated: animated, appearingViewController: nil, disappearingViewControllers: nil)
                    
                    if shouldInvokeAppearanceMethod {
                        disappearingViewControllers?.last?.endAppearanceTransition()
                        appearingViewController.endAppearanceTransition()
                    }
                }
                
                if result == nil {
                    // 如果系统的 pop 没有成功，实际上提交给 animateAlongsideTransition:completion: 的 completion 并不会被执行，所以这里改为手动调用
                    if (transitionCompletion != nil) {
                        transitionCompletion()
                    }
                } else {
                    selfObject.xwui_animateAlongsideTransition(nil) { context in
                        if (transitionCompletion != nil) {
                            transitionCompletion()
                        }
                    }
                }
                
                return result
            } as @convention(block) (UINavigationController, Bool)->UIViewController?
        })
        
        // MARK: - popToViewController:animated:
        _ = NothingToSeeHere.overrideImplementation(for: UINavigationController.self,
                                                    targetSelector: #selector(UINavigationController.popToViewController(_:animated:)),
                                                    implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, viewController, animated) in
                // 调用原有实现
                let callSuperBlock = {
                    typealias Imp  = @convention(c) (UINavigationController, Selector, UIViewController, Bool)->[UIViewController]?
                    let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                    let result = oldImpBlock(selfObject, originCMD, viewController, animated)
                    return result
                }
                
                let action = selfObject.xwui_navigationAction
                if action != .unknow {
                    debugPrint("popViewController 时上一次的转场尚未完成，系统会忽略本次 pop，等上一次转场完成后再重新执行 pop")
                }
                // 系统文档里说 rootViewController 是不能被 pop 的，当只剩下 rootViewController 时当前方法什么事都不会做
                let willPopActually = selfObject.viewControllers.count > 1 &&
                    selfObject.viewControllers.contains(viewController) &&
                selfObject.topViewController != viewController &&
                action == .unknow
                
                if willPopActually == false {
                    return callSuperBlock()
                }
                
                var appearingViewController = viewController
                var disappearingViewControllers: [UIViewController]? = nil
                if let index = selfObject.viewControllers.firstIndex(of: appearingViewController) {
                    let st = index + 1
                    var vcs: [UIViewController] = []
                    for (i, vc) in selfObject.viewControllers.enumerated() {
                        if i > index {
                            vcs.append(vc)
                        }
                    }
                    disappearingViewControllers = vcs
                }
                selfObject.setXwui_navigationAction(action: .willPop, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                
                let result = callSuperBlock()
                if let result = result {
                    disappearingViewControllers = result
                }
                
                selfObject.setXwui_navigationAction(action: .didPop, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                selfObject.setXwui_navigationAction(action: .popCompleted, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                selfObject.setXwui_navigationAction(action: .unknow, animated: animated, appearingViewController: nil, disappearingViewControllers: nil)
                
                return result
            } as @convention(block) (UINavigationController, UIViewController, Bool)->[UIViewController]?
        })
        
        // MARK: - popToRootViewControllerAnimated:
        _ = NothingToSeeHere.overrideImplementation(for: UINavigationController.self,
                                                    targetSelector: #selector(UINavigationController.popToRootViewController(animated:)),
                                                    implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, animated) -> [UIViewController]? in
                
                // 调用原有实现
                let callSuperBlock = {
                    typealias Imp  = @convention(c) (UINavigationController, Selector, Bool)->[UIViewController]?
                    let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                    let result = oldImpBlock(selfObject, originCMD, animated)
                    return result
                }
                
                let action = selfObject.xwui_navigationAction
                if action != .unknow {
                    debugPrint("popToRootViewController 时上一次的转场尚未完成，系统会忽略本次 pop，等上一次转场完成后再重新执行 pop, viewControllers = \(selfObject.viewControllers)")
                }
                
                let willPopActually = selfObject.viewControllers.count > 1 && action == .unknow
                if !willPopActually {
                    return callSuperBlock()
                }
                
                let appearingViewController = selfObject.xwui_rootViewController
                var disappearingViewControllers = selfObject.viewControllers.filter({ $0 != appearingViewController })
                
                selfObject.setXwui_navigationAction(action: .willPop, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                let result = callSuperBlock()
                
                if let result = result {
                    disappearingViewControllers = result
                }
                
                selfObject.setXwui_navigationAction(action: .didPop, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                
                selfObject.xwui_animateAlongsideTransition(nil) { context in
                    selfObject.setXwui_navigationAction(action: .popCompleted, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                    
                    selfObject.setXwui_navigationAction(action: .unknow, animated: animated, appearingViewController: nil, disappearingViewControllers: nil)
                }
                
                return result
            } as @convention(block) (UINavigationController, Bool)->[UIViewController]?
        })
        
        // MARK: - setViewControllers:animated:
        _ = NothingToSeeHere.overrideImplementation(for: UINavigationController.self,
                                                    targetSelector: #selector(UINavigationController.setViewControllers(_:animated:)),
                                                    implementationBlock: { (originClass, originCMD, originalIMPProvider) -> Any in
            return { (selfObject, viewControllers, animated) in
                var viewControllers = viewControllers
                if viewControllers.count != NSSet(array: viewControllers).count {
                    viewControllers = NSOrderedSet.init(array: viewControllers).array as? [UIViewController] ?? []
                    if viewControllers.count <= 0 { return }
                }
                // setViewControllers 执行前后 topViewController 没有变化，则赋值为 nil，表示没有任何界面有“重新显示”，这个 nil 的值也用于在 XWUINavigationController 里实现 viewControllerKeepingAppearWhenSetViewControllersWithAnimated:
                let appearingViewController = selfObject.topViewController != viewControllers.last ? viewControllers.last : nil
                var disappearingViewControllers: [UIViewController]? = selfObject.viewControllers
                disappearingViewControllers = disappearingViewControllers?.filter({ !viewControllers.contains($0) })
                disappearingViewControllers = (disappearingViewControllers?.count ?? 0) > 0 ? disappearingViewControllers : nil
                
                selfObject.setXwui_navigationAction(action: .willSet, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                
                typealias Imp  = @convention(c) (UINavigationController, Selector, [UIViewController], Bool)->Void
                let oldImpBlock = unsafeBitCast(originalIMPProvider(), to: Imp.self)
                oldImpBlock(selfObject, originCMD, viewControllers, animated)
                
                
                selfObject.setXwui_navigationAction(action: .didSet, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                
                selfObject.xwui_animateAlongsideTransition(nil) { context in
                    selfObject.setXwui_navigationAction(action: .setCompleted, animated: animated, appearingViewController: appearingViewController, disappearingViewControllers: disappearingViewControllers)
                    
                    selfObject.setXwui_navigationAction(action: .unknow, animated: animated, appearingViewController: nil, disappearingViewControllers: nil)
                }
                
            } as @convention(block) (UINavigationController, [UIViewController], Bool)->Void
        })
    }()
    
    @objc private func navSwizzleViewDidLoadMethod() {
        self.navSwizzleViewDidLoadMethod()
        
        self.xwui_interactivePopGestureRecognizerDelegate = self.interactivePopGestureRecognizer?.delegate
        self.xwui_interactiveGestureDelegator = _XWUINavigationInteractiveGestureDelegator(parentViewController: self)
        self.interactivePopGestureRecognizer?.delegate = self.xwui_interactiveGestureDelegator
    }
    
    private static let navSwizzleViewDidLoad: () = {
        let originalSelector = #selector(UINavigationController.viewDidLoad)
        let swizzledSelector = #selector(UINavigationController.navSwizzleViewDidLoadMethod)
        NothingToSeeHere.swizzleMethod(for: UINavigationController.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }()
    
    
    
    /// 相应界面是否能返回
    fileprivate func canPopViewController(viewController: UIViewController?, byPopGesture: Bool) -> Bool {
        if let viewController = viewController as? UINavigationControllerBackButtonHandlerProtocol,
           viewController.responds(to: #selector(UINavigationControllerBackButtonHandlerProtocol.shouldPopViewControllerByBackButtonOrPopGesture(byPopGesture:))) {
            return viewController.shouldPopViewControllerByBackButtonOrPopGesture?(byPopGesture: byPopGesture) ?? true
        }
        return true
    }
    
    /// 是否强制添加侧滑返回手势
    fileprivate func shouldForceEnableInteractivePopGestureRecognizer() -> Bool {
        guard let topViewController = self.topViewController as? UINavigationControllerBackButtonHandlerProtocol else { return false }
        return self.viewControllers.count > 1 &&
        (self.interactivePopGestureRecognizer?.isEnabled ?? false) &&
        topViewController.responds(to: #selector(UINavigationControllerBackButtonHandlerProtocol.forceEnableInteractivePopGestureRecognizer)) &&
        (topViewController.forceEnableInteractivePopGestureRecognizer?() ?? false)
    }
    
    fileprivate func setXwui_navigationAction(action: XWUINavigationAction, animated: Bool, appearingViewController: UIViewController?, disappearingViewControllers: [UIViewController]?) {
        let valueChanged = self.xwui_navigationAction != action
        self.xwui_navigationAction = action
        if valueChanged, let navigationActionDidChangeBlocks = self.xwuinc_navigationActionDidChangeBlocks, navigationActionDidChangeBlocks.count > 0 {
            for item in navigationActionDidChangeBlocks {
                item(action, animated, self, appearingViewController, disappearingViewControllers)
            }
        }
    }
}


// MARK: -- _XWUINavigationInteractiveGestureDelegator
private class _XWUINavigationInteractiveGestureDelegator: NSObject, UIGestureRecognizerDelegate {
    private(set) weak var parentViewController: UINavigationController?
    
    init(parentViewController: UINavigationController? = nil) {
        self.parentViewController = parentViewController
        super.init()
    }
    
    
    // MARK: -- <UIGestureRecognizerDelegate>
    // iOS 13.4 开始会优先询问该方法，只有返回 YES 后才会继续后续的逻辑
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        if let parentViewController = parentViewController,
           gestureRecognizer == parentViewController.interactivePopGestureRecognizer {
            if parentViewController.viewControllers.count <= 1 {
                return false
            }
            if parentViewController.xwui_navigationAction == .unknow, parentViewController.shouldForceEnableInteractivePopGestureRecognizer() {
                return true
            }
        }
        return true
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == parentViewController?.interactivePopGestureRecognizer {
            let originGestureDelegate = parentViewController?.xwui_interactivePopGestureRecognizerDelegate
            if true {
                let originalValue = originGestureDelegate?.gestureRecognizer?(gestureRecognizer, shouldReceive: touch) ?? false
                
                if !originalValue, (parentViewController?.shouldForceEnableInteractivePopGestureRecognizer() ?? false ) {
                    return true
                }
                return originalValue
            }
        }
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == parentViewController?.interactivePopGestureRecognizer {
            let canPopViewController = parentViewController?.canPopViewController(viewController: parentViewController?.topViewController, byPopGesture: true) ?? false
            
            if canPopViewController {
                if parentViewController?.xwui_interactivePopGestureRecognizerDelegate?.responds(to: #selector(UIGestureRecognizerDelegate.gestureRecognizerShouldBegin(_:))) ?? false {
                    let result = parentViewController?.xwui_interactivePopGestureRecognizerDelegate?.gestureRecognizerShouldBegin?(gestureRecognizer) ?? false
                    return result
                }
                return false
            }
            return false
        }
        return true
    }
    
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == parentViewController?.interactivePopGestureRecognizer {
            if parentViewController?.xwui_interactivePopGestureRecognizerDelegate?.responds(to: #selector(UIGestureRecognizerDelegate.gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:))) ?? false{
                let result =  parentViewController?.xwui_interactivePopGestureRecognizerDelegate?.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) ?? false
                return result
            }
        }
        return false
    }
    
    // 是否要gestureRecognizer检测失败了，才去检测otherGestureRecognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == parentViewController?.interactivePopGestureRecognizer {
            // 如果只是实现了上面几个手势的delegate，那么返回的手势和当前界面上的scrollview或者其他存在的手势会冲突，所以如果判断是返回手势，则优先响应返回手势再响应其他手势。
            // 不知道为什么，系统竟然没有实现这个delegate，那么它是怎么处理返回手势和其他手势的优先级的
            return true
        }
        return false
    }
}






