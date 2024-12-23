//
//  XWNamespaceWrappable.swift
//  XWExtensionKit
//
//  Created by Jay on 2023/11/8.
//

import UIKit


// 定义泛型类
// 定义一个泛型类 XWKit，使用泛型 Base
public struct XWKit<T> {
    public var base: T
    public init(_ base: T) {
        self.base = base
    }
}

// 定义泛型协议
// 定义支持泛型的协议 XWWrappable，并通过协议扩展提供协议的默认实现，返回实现泛型类 XWKit 的对象自身。
public protocol XWWrappable {
    associatedtype WrappableType
    
    static var xw: XWKit<WrappableType>.Type { get }
    
    var xw: XWKit<WrappableType> { get }
}

// 协议的扩展
public extension XWWrappable {
    static var xw: XWKit<Self>.Type {
        get{
            return XWKit<Self>.self
        }
    }
    
    var xw: XWKit<Self> {
        get {
            return XWKit(self)
        }
    }
}




extension NSObject: XWWrappable {}

extension Bool: XWWrappable {}

extension CGFloat: XWWrappable {}
extension Float: XWWrappable {}
extension Double: XWWrappable {}

extension Int: XWWrappable {}
extension Int8: XWWrappable {}
extension Int16: XWWrappable {}
extension Int32: XWWrappable {}
extension Int64: XWWrappable {}
extension UInt: XWWrappable {}
extension UInt8: XWWrappable {}
extension UInt16: XWWrappable {}
extension UInt32: XWWrappable {}
extension UInt64: XWWrappable {}

extension CGPoint: XWWrappable {}
extension CGSize: XWWrappable {}
extension CGRect: XWWrappable {}
