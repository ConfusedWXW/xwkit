//
//  NavigationController.swift
//  XWKit
//
//  Created by Jay on 2024/3/2.
//

import UIKit
import Foundation


// MARK: -- 与 NavigationController push/pop 相关的一些方法
@objc public protocol XWUINavigationControllerTransitionDelegate: NSObjectProtocol {
    /**
     *  当前界面正处于手势返回的过程中，可自行通过 gestureRecognizer.state 来区分手势返回的各个阶段。手势返回有多个阶段（手势返回开始、拖拽过程中、松手并成功返回、松手但不切换界面），不同阶段的 viewController 的状态可能不一样。
     *  @param navigationController 当前正在手势返回的 QMUINavigationController，请勿通过 vc.navigationController 获取 UINavigationController 的引用，而应该用本参数。因为某些手势阶段，vc.navigationController 得到的是 nil。
     *  @param gestureRecognizer 手势对象
     *  @param isCancelled 表示当前手势返回是否取消，只有在松手后这个参数的值才有意义
     *  @param viewControllerWillDisappear 手势返回中顶部的那个 vc，松手时如果成功手势返回，则该参数表示被 pop 的界面，如果手势返回取消，则该参数表示背后的界面。
     *  @param viewControllerWillAppear 手势返回中背后的那个 vc，松手时如果成功手势返回，则该参数表示背后的界面，如果手势返回取消，则该参数表示当前顶部的界面。
     */
    @objc optional func navigationController(_ navigationController: NavigationController, gestureRecognizer: UIScreenEdgePanGestureRecognizer ,viewControllerWillDisappear: UIViewController, viewControllerWillAppear: UIViewController, isCancelled: Bool)
    
    
    /**
     *  在 self.navigationController 进行以下 4 个操作前，相应的 viewController 的 willPopInNavigationControllerWithAnimated: 方法会被调用：
     *  1. popViewControllerAnimated:
     *  2. popToViewController:animated:
     *  3. popToRootViewControllerAnimated:
     *  4. setViewControllers:animated:
     *
     *  此时 self 仍存在于 self.navigationController.viewControllers 堆栈内。
     *
     *  在 ARC 环境下，viewController 可能被放在 autorelease 池中，因此 viewController 被pop后不一定立即被销毁，所以一些对实时性要求很高的内存管理逻辑可以写在这里（而不是写在dealloc内）
     *
     *  @warning 不要尝试将 willPopInNavigationControllerWithAnimated: 视为点击返回按钮的回调，因为导致 viewController 被 pop 的情况不止点击返回按钮这一途径。系统的返回按钮是无法添加回调的，只能使用自定义的返回按钮。
     */
    @objc optional func willPopInNavigationController(_ animated: Bool)
    
    /**
     *  在 self.navigationController 进行以下 4 个操作后，相应的 viewController 的 didPopInNavigationControllerWithAnimated: 方法会被调用：
     *  1. popViewControllerAnimated:
     *  2. popToViewController:animated:
     *  3. popToRootViewControllerAnimated:
     *  4. setViewControllers:animated:
     *
     *  此时 self.navigationController 仍有值，但 self 已经不在 viewControllers 数组内。
     *
     *  @warning 这个方法被调用并不意味着 self 最终一定会被 pop 掉，例如手势返回被触发时就会调用这个方法，但如果中途取消手势，self 依然会回到 viewControllers 内。
     */
    @objc optional func didPopInNavigationController(_ animated: Bool)
    
    /**
     *  当通过 setViewControllers:animated: 来修改 viewController 的堆栈时，如果参数 viewControllers.lastObject 与当前的 self.viewControllers.lastObject 不相同，则意味着会产生界面的切换，这种情况系统会自动调用两个切换的界面的生命周期方法，但如果两者相同，则意味着并不会产生界面切换，此时之前就已经在显示的那个 viewController 的 viewWillAppear:、viewDidAppear: 并不会被调用，那如果用户确实需要在这个时候修改一些界面元素，则找不到一个时机。所以这个方法就是提供这样一个时机给用户修改界面元素。
     */
    @objc optional func viewControllerKeepingAppearWhenSetViewControllers(_ animated: Bool)
    
}

// MARK: -- 与 NavigationController 外观样式相关的方法
@objc public protocol XWUINavigationControllerAppearanceDelegate: NSObjectProtocol {
    /// 设置 titleView 的 tintColor
    @objc optional func titleViewTintColor() -> UIColor?
    
    /// 设置导航栏的背景图，默认为 NavBarBackgroundImage
    @objc optional func navigationBarBackgroundImage() -> UIImage?
    
    /// 设置导航栏底部的分隔线图片，默认为 NavBarShadowImage，必须在 navigationBar 设置了背景图后才有效（系统限制如此）
    @objc optional func navigationBarShadowImage() -> UIImage?
    
    /// 设置当前导航栏的 barTintColor，默认为 NavBarBarTintColor
    @objc optional func navigationBarBarTintColor() -> UIColor?
    
    /// 设置当前导航栏的 UIBarButtonItem 的 tintColor，默认为NavBarTintColor
    @objc optional func navigationBarTintColor() -> UIColor?
    
    /// 设置系统返回按钮title，如果返回nil则使用系统默认的返回按钮标题。当实现了这个方法时，会无视配置表 NeedsBackBarButtonItemTitle 的值
    @objc optional func backBarButtonItemTitleWithPreviousViewController(_ viewController: UIViewController) -> String?
    
}

// MARK: -- 与 NavigationController 控制 navigationBar 显隐/动画相关的方法
@objc public protocol XWUICustomNavigationBarTransitionDelegate: NSObjectProtocol {
    /// 设置每个界面导航栏的显示/隐藏，为了减少对项目的侵入性，默认不开启这个接口的功能，只有当 shouldCustomizeNavigationBarTransitionIfHideable 返回 YES 时才会开启此功能。如果需要全局开启，那么就在 Controller 基类里面返回 YES；如果是老项目并不想全局使用此功能，那么则可以在单独的界面里面开启。
    @objc optional func preferredNavigationBarHidden() -> Bool
    
    /**
     *  当切换界面时，如果不同界面导航栏的显隐状态不同，可以通过 shouldCustomizeNavigationBarTransitionIfHideable 设置是否需要接管导航栏的显示和隐藏。从而不需要在各自的界面的 viewWillAppear 和 viewWillDisappear 里面去管理导航栏的状态。
     *  @see UINavigationController+NavigationBarTransition.h
     *  @see preferredNavigationBarHidden
     */
    @objc optional func shouldCustomizeNavigationBarTransitionIfHideable() -> Bool
    
    /**
     *  设置导航栏转场的时候是否需要使用自定义的 push / pop transition 效果。<br/>
     *  如果前后两个界面 controller 返回的 key 不一致，那么则说明需要自定义。<br/>
     *  不实现这个方法，或者实现了但返回 nil，都视为希望使用默认样式。<br/>
     *  @see UINavigationController+NavigationBarTransition.h
     *  @see 配置表有开关 AutomaticCustomNavigationBarTransitionStyle 支持自动判断样式，无需实现这个方法
     */
    @objc optional func customNavigationBarTransitionKey() -> String?
    
    /**
     *  在实现了系统的自定义转场情况下，导航栏转场的时候是否需要使用 XWUI 自定义的 push / pop transition 效果，默认不实现的话则不会使用，只要前后其中一个 vc 实现并返回了 YES 则会使用。
     *  @see UINavigationController+NavigationBarTransition.h
     */
//    @objc optional func shouldCustomizeNavigationBarTransitionIfUsingCustomTransitionForOperation(_ operation: XWNavigationControllerOperation?, fromViewController: UIViewController, toViewController: UIViewController) -> Bool
    
    /**
     *  自定义navBar效果过程中UINavigationController的containerView的背景色
     *  @see UINavigationController+NavigationBarTransition.h
     */
    @objc optional func containerViewBackgroundColorWhenTransitioning() -> UIColor?
}

// MARK: XWUINavigationControllerDelegate
@objc protocol XWUINavigationControllerDelegate: UINavigationControllerDelegate, XWUINavigationControllerTransitionDelegate, XWUINavigationControllerAppearanceDelegate, XWUICustomNavigationBarTransitionDelegate { }

// MARK: -- 拦截系统默认返回按钮事件 或者手势返回的拦截事件
@objc public protocol UINavigationControllerBackButtonHandlerProtocol: NSObjectProtocol {
    /**
     * 点击系统返回按钮或者手势返回的时候是否要相应界面返回（手动调用代码pop排除）。支持参数判断是点击系统返回按钮还是通过手势触发
     * 一般使用的场景是：可以在这个返回里面做一些业务的判断，比如点击返回按钮的时候，如果输入框里面的文本没有满足条件的则可以弹 Alert 并且返回 NO 来阻止用户退出界面导致不合法的数据或者数据丢失。
     */
    @objc optional func shouldPopViewControllerByBackButtonOrPopGesture(byPopGesture: Bool) -> Bool
    
    
    /// 当自定义了`leftBarButtonItem`按钮之后，系统的手势返回就失效了。可以通过`forceEnableInteractivePopGestureRecognizer`来决定要不要把那个手势返回强制加回来。当 interactivePopGestureRecognizer.enabled = NO 或者当前`UINavigationController`堆栈的viewControllers小于2的时候此方法无效。
    @objc optional func forceEnableInteractivePopGestureRecognizer() -> Bool
}




@objc public enum XWNavigationControllerOperation: Int {
    case none = 0
    case push = 1
    case pop = 2
}





open class NavigationController: UINavigationController, UIGestureRecognizerDelegate {
    // MARK: - 状态栏
    open override var childForStatusBarStyle: UIViewController? {
        return childViewControllerForStatusBar { vc -> Bool in
            // TODO: vc.qmui_preferredStatusBarStyleBlock || [vc qmui_hasOverrideUIKitMethod:@selector(preferredStatusBarStyle)];
            return false
        }
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return childViewControllerForStatusBar { vc -> Bool in
            // TODO: vc.qmui_prefersStatusBarHiddenBlock || [vc qmui_hasOverrideUIKitMethod:@selector(prefersStatusBarHidden)];
            return false
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        // 按照系统的文档，当 -[UIViewController childViewControllerForStatusBarStyle] 返回值不为 nil 时，会询问返回的 vc 的 preferredStatusBarStyle，只有当返回 nil 时才会询问 self 的 preferredStatusBarStyle，但实测在 iOS 13 默认的半屏 present 或者 UISearchController 进入搜索状态时，即便在 childViewControllerForStatusBarStyle 里返回了正确的 vc，最终依然会来询问 -[self preferredStatusBarStyle]，导致样式错误，所以这里做个保护。
        let childViewController = self.childForStatusBarStyle
        if let childViewController = childViewController {
            return childViewController.preferredStatusBarStyle
        }
        
        // TODO: 配置文件的
        if false {
            return .default
        }
        return super.preferredStatusBarStyle
    }
    
    // MARK: - Home指示器
    open override var childForHomeIndicatorAutoHidden: UIViewController? {
        return topViewController
    }
    
    // MARK: - 屏幕旋转
    open override var shouldAutorotate: Bool {
        // 根据当前可见ViewController是否重新shouldAutorotate
        // TODO: [self.visibleViewController qmui_hasOverrideUIKitMethod:_cmd] ? [self.visibleViewController shouldAutorotate] : YES;
        return true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        var visibleViewController = visibleViewController
        if visibleViewController == nil || (visibleViewController?.isBeingDismissed ?? false) || (visibleViewController?.isKind(of: UIAlertController.self) ?? false) {
            visibleViewController = topViewController
        }
        // TODO: [visibleViewController qmui_hasOverrideUIKitMethod:_cmd] ? [visibleViewController supportedInterfaceOrientations] : SupportedOrientationMask;
        return super.supportedInterfaceOrientations
    }
    
    
    
    // MARK: 添加属性
    private var delegator: _XWUINavigationControllerDelegator?
    
    /// 记录当前是否正在 push/pop 界面的动画过程，如果动画尚未结束，不应该继续 push/pop 其他界面。
    /// 在 getter 方法里会根据配置表开关 PreventConcurrentNavigationControllerTransitions 的值来控制这个属性是否生效。
    private var _isViewControllerTransiting: Bool = false
    
    /// 即将要被pop的controller
    public weak var viewControllerPopping: UIViewController?
    
    
    
    
    // MARK: -- 生命周期函数 && 基类方法重写
    public override func didInitialize() {
        self.delegator = _XWUINavigationControllerDelegator()
        self.delegator?.navigationController = self
        self.delegate = self.delegator
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // 手势允许多次addTarget
        self.interactivePopGestureRecognizer?.addTarget(self, action: #selector(handleInteractivePopGestureRecognizer(_:)))
        
        makeUI()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        willShow(topViewController, animated: animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        willShow(topViewController, animated: animated)
    }
    
    deinit {
        self.delegate = nil
    }
    
    
    open func makeUI() {
        updateUI()
    }
    
    open func updateUI() { }
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        if viewControllers.count < 2 {
            // 只剩 1 个 viewController 或者不存在 viewController 时，调用 popViewControllerAnimated: 后不会有任何变化，所以不需要触发 willPop / didPop
            return super.popViewController(animated: animated)
        }
        var viewController = self.topViewController
        self.viewControllerPopping = viewController
        
        if animated {
            // TODO: 还没处理
//            self.viewControllerPopping.
            _isViewControllerTransiting = true
        }
        
        if let viewController = viewController as? XWUINavigationControllerTransitionDelegate, viewController.responds(to: #selector(XWUINavigationControllerTransitionDelegate.willPopInNavigationController(_:))) {
            viewController.willPopInNavigationController?(animated)
        }
        
        viewController = super.popViewController(animated: animated)
        if let viewController = viewController as? XWUINavigationControllerTransitionDelegate, viewController.responds(to: #selector(XWUINavigationControllerTransitionDelegate.didPopInNavigationController(_:))) {
            viewController.didPopInNavigationController?(animated)
        }
        
        return viewController
    }
    
    
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if viewController == topViewController {
            // 当要被 pop 到的 viewController 已经处于最顶层时，调用 super 默认也是什么都不做，所以直接 return 掉
            return super.popToViewController(viewController, animated: animated)
        }
        
        self.viewControllerPopping = topViewController
        
        if animated {
            // TODO: 还没处理
//            self.viewControllerPopping.
            _isViewControllerTransiting = true
        }
        // will pop
        var i = viewControllers.count - 1
        while i > 0 {
            let viewControllerPopping = viewControllers[i]
            if viewControllerPopping == viewController {
                break
            }
            if let viewControllerPopping = viewControllerPopping as? XWUINavigationControllerTransitionDelegate, viewControllerPopping.responds(to: #selector(XWUINavigationControllerTransitionDelegate.willPopInNavigationController(_:))) {
                // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                let animatedArgument = i == viewControllers.count ? animated : false
                viewControllerPopping.willPopInNavigationController?(animatedArgument)
            }
            i -= 1
        }
        
        let poppedViewControllers = super.popToViewController(viewController, animated: animated)
        // did pop
        i = viewControllers.count - 1
        while i > 0 {
            let viewControllerPopping = viewControllers[i]
            if viewControllerPopping == viewController {
                break
            }
            if let viewControllerPopping = viewControllerPopping as? XWUINavigationControllerTransitionDelegate, viewControllerPopping.responds(to: #selector(XWUINavigationControllerTransitionDelegate.didPopInNavigationController(_:))) {
                // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                let animatedArgument = i == viewControllers.count ? animated : false
                viewControllerPopping.didPopInNavigationController?(animatedArgument)
            }
            i -= 1
        }
        
        return poppedViewControllers
    }
    
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        // 在配合 tabBarItem 使用的情况下，快速重复点击相同 item 可能会重复调用 popToRootViewControllerAnimated:，而此时其实已经处于 rootViewController 了，就没必要继续走后续的流程，否则一些变量会得不到重置。
//        if topViewController == self.
        
        viewControllerPopping = topViewController
        if animated {
            // TODO: 还没处理
//            self.viewControllerPopping.
            _isViewControllerTransiting = true
        }
        
        // will pop
        var i = viewControllers.count - 1
        while i > 0 {
            let viewControllerPopping = viewControllers[i]
            if let viewControllerPopping = viewControllerPopping as? XWUINavigationControllerTransitionDelegate, viewControllerPopping.responds(to: #selector(XWUINavigationControllerTransitionDelegate.willPopInNavigationController(_:))) {
                // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                let animatedArgument = i == viewControllers.count ? animated : false
                viewControllerPopping.willPopInNavigationController?(animatedArgument)
            }
            i -= 1
        }
        
        let poppedViewControllers = super.popToRootViewController(animated: animated)
        // did pop
        i = viewControllers.count - 1
        while i > 0 {
            let viewControllerPopping = viewControllers[i]
            if let viewControllerPopping = viewControllerPopping as? XWUINavigationControllerTransitionDelegate, viewControllerPopping.responds(to: #selector(XWUINavigationControllerTransitionDelegate.didPopInNavigationController(_:))) {
                // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                let animatedArgument = i == viewControllers.count ? animated : false
                viewControllerPopping.didPopInNavigationController?(animatedArgument)
            }
            i -= 1
        }
        
        return poppedViewControllers
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        let topViewController = topViewController
        
        // will pop
        var viewControllersPopping = self.viewControllers.filter({ !viewControllers.contains($0) })
        viewControllersPopping.forEach { vc in
            if vc.responds(to: #selector(XWUINavigationControllerTransitionDelegate.willPopInNavigationController(_:))) {
                // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                let animatedArgument = vc == topViewController ? animated : false
                if let vc = vc as? XWUINavigationControllerTransitionDelegate {
                    vc.willPopInNavigationController?(animatedArgument)
                }
            }
        }
        
        // setViewControllers 不会触发 pushViewController，所以这里也要更新一下返回按钮的文字
        for (index, vc) in viewControllers.enumerated() {
            self.updateBackItemTitle(with: vc, nextViewController: ((index + 1) < viewControllers.count) ? viewControllers[index + 1] : nil)
        }
        
        super.setViewControllers(viewControllers, animated: animated)
        
        // did pop
        for (index, vc) in viewControllersPopping.enumerated() {
            if vc.responds(to: #selector(XWUINavigationControllerTransitionDelegate.didPopInNavigationController(_:))) {
                // 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
                let animatedArgument = vc == topViewController ? animated : false
                if let vc = vc as? XWUINavigationControllerTransitionDelegate {
                    vc.didPopInNavigationController?(animatedArgument)
                }
            }
        }
        
        // 操作前后如果 topViewController 没发生变化，则为它调用一个特殊的时机
        if topViewController == viewControllers.last {
            if let topViewController = topViewController,
                topViewController.responds(to: #selector(XWUINavigationControllerTransitionDelegate.viewControllerKeepingAppearWhenSetViewControllers(_:))) {
                if let vc = topViewController as? XWUINavigationControllerTransitionDelegate {
                    vc.viewControllerKeepingAppearWhenSetViewControllers?(animated)
                }
                
            }
        }
    }
    
    

   
    
    func viewControllerDidInvokeViewWillAppear(_ viewController: UIViewController) {
        // TODO: viewController.qmui_viewWillAppearNotifyDelegate = nil;
        if let viewControllerPopping = viewControllerPopping {
            self.delegator?.navigationController(self, willShow: viewControllerPopping, animated: true)
        }
        viewControllerPopping = nil
        _isViewControllerTransiting = false
    }
    
    // 接管系统手势返回的回调
    @objc private func handleInteractivePopGestureRecognizer(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let state = gestureRecognizer.state
        
        var viewControllerWillDisappear = self.transitionCoordinator?.viewController(forKey: UITransitionContextViewControllerKey.from)
        var viewControllerWillAppear = self.transitionCoordinator?.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        viewControllerWillDisappear?.poppingByInteractivePopGestureRecognizer = true
        viewControllerWillDisappear?.willAppearByInteractivePopGestureRecognizer = false
        
        viewControllerWillAppear?.poppingByInteractivePopGestureRecognizer = false
        viewControllerWillAppear?.willAppearByInteractivePopGestureRecognizer = true
        
        if state == .began {
            // UIGestureRecognizerStateBegan 对应 viewWillAppear:，只要在 viewWillAppear: 里的修改都是安全的，但只要过了 viewWillAppear:，后续的修改都是不安全的，所以这里用 dispatch 的方式将标志位的赋值放到 viewWillAppear: 的下一个 Runloop 里
            DispatchQueue.main.async {
                viewControllerWillDisappear?.navigationControllerPopGestureRecognizerChanging = true
                viewControllerWillAppear?.navigationControllerPopGestureRecognizerChanging = true
            }
        }else if state.rawValue > UIGestureRecognizer.State.changed.rawValue {
            viewControllerWillDisappear?.navigationControllerPopGestureRecognizerChanging = false
            viewControllerWillAppear?.navigationControllerPopGestureRecognizerChanging = false
        }
        
        if state == .ended{
            if let transitionCoordinator = transitionCoordinator,  transitionCoordinator.isCancelled {
                if let temp = viewControllerWillDisappear as? XWUINavigationControllerTransitionDelegate {
                    viewControllerWillDisappear = viewControllerWillAppear
                    viewControllerWillAppear = temp as? UIViewController
                }
            }
        }
        
        if let viewControllerWillAppear = viewControllerWillAppear,
            let viewControllerWillDisappear = viewControllerWillDisappear as? XWUINavigationControllerTransitionDelegate,
            viewControllerWillDisappear.responds(to: #selector(XWUINavigationControllerTransitionDelegate.navigationController(_:gestureRecognizer:viewControllerWillDisappear:viewControllerWillAppear:isCancelled:))) {
            viewControllerWillDisappear.navigationController?(self, gestureRecognizer: gestureRecognizer, viewControllerWillDisappear: viewControllerWillDisappear as! UIViewController, viewControllerWillAppear: viewControllerWillAppear, isCancelled: transitionCoordinator?.isCancelled ?? false)
        }
        
        if let viewControllerWillDisappear = viewControllerWillDisappear,
            let viewControllerWillAppear = viewControllerWillAppear as? XWUINavigationControllerTransitionDelegate,
           viewControllerWillAppear.responds(to: #selector(XWUINavigationControllerTransitionDelegate.navigationController(_:gestureRecognizer:viewControllerWillDisappear:viewControllerWillAppear:isCancelled:))) {
            viewControllerWillAppear.navigationController?(self, gestureRecognizer: gestureRecognizer, viewControllerWillDisappear: viewControllerWillDisappear, viewControllerWillAppear: viewControllerWillAppear as! UIViewController, isCancelled: transitionCoordinator?.isCancelled ?? false)
        }
    }
    
    // 返回按钮文字配置更新
    private func updateBackItemTitle(with currentViewController: UIViewController?, nextViewController: UIViewController?) {
        guard let currentViewController = currentViewController else { return }
        // 如果某个 viewController 显式声明了返回按钮的文字，则无视配置表 NeedsBackBarButtonItemTitle 的值
        if let vc = nextViewController as? XWUINavigationControllerAppearanceDelegate,
           vc.responds(to: #selector(XWUINavigationControllerAppearanceDelegate.backBarButtonItemTitleWithPreviousViewController(_:))) {
            if let title = vc.backBarButtonItemTitleWithPreviousViewController?(currentViewController) {
                currentViewController.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: title, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
            }else {
                currentViewController.navigationItem.backBarButtonItem =  nil
            }
            return
        }
        
        // TODO: 全局屏蔽返回按钮的文字
        if true {
            if #available(iOS 14.0, *) {
                // 用新 API 来屏蔽返回按钮的文字，才能保证 iOS 14 长按返回按钮时能正确出现 viewController title
                currentViewController.navigationItem.backButtonDisplayMode = .minimal
                return
            }
            
            // 业务自己设置的 backBarButtonItem 优先级高于配置表
            if currentViewController.navigationItem.backBarButtonItem == nil {
                currentViewController.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
            }
        }
    }
    
    private func isViewControllerTransiting() -> Bool {
        // TODO: 如果配置表里这个开关关闭，则为了使 isViewControllerTransiting 功能失效，强制返回 NO
        if false {
            return false
        }
        return _isViewControllerTransiting
    }
    
    
    // MARK: - StatusBar
    private func childViewControllerIfSearching(_ childViewController: UIViewController?, hasCustomizedStatusBarBlock: ((UIViewController?)->(Bool))) -> UIViewController? {
        let presentedViewController = childViewController?.presentedViewController
        // 3. 命中这个条件意味着 viewControllers 里某个 vc 被设置了 definesPresentationContext = YES 并 present 了一个 vc（最常见的是进入搜索状态的 UISearchController），此时对 self 而言是不存在 presentedViewController 的，所以在上面第1步里无法得到这个被 present 起来的 vc，也就无法将 statusBar 的控制权交给它，所以这里要特殊处理一下，保证状态栏正确交给 present 起来的 vc
        if let presentedViewController = presentedViewController, !presentedViewController.isBeingDismissed, presentedViewController != self.presentedViewController, hasCustomizedStatusBarBlock(presentedViewController) {
            return childViewControllerIfSearching(childViewController?.presentedViewController, hasCustomizedStatusBarBlock: hasCustomizedStatusBarBlock)
        }
        
        // 4. 普通 dismiss，或者 iOS 13 默认的半屏 present 手势拖拽下来过程中，或者 UISearchController 退出搜索状态时，都会触发 statusBar 样式刷新，此时的 childViewController 依然是被 dismiss 的那个 vc，但状态栏应该交给背后的界面去控制，所以这里做个保护。为什么需要递归再查一次，是因为 self.topViewController 也可能正在显示一个 present 起来的搜索界面。
        if childViewController?.isBeingDismissed ?? false {
            return childViewControllerIfSearching(topViewController, hasCustomizedStatusBarBlock: hasCustomizedStatusBarBlock)
        }
        
        return childViewController
    }
    
    // 参数 hasCustomizedStatusBarBlock 用于判断指定 vc 是否有自己控制状态栏 hidden/style 的实现。
    private func childViewControllerForStatusBar(_ hasCustomizedStatusBarBlock: ((UIViewController?)->(Bool))) -> UIViewController? {
        // 1. 有 modal present 则优先交给 modal present 的 vc 控制（例如进入搜索状态且没指定 definesPresentationContext 的 UISearchController）
        var childViewController = visibleViewController
        
        // 2. 如果 modal present 是一个 UINavigationController，则 self.visibleViewController 拿到的是该 UINavigationController.topViewController，而不是该 UINavigationController 本身，所以这里要特殊处理一下，才能让下文的 beingDismissed 判断生效
        if let navigationController = childViewController?.navigationController, presentedViewController == navigationController {
            childViewController = navigationController
        }
        
        childViewController = childViewControllerIfSearching(childViewController, hasCustomizedStatusBarBlock: hasCustomizedStatusBarBlock)
        
        // TODO: 标志当前项目是否正使用配置表功能
        if true {
            if hasCustomizedStatusBarBlock(childViewController) {
                return childViewController
            }
            return nil
        }
        return childViewController
    }
    
   
    
    fileprivate func shouldForceEnableInteractivePopGestureRecognizer() -> Bool {
        guard let viewController = self.topViewController as? UINavigationControllerBackButtonHandlerProtocol else { return false }
        guard viewControllers.count > 1, interactivePopGestureRecognizer?.isEnabled ?? false else { return false }
        guard viewController.responds(to: #selector(UINavigationControllerBackButtonHandlerProtocol.forceEnableInteractivePopGestureRecognizer)) else { return false }
        return viewController.forceEnableInteractivePopGestureRecognizer?() ?? false
    }
}

// MARK: - NavigationController 子类可以重写
extension NavigationController {
    // 子类可以重写
    @objc open func willShow(_ viewController: UIViewController?, animated: Bool) { }
    
    // 子类可以重写
    @objc open func didShow(_ viewController: UIViewController?, animated: Bool) {}
}



// MARK: -- _XWUINavigationControllerDelegator
private class _XWUINavigationControllerDelegator: NSObject, XWUINavigationControllerDelegate {
    weak var navigationController: NavigationController?
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let navigationController = navigationController as? NavigationController else { return }
        navigationController.willShow(viewController, animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let navigationController = navigationController as? NavigationController else { return }
        navigationController.didShow(viewController, animated: animated)
    }
}





/// ViewController 默认遵循协议
extension ViewController: UINavigationControllerBackButtonHandlerProtocol { }



public extension UIViewController {
#if os(Linux)
#else
    fileprivate enum UINavigationControllerKeys: String {
        case navigationControllerPopGestureRecognizerChanging = "XWUI.KeyForNavigationControllerPopGestureRecognizerChanging"
        case poppingByInteractivePopGestureRecognizer = "XWUI.KeyForPoppingByInteractivePopGestureRecognizer"
        case willAppearByInteractivePopGestureRecognizer = "XWUI.KeyForWillAppearByInteractivePopGestureRecognizer"
    }
#endif
    
    /// 判断当前 viewController 是否处于手势返回中，仅对当前手势返回涉及到的前后两个 viewController 有效
    var navigationControllerPoppingInteracted: Bool {
        get {
            return poppingByInteractivePopGestureRecognizer || willAppearByInteractivePopGestureRecognizer
        }
    }
    
    /// 基本与上一个属性 navigationControllerPoppingInteracted 相同，只不过 navigationControllerPoppingInteracted 是在 began 时就为 YES，而这个属性仅在 changed 时才为 YES。
    /// @note viewController 会在走完 viewWillAppear: 之后才将这个值置为 YES。
    var navigationControllerPopGestureRecognizerChanging: Bool {
        get {
            return getAssociatedValue<Bool>(key: UINavigationControllerKeys.navigationControllerPopGestureRecognizerChanging.rawValue, object: self as AnyObject) ?? false
        }
        set {
            set(associatedValue: newValue, key: UINavigationControllerKeys.navigationControllerPopGestureRecognizerChanging.rawValue, object: self as AnyObject)
        }
    }
    
    /// 当前 viewController 是否正在被手势返回 pop
    var poppingByInteractivePopGestureRecognizer: Bool {
        get {
            return getAssociatedValue<Bool>(key: UINavigationControllerKeys.poppingByInteractivePopGestureRecognizer.rawValue, object: self as AnyObject) ?? false
        }
        set {
            set(associatedValue: newValue, key: UINavigationControllerKeys.poppingByInteractivePopGestureRecognizer.rawValue, object: self as AnyObject)
        }
    }
    
    /// 当前 viewController 是否是手势返回中，背后的那个界面
    var willAppearByInteractivePopGestureRecognizer: Bool {
        get {
            return getAssociatedValue<Bool>(key: UINavigationControllerKeys.willAppearByInteractivePopGestureRecognizer.rawValue, object: self as AnyObject) ?? false
        }
        set {
            set(associatedValue: newValue, key: UINavigationControllerKeys.willAppearByInteractivePopGestureRecognizer.rawValue, object: self as AnyObject)
        }
    }
    
    /// 可用于对  View 执行一些操作， 如果此时处于转场过渡中，这些操作会跟随转场进度以动画的形式展示过程
    /// @param animation 要执行的操作
    /// @param completion 转场完成或取消后的回调
    /// @note 如果处于非转场过程中，也会执行 animation ，随后执行 completion，业务无需关心是否处于转场过程中。
    func animateAlongsideTransition(animation: ((_ context: UIViewControllerTransitionCoordinatorContext?) -> Void)?,
                                    completion: ((_ context: UIViewControllerTransitionCoordinatorContext?) -> Void)?) {
        guard let transitionCoordinator = self.transitionCoordinator else {
            animation?(nil)
            completion?(nil)
            return
        }
        let animationQueuedToRun = transitionCoordinator.animate(alongsideTransition: animation, completion: completion)
        // 某些情况下传给 animateAlongsideTransition 的 animation 不会被执行，这时候要自己手动调用一下
        // 但即便如此，completion 也会在动画结束后才被调用，因此这样写不会导致 completion 比 animation block 先调用
        // 某些情况包含：从 B 手势返回 A 的过程中，取消手势，animation 不会被调用
        if !animationQueuedToRun, animation != nil {
            animation?(nil)
        }
        
    }
    
}
