//
//  Int+XW.swift
//  XWKit
//
//  Created by Jay on 2024/3/1.
//

import Foundation

public extension Int {
    var hexStr: String {
        return toHexString()
    }
    
    // 将Int转16进制 Int 必须小于等于255 否则返回0
    var byte: Byte {
        return self < 0 ? 0 : Byte(self)
    }
    
    // 将Int转16进制数组
    var bytes: [Byte] {
        return Array(hex: hexStr)
    }
    
    // 将Int转16进制字符串
    func toHexString() -> String {
        return String(self, radix: 16)
    }
    
    /// 播放时间 MMSS
    func toPlayTimeMMSSStr() -> String {
        
        let secounds = TimeInterval(self)
        
        if secounds.isNaN {
            return "00:00"
        }
        var minute = Int(secounds / 60)
        let second = Int(secounds.truncatingRemainder(dividingBy: 60))
        var hour = 0
        if minute >= 60 {
            hour = Int(minute / 60)
            minute = minute - hour * 60
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        }
        return String(format: "%02d:%02d", minute, second)
    }
    
    /// 播放时间 HHMMSS
    func toPlayTimeHHMMSSStr() -> String {
        let secounds = TimeInterval(self)
        
        if secounds.isNaN {
            return "00:00:00"
        }
        var minute = Int(secounds / 60)
        let second = Int(secounds.truncatingRemainder(dividingBy: 60))
        var hour = 0
        if minute >= 60 {
            hour = Int(minute / 60)
            minute = minute - hour * 60
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        }
        return String(format: "%02d:%02d:%02d", hour, minute, second)
    }
}

