//
//  UIColor+WX.swift
//  XWExtensionKit
//
//  Created by Jay on 2023/11/8.
//

import UIKit
import Foundation

public extension UIColor {
    /**
     *  获取当前 UIColor 对象里的红色色值
     *
     *  @return 红色通道的色值，值范围为0.0-1.0
     */
    var red: Float {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Float(r)
    }
    
    
    /**
     *  获取当前 UIColor 对象里的绿色色值
     *
     *  @return 绿色通道的色值，值范围为0.0-1.0
     */
    var green: Float {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Float(g)
    }
    
    
    /**
     *  获取当前 UIColor 对象里的蓝色色值
     *
     *  @return 蓝色通道的色值，值范围为0.0-1.0
     */
    var blue: Float {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Float(b)
    }
    
    
    /**
     *  获取当前 UIColor 对象里的透明色值
     *
     *  @return 透明通道的色值，值范围为0.0-1.0
     */
    var alpha: Float {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Float(a)
    }
    
    
    
    /**
     *  使用HEX命名方式的颜色字符串生成一个UIColor对象
     *
     *  @param hexString 支持以 # 开头和不以 # 开头的 hex 字符串
     *      #RGB        例如#f0f，等同于#ffff00ff，RGBA(255, 0, 255, 1)
     *      #ARGB       例如#0f0f，等同于#00ff00ff，RGBA(255, 0, 255, 0)
     *      #RRGGBB     例如#ff00ff，等同于#ffff00ff，RGBA(255, 0, 255, 1)
     *      #AARRGGBB   例如#00ff00ff，等同于RGBA(255, 0, 255, 0)
     *
     * @return UIColor对象
     */
    convenience init?(hexStr: String) {
        guard hexStr.count > 0 else { return nil }
        let colorString = hexStr.replacingOccurrences(of: "#", with: "")
        var r: Float = 0
        var g: Float = 0
        var b: Float = 0
        var alpha: Float = 0
        
        switch colorString.count {
        case 3: // #RGB
            alpha = 1.0;
            r = Self.colorComponentFrom(hexStr: colorString, start: 0, length: 1)
            g = Self.colorComponentFrom(hexStr: colorString, start: 1, length: 1)
            b = Self.colorComponentFrom(hexStr: colorString, start: 2, length: 1)
            break
            
        case 4: // #ARGB
            alpha = Self.colorComponentFrom(hexStr: colorString, start: 0, length: 1)
            r = Self.colorComponentFrom(hexStr: colorString, start: 1, length: 1)
            g = Self.colorComponentFrom(hexStr: colorString, start: 2, length: 1)
            b = Self.colorComponentFrom(hexStr: colorString, start: 3, length: 1)
            break
            
        case 6: // #RRGGBB
            alpha = 1.0;
            r = Self.colorComponentFrom(hexStr: colorString, start: 0, length: 2)
            g = Self.colorComponentFrom(hexStr: colorString, start: 2, length: 2)
            b = Self.colorComponentFrom(hexStr: colorString, start: 4, length: 2)
            break
            
        case 8: // #AARRGGBB
            alpha = Self.colorComponentFrom(hexStr: colorString, start: 0, length: 2)
            r = Self.colorComponentFrom(hexStr: colorString, start: 2, length: 2)
            g = Self.colorComponentFrom(hexStr: colorString, start: 4, length: 2)
            b = Self.colorComponentFrom(hexStr: colorString, start: 6, length: 2)
            
            break
            
        default: break
        }
        
        
        self.init(red: CGFloat(r / 255.0),
                  green: CGFloat(g / 255.0),
                  blue: CGFloat(b / 255.0),
                  alpha: CGFloat(alpha))
    }
    
    
    // 十六进制颜色值
    convenience init(hex hexValue: UInt32, alpha: Float = 1.0) {
        self.init(red: CGFloat(Float((hexValue & 0xFF0000) >> 16) / 255.0),
                  green: CGFloat(Float((hexValue & 0xFF00) >> 8) / 255.0),
                  blue: CGFloat(Float(hexValue & 0xFF) / 255.0),
                  alpha: CGFloat(alpha))
    }
    
    // 十进制RGB颜色值
    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(Float(r) / 255.0),
                  green: CGFloat(Float(g) / 255.0),
                  blue: CGFloat(Float(b) / 255.0),
                  alpha: CGFloat(alpha))
    }
    
    
   fileprivate static func colorComponentFrom(hexStr: String, start: Int, length: Int) -> Float {
        var substring = hexStr.substring(range: NSRange(location: start, length: length))
        var fullHex = substring.count == 2 ? substring : "\(substring)\(substring)"
        var hexComponent: UInt64 = 0
        Scanner(string: fullHex).scanHexInt64(&hexComponent)
        return Float(hexComponent) / 255.0
    }
    

}




public extension UIColor {
    /**
     *  将自身变化到某个目标颜色，可通过参数progress控制变化的程度，最终得到一个纯色
     *  @param toColor 目标颜色
     *  @param progress 变化程度，取值范围0.0f~1.0f
     */
    func transitionToColor(toColor: UIColor, progress: Float) -> UIColor {
        Self.colorFromColor(fromColor: self, toColor: toColor, progress: progress)
    }
    
    
    /**
     *  将颜色A变化到颜色B，可通过progress控制变化的程度
     *  @param fromColor 起始颜色
     *  @param toColor 目标颜色
     *  @param progress 变化程度，取值范围0.0f~1.0f
     */
    static func colorFromColor(fromColor: UIColor, toColor: UIColor, progress: Float) -> UIColor {
        let progress = min(progress, 1.0)
        let fromRed = fromColor.red
        let fromGreen = fromColor.green
        let fromBlue = fromColor.blue
        let fromAlpha = fromColor.alpha
        
        let toRed = toColor.red
        let toGreen = toColor.green
        let toBlue = toColor.blue
        let toAlpha = toColor.alpha
        
        let finalRed = fromRed + (toRed - fromRed) * progress
        let finalGreen = fromGreen + (toGreen - fromGreen) * progress
        let finalBlue = fromBlue + (toBlue - fromBlue) * progress
        let finalAlpha = fromAlpha + (toAlpha - fromAlpha) * progress
        
        return UIColor(red: CGFloat(finalRed / 255.0),
                  green: CGFloat(finalGreen / 255.0),
                  blue: CGFloat(finalBlue / 255.0),
                  alpha: CGFloat(finalAlpha))
    }
    
    
    static func randomColor() -> UIColor {
        let red = CGFloat(arc4random() % 255) / 255.0
        let green = CGFloat(arc4random() % 255) / 255.0
        let blue = CGFloat(arc4random() % 255) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
