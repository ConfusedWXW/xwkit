//
//  APP.swift
//  XWKit
//
//  Created by Jay on 2024/3/1.
//

import Foundation


/**
 *  APP
 */
public struct XWAPP {
    // APP 显示名称
    public static let displayName: String = ((Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String) ?? "" )
    
    // APP 版本号
    public static let versionStr: String = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "" )
    
    // APP 编译号
    public static let bundleStr: String = ((Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "" )
    
    // APP BundleId
    public static let bundleId: String = ((Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String) ?? "")
}
