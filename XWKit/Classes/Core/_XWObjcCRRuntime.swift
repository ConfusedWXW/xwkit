//
//  _XWObjcCRRuntime.swift
//  XWKit
//
//  Created by Jay on 2024/5/20.
//

import Foundation


//public protocol SelfAware: AnyObject {
//    static func awake()
//}


public class NothingToSeeHere: NSObject {
    public static func harmlessFunction() {
        swizzle()
//        let typeCount = Int(objc_getClassList(nil, 0))
//        let types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
//        let safeTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
//        objc_getClassList(safeTypes, Int32(typeCount))
//
//        for index in 0 ..< typeCount { (types[index] as? SelfAware.Type)?.awake() }
//        
//        #if swift(>=4.1)
//        types.deallocate()
//        #else
//        types.deallocate(capacity: typeCount)
//        #endif
    }
    
    
    private static func swizzle() {
        UIView.viewSwizzle
        UIViewController.viewControllerSwizzle
        UINavigationController.navigationControllerSwizzle
        UINavigationBar.navigationBarSwizzle
    }
    
    
    internal class func swizzleMethod(for aClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(aClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector)
        
        let didAddMethod = class_addMethod(aClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(aClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    internal class func overrideImplementation(for targetClass: AnyClass, targetSelector: Selector,
                                               implementationBlock: ((_ originClass: AnyClass, _ originCMD: Selector, _ originalIMPProvider: @escaping ()->IMP)->Any)) -> Bool {
        let originMethod = class_getInstanceMethod(targetClass, targetSelector)
        guard let originMethod = originMethod else { return false }
        let imp = method_getImplementation(originMethod)
        let hasOverride = hasOverrideSuperclassMethod(aClass: targetClass, originalSelector: targetSelector)
        
        // 以 closures 的方式达到实时获取初始方法的 IMP 的目的，从而避免先 swizzle 了 subclass 的方法，再 swizzle superclass 的方法，会发现前者调用时不会触发后者 swizzle 后的版本的 bug。
        let originalIMPProvider = {() -> IMP in
            var result: IMP? = nil
            if hasOverride {
                result = imp
            }else{
                // 如果 superclass 里依然没有实现，则会返回一个 objc_msgForward 从而触发消息转发的流程
                let superclass: AnyClass? = class_getSuperclass(targetClass)
                result = class_getMethodImplementation(superclass, targetSelector)
            }
            
            // 这只是一个保底，这里要返回一个空 block 保证非 nil，才能避免用小括号语法调用 block 时 crash
            // 空 block 虽然没有参数列表，但在业务那边被转换成 IMP 后就算传多个参数进来也不会 crash
            if result == nil {
                result = imp_implementationWithBlock({ (selfObject: AnyClass) in
                    print("没有初始实现")
                })
            }
            return result!
        }

        if hasOverride {
            method_setImplementation(originMethod, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)))
        }else if let typeEncoding = method_getTypeEncoding(originMethod) {
            class_addMethod(targetClass, targetSelector, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)), typeEncoding)
        }else{
            return false
        }
        return true
    }
    
    
    
    
    
    class func hasOverrideSuperclassMethod(aClass: AnyClass, originalSelector: Selector) -> Bool {
        guard let method = class_getInstanceMethod(aClass, originalSelector) else{ return false }
        guard
            let methodOfSuperclass = class_getInstanceMethod(class_getSuperclass(aClass), originalSelector) else{ return true }
        return method != methodOfSuperclass
    }
    
    
}

public class WeakObjectContainer: NSObject {
    weak var weakObject: AnyObject?
    
    init(with weakObject: Any?) {
        super.init()
        self.weakObject = weakObject as AnyObject?
    }
}


