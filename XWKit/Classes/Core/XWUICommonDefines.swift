//
//  XWUICommonDefines.swift
//  XWKit
//
//  Created by Jay on 2024/6/1.
//

import Foundation

func removeFloatMin(_ floatValue: CGFloat) -> CGFloat {
    return CGFLOAT_MIN == floatValue ? 0 : floatValue
}

/**
 *  基于指定的倍数，对传进来的 floatValue 进行像素取整。若指定倍数为0，则表示以当前设备的屏幕倍数为准。
 *
 *  例如传进来 “2.1”，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
 */
func flatSpecificScale(_ floatValue: CGFloat, _ scale: CGFloat) -> CGFloat {
    let floatValue = removeFloatMin(floatValue)
    let scale = scale > 0 ? scale : UIDevice.screen.scale
    let flattedValue = CGFloat(ceilf(Float(floatValue * scale))) / scale
    return flattedValue
}

/**
 *  基于当前设备的屏幕倍数，对传进来的 floatValue 进行像素取整。
 *
 *  注意如果在 Core Graphic 绘图里使用时，要注意当前画布的倍数是否和设备屏幕倍数一致，若不一致，不可使用 flat() 函数，而应该用 flatSpecificScale
 */
func flat(_ floatValue: CGFloat) -> CGFloat {
    return flatSpecificScale(floatValue, 0)
}

/**
 *  类似flat()，只不过 flat 是向上取整，而 floorInPixel 是向下取整
 */
func floorInPixel(floatValue: CGFloat) -> CGFloat {
    let floatValue = removeFloatMin(floatValue)
    let scale  = UIDevice.screen.scale
    let flattedValue = CGFloat(floorf(Float(floatValue * scale))) / scale
    return flattedValue
}



func CGRectSetY(_ rect: CGRect, _ y: CGFloat) -> CGRect {
    return CGRect(x: rect.origin.x, y: y, width: rect.size.width, height: rect.size.height)
}



/// 计算view的垂直居中，传入父view和子view的frame，返回子view在垂直居中时的y值
func CGRectGetMinYVerticallyCenterInParentRect(_ parentRect: CGRect, _ childRect: CGRect) -> CGFloat {
    return flat((CGRectGetHeight(parentRect) - CGRectGetHeight(childRect)) / 2.0)
}
