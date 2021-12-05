//
//  STPDispatchFunctions.swift
//  Stripe
//
//  Created by Brian Dorfman on 10/24/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

import Foundation

// 在这里, 主动地进行主线程的调度的动作. 
func stpDispatchToMainThreadIfNecessary(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}
