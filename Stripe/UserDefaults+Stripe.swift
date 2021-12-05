//
//  UserDefaults+Stripe.swift
//  StripeiOS
//
//  Created by Yuki Tokuhiro on 5/21/21.
//  Copyright © 2021 Stripe, Inc. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    /*
        Swift 没有命名空间的概念.
        想要将相关的变量集中要一块, 可以使用 Enum. 这也是一种 Apple 推荐的一种方式.
     */
    enum StripeKeys: String {
        /// The key for a dictionary of Customer id to their last selected payment method ID
        case customerToLastSelectedPaymentMethod = "com.stripe.lib:STPStripeCustomerToLastSelectedPaymentMethodKey"
        /// The key for a dictionary FraudDetectionData dictionary
        case fraudDetectionData = "com.stripe.lib:FraudDetectionDataKey"
    }
    
    var customerToLastSelectedPaymentMethod: [String: String]? {
        get {
            let key = StripeKeys.customerToLastSelectedPaymentMethod.rawValue
            /*
             The dictionary object associated with the specified key, or nil if the key does not exist or its value is not a dictionary.
             
             这是 UserDefault 已经存在的一个方法, 之前并没有这样的一个方法.
             */
            return dictionary(forKey: key) as? [String: String]
        }
        set {
            let key = StripeKeys.customerToLastSelectedPaymentMethod.rawValue
            setValue(newValue, forKey: key)
        }
    }
    
    var fraudDetectionData: FraudDetectionData? {
        get {
            let key = StripeKeys.fraudDetectionData.rawValue
            guard let data = data(forKey: key) else {
                return nil
            }
            do {
                return try JSONDecoder().decode(FraudDetectionData.self, from: data)
            }
            catch(let e) {
                assertionFailure("\(e)")
                return nil
            }
        }
        set {
            let key = StripeKeys.fraudDetectionData.rawValue
            do {
                let data = try JSONEncoder().encode(newValue)
                setValue(data, forKey: key)
            }
            catch(let e) {
                assertionFailure("\(e)")
                return
            }
        }
    }
}

