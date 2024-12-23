//
//  UIDevice+XWWrappable.swift
//  XWKit
//
//  Created by Jay on 2024/3/1.
//

import Foundation


public extension XWKit where T: UIDevice {
    // 是否是平板
    static var isIPad: Bool { return UIDevice.isIPad }
    
    // 是否是手机
    static var isIPhone: Bool { return UIDevice.isIPhone }
    
    // 是否是刘海屏
    static var isFringeScreen: Bool { return UIDevice.isFringeScreen }
    
    // 主window
    static var keyWindow: UIWindow? { return UIDevice.keyWindow }
    
    // 所有window
    static var windows: [UIWindow] { return UIDevice.windows }
    
    // 屏幕
    static var screen: UIScreen { return UIDevice.screen }
    
    // 屏幕宽度
    static var screenWidth: CGFloat { return UIDevice.screenWidth }

    // 屏幕高度
    static var screenHeight: CGFloat { return UIDevice.screenHeight }
    
    // 状态栏高度
    static var statusBarHeight: CGFloat { return UIDevice.statusBarHeight }
    
    // 导航栏高度 + 状态栏高度
    static var navBarHeight: CGFloat { return UIDevice.navBarHeight }
    
    // tabBar高度 + 底部安全高度
    static var tabBarHeight: CGFloat { return UIDevice.tabBarHeight }
    
    // 导航栏高度实际高度
    static var navBarIntrinsicHeight: CGFloat { return UIDevice.navBarIntrinsicHeight }
    
    // tabBar实际高度
    static var tabBarIntrinsicHeight: CGFloat { return UIDevice.tabBarIntrinsicHeight }
    
    // 屏幕比例
    static var screenWidthScale: CGFloat { return UIDevice.screenWidthScale }
    
    // 安全区域
    static var safeAreaInsets: UIEdgeInsets { return UIDevice.safeAreaInsets }
    
    // 手机系统版本
    static var iosVersionStr: String { return UIDevice.iosVersionStr }
}
