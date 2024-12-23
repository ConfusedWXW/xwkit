//
//  URL+XW.swift
//  XWKit
//
//  Created by Jay on 2024/5/17.
//

import Foundation


public extension URL {
    // 获取当前 query 的参数列表
    var queryItems: [String: String]? {
        guard self.absoluteString.count > 0 else { return nil }
        let urlComponents = URLComponents(string: self.absoluteString)
        guard let queryItems = urlComponents?.queryItems else { return nil }
        
        var params: [String: String] = [:]
        for item in queryItems {
            params[item.name] = item.value ?? ""
        }
        return params
    }
}
