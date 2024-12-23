//
//  UIDevice+XW.swift
//  XWExtensionKit
//
//  Created by Jay on 2023/11/8.
//

import UIKit


public extension UIDevice {
    
    // 是否是平板
    static let isIPad: Bool = (UIDevice.current.userInterfaceIdiom == .pad)
    
    // 是否是手机
    static let isIPhone: Bool = (UIDevice.current.userInterfaceIdiom == .phone)
    
    // 是否是刘海屏
    static let isFringeScreen: Bool = safeAreaInsets.bottom > 0
    
    // 主window
    static var keyWindow: UIWindow? {
        if #available(iOS 13, *) {
            let sceneList = UIApplication.shared.connectedScenes
            let useableSceneList = sceneList.filter { ($0 is UIWindowScene) }.compactMap { $0 as? UIWindowScene }
            let keyWindow = useableSceneList.flatMap { $0.windows }.first { $0.isKeyWindow }
            return keyWindow
        }
        return UIApplication.shared.keyWindow
    }
    
    // 所有window
    static var windows: [UIWindow] {
        if #available(iOS 13, *) {
            let sceneList = UIApplication.shared.connectedScenes
            let useableSceneList = sceneList.filter { ($0 is UIWindowScene) }.compactMap { $0 as? UIWindowScene }
            let result = useableSceneList.flatMap { $0.windows }
            return result
        }
        return UIApplication.shared.windows
    }
    
    // 屏幕
    static var screen: UIScreen {
        guard #available(iOS 13, *) else { return UIScreen.main }
        return self.keyWindow?.windowScene?.screen ?? UIScreen.main
    }
    
    // 屏幕宽度
    static var screenWidth: CGFloat { return CGFloat(screen.bounds.size.width) }

    // 屏幕高度
    static var screenHeight: CGFloat { return CGFloat(screen.bounds.size.height)  }
    
    // 状态栏高度
    static var statusBarHeight: CGFloat {
        if #available(iOS 13, *) {
            return (self.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.maxY ?? 0)
        }
        return CGFloat(UIApplication.shared.statusBarFrame.maxY)
    }
    
    // 导航栏高度 + 状态栏高度
    static var navBarHeight: CGFloat { return statusBarHeight + navBarIntrinsicHeight }
    
    // tabBar高度 + 底部安全高度
    static let tabBarHeight: CGFloat = tabBarIntrinsicHeight + UIDevice.safeAreaInsets.bottom
    
    // 导航栏高度实际高度
    static let navBarIntrinsicHeight: CGFloat = 44.0
    
    // tabBar实际高度
    static let tabBarIntrinsicHeight: CGFloat = 49.0
    
    // 屏幕比例
    static let screenWidthScale: CGFloat = CGFloat(UIScreen.main.bounds.width / 414.0)
    
    
    // 安全区域
    static let safeAreaInsets: UIEdgeInsets = {
        let defaultInsets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        guard #available(iOS 11.0, *) else { return defaultInsets }
        return keyWindow?.safeAreaInsets ?? defaultInsets
    }()
    
    // 手机系统版本
    static let iosVersionStr: String = UIDevice.current.systemVersion
    
    // 系统当前语言
    static var currentLanguage: String {
        // 返回设备曾使用过的语言列表
        let languages: [String] = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
        // 当前使用的语言排在第一
        let currentLanguage = languages.first
        return currentLanguage ?? "en-CN"
    }
}
