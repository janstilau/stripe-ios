//
//  STPFormEncoder.swift
//  Stripe
//
//  Created by Jack Flintermann on 1/8/15.
//  Copyright (c) 2015 Stripe, Inc. All rights reserved.
//

import Foundation

class STPFormEncoder: NSObject {
    
    @objc class func dictionary(forObject object: (NSObject & STPFormEncodable)) -> [String: Any] {
        // returns [object root name : object.coded (eg [property name strings: property values)]
        // 一个自定义的编码的控制过程.
        let keyPairs = self.keyPairDictionary(forObject: object)
        let rootObjectName = type(of: object).rootObjectName()
        if let rootObjectName = rootObjectName {
            return [rootObjectName: keyPairs]
        } else {
            return keyPairs
        }
    }
    
    // MARK: - Internal
    
    /// Returns [Property name : Property's form encodable value]
    private class func keyPairDictionary(forObject object: (NSObject & STPFormEncodable))
    -> [String: Any]
    {
        var keyPairs: [String: Any] = [:]
        /*
            propertyNamesToFormFieldNamesMapping 里面存储的是值在 Encode 的过程中, 应该存储的值, 已经这个值的 Get 方法.
         */
        for (propertyName, formFieldName) in type(of: object).propertyNamesToFormFieldNamesMapping()
        {
            // Value 的取值, 直接使用的 KVC 的方法.
            if let propertyValue = object.value(forKeyPath: propertyName) {
                guard let propertyValue = propertyValue as? NSObject else {
                    assertionFailure()
                    continue
                }
                // 然后, 使用一个 formEncodableValue, 将这个值, 变为一个 Dict 里面的内容.
                keyPairs[formFieldName] = formEncodableValue(for: propertyValue)
            }
        }
        
        for (additionalFieldName, additionalFieldValue) in object.additionalAPIParameters {
            guard let additionalFieldName = additionalFieldName as? String,
                  let additionalFieldValue = additionalFieldValue as? NSObject
            else {
                assertionFailure()
                continue
            }
            keyPairs[additionalFieldName] = formEncodableValue(for: additionalFieldValue)
        }
        return keyPairs
    }
    
    /// Expands object, and any subobjects, into key pair dictionaries if they are STPFormEncodable
    private class func formEncodableValue(for object: NSObject) -> NSObject {
        switch object {
        case let object as NSObject & STPFormEncodable:
            return self.keyPairDictionary(forObject: object) as NSObject
        case let dict as NSDictionary:
            let result = NSMutableDictionary(capacity: dict.count)
            dict.enumerateKeysAndObjects({ key, value, _ in
                if let key = key as? NSObject,  // Don't all keys need to be Strings?
                   let value = value as? NSObject
                {
                    result[formEncodableValue(for: key)] = formEncodableValue(for: value)
                } else {
                    assertionFailure()  // TODO remove
                }
            })
            return result
        case let array as NSArray:
            let result = NSMutableArray()
            for element in array {
                guard let element = element as? NSObject else {
                    assertionFailure()  // TODO remove
                    continue
                }
                result.add(formEncodableValue(for: element))
            }
            return result
        case let set as NSSet:
            let result = NSMutableSet()
            for element in set {
                guard let element = element as? NSObject else {
                    continue
                }
                result.add(self.formEncodableValue(for: element))
            }
            return result
        default:
            return object
        }
    }
}
