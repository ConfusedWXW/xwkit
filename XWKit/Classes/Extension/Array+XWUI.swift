//
//  Array+XW.swift
//  XWKit
//
//  Created by Jay on 2024/3/1.
//

import Foundation

public typealias Byte = UInt8

public extension Array {
    // 安全的取出元素
    func safe(_ index:Index) -> Element? {
       return indices.contains(index) ? self[index] : nil
        
    }

    
    init(reserveCapacity: Int) {
       self = Array<Element>()
       self.reserveCapacity(reserveCapacity)
   }
}




public extension Array where Element == Byte {
    // 将Byte数组转字符串
     var hexStr: String {
        return toHexString()
    }
    
    
    init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }
    
    
    // 将Byte数组转字符串
    func toHexString() -> String {
    return `lazy`.reduce("") {
        var s = String($1, radix: 16)
        if s.count == 1 {
            s = "0" + s
        }
        return $0 + s
    }
}
}
