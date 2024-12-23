//
//  String+XW.swift
//  XWExtensionKit
//
//  Created by Jay on 2023/11/8.
//

import Foundation
import UIKit
import CommonCrypto

public extension String {
    // 按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
    var lengthWhenCountingNonASCIICharacterAsTwo: Int {
        return self.reduce(0, { $0 + ($1.isASCII ? 1: 2) })
    }
    
    // 去掉头尾的空白字符
    var trim: String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    // 去掉所有的空白字符
    var trimAll: String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    // 把该字符串转换为对应的 md5
    var md5: String {
        guard let data = self.data(using: .utf8) else {
            return self
        }
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        #if swift(>=5.0)
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            return CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        #else
        _ = data.withUnsafeBytes { bytes in
            return CC_MD5(bytes, CC_LONG(data.count), &digest)
        }
        #endif
        
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    

    
    // 正则匹配
    func isMatch(byRegex: String) -> Bool {
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", byRegex)
        return predicate.evaluate(with: self)
    }
    
    var range: NSRange { return NSRange(location: 0, length: self.count) }
    
    func nsRange(fromSubString subString: String, options: String.CompareOptions = []) -> NSRange? {
        let subRange = self.range(of: subString, options: options)
        if let subRange = subRange {
            return NSRange(subRange, in: self)
        }
        return nil
    }
    
    func substring(range: NSRange) -> String {
        return self.substring(from: range.location, count: range.length)
    }
    
    func substring(from: Int, count: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(startIndex, offsetBy: count)
        return String(self[startIndex..<endIndex])
    }
    
    func substring(from: Int, to: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.endIndex, offsetBy: to - self.count)
        let subString = self[startIndex..<endIndex]
        return String(subString)
    }
    
    func substring(from index: Int) -> String {
        return self.substring(from: index, to: self.count)
    }
    
    func substring(to index: Int) -> String {
        return self.substring(from: 0, to: index)
    }
    
    func ensureLeft(_ prefix: String) -> String {
        if self.hasPrefix(prefix) {
            return self
        } else {
            return "\(prefix)\(self)"
        }
    }
    
    func ensureRight(_ suffix: String) -> String {
        if self.hasSuffix(suffix) {
            return self
        } else {
            return "\(self)\(suffix)"
        }
    }
    
    func chompLeft(_ prefix: String) -> String {
        if let prefixRange = range(of: prefix) {
            if prefixRange.upperBound >= endIndex {
                return String(self[startIndex..<prefixRange.lowerBound])
            } else {
                return String(self[prefixRange.upperBound..<endIndex])
            }
        }
        return self
    }
    
    
    // api 与参数拼接
    func api(addParams: [String: Any]) -> String {
        /// 参数连接标识
        let addParamsTagStr = (self.contains("?") || addParams.count == 0) ? "" : "?"
        let combineTagStr = (addParams.count == 0 || self.hasSuffix("&") || self.hasSuffix("?")) ? "" : "&"
        let paramsStr = addParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let toString = self + addParamsTagStr + combineTagStr + paramsStr
        
        return toString
    }
    
    // api 与子路径拼接
    func api(addPath: String) -> String {
        var toDomain = self
        for i in self.reversed() {
            if i == "/" {
                toDomain.removeLast()
            } else {
                break
            }
        }
        
        var toPath = addPath
        
        for i in addPath {
            if i == "/" {
                toPath.removeFirst()
            } else {
                break
            }
        }
        
        let toString = toDomain.ensureRight("/") + toPath
        return toString
    }
    
    
    /// 根据00:00:00时间格式，转换成秒
    func asPlayTimeSeconds() -> Int {
        var list = self.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "：", with: ":").components(separatedBy: ":")
        list.reverse()
        
        var seconds = 0
        for (index, value) in list.enumerated() {
            if index == 0, let s = Int(value), s > 0 {
                seconds += s
            }else if index == 1, let m = Int(value), m > 0 {
                seconds += (m * 60)
            }else if index == 2, let h = Int(value), h > 0 {
                seconds += (h * 3600)
            }
        }
        
        return seconds
    }
}



/// 常用正则
public enum CommonMatchRegex: String {
    
    // 简单手机号码校验
    case phone = "^1[0-9]{10}$"
    // 严格手机号码校验
    case phoneStrict = "^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\\d{8}$"
    // 数字
    case number = "[0-9]+$"
    // 邮编
    case zipCode = "^[1-9]\\d{5}$"
    // ip 地址
    case ipAddress = "((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)"
    // 网址
    case website = "[a-zA-z]+://[^\\s]*"
    // 数字和字母
    case alphanumeric = "^[0-9A-Za-z]+$"
    // 用户名
    case nickname = "^[a-zA-Z0-9\\u4e00-\\u9fa5_]{1,10}$"
    // 密码
    case password = "^[a-zA-Z0-9]{6,16}$"
    
    case passwordStrict = "^(?=.*[a-z])(?=.*[a-z]).{6,16}$"
    
    /**
     严格密码校验(6-16位字母或数字，首位不能为数字,不能纯字母,不能纯数字)
     (?![0-9]+$) 表示不为多个数字
     (?![a-zA-Z]+$) 表示不为多个字母
     */
    case passwordStrict1 = "^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,16}"
    
    // 身份证简单校验
    case idCard = "(^[0-9]{15}$)|([0-9]{17}([0-9]|[xX])$)"
    
    // 18位身份证
    case idCard18 = "^\\d{6}(18|19|20)?\\d{2}(0[1-9]|1[012])(0[1-9]|[12]\\d|3[01])\\d{3}(\\d|[xX])$"
    
    // 车牌
    case carNumber = "^[京津沪渝蒙新藏宁桂黑吉辽晋青冀鲁豫苏皖浙闽赣湘鄂粤琼甘陕川云贵]{1}[A-Za-z]{1}[A-Za-z0-9]{5,6}$"
    
    // 简单邮箱校验
    case email = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*.\\w+([-.]\\w+)*$"
    /**
     严格邮箱校验
     
     @之前必须有内容且只能是字母（大小写）、数字、下划线(_)、减号（-）、点（.)
     @和最后一个点（.）之间必须有内容且只能是字母（大小写）、数字、点（.）、减号（-），且两个点不能挨着
     最后一个点（.）之后必须有内容且内容只能是字母（大小写）、数字且长度为大于等于2个字节，小于等于6个字节
     */
    case emailStrict = "^[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*\\.[a-zA-Z0-9]{2,6}$"
}




public extension XWKit where T == String {
    

    
}
