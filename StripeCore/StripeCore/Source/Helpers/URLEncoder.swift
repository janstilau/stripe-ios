//
//  URLEncoder.swift
//  StripeCore
//
//  Created by Mel Ludowise on 5/26/21.
//

import Foundation

/*
    这个类, 就是将 KeyValue 变为 Data 形式的一个类.
 */
@_spi(STP) public final class URLEncoder {
    public class func string(byURLEncoding string: String) -> String {
        return escape(string)
    }
    
    public class func stringByReplacingSnakeCase(withCamelCase input: String) -> String {
        let parts: [String] = input.components(separatedBy: "_")
        var camelCaseParam = ""
        for (idx, part) in parts.enumerated() {
            camelCaseParam += idx == 0 ? part : part.capitalized
        }
        return camelCaseParam
    }
    
    @objc(queryStringFromParameters:)
    public class func queryString(from parameters: [String: Any]) -> String {
        return query(parameters)
    }
}

// MARK: -
// The code below is adapted from https://github.com/Alamofire/Alamofire
struct Key {
    enum Part {
        case normal(String)
        case dontEscape(String)
    }
    let parts: [Part]
}

/*
    Any 作为一个, 泛型类型, 是无法直接变化成为 String 的.
    在这里, 根据 Value 的类型, 进行了一次转化的动作.
 
    student: [
        age: 10,
        name: "Justin"
    ]
 */
private func queryComponents(fromKey key: String,
                             value: Any) -> [(String, String)] {
    func unwrap<T>(_ any: T) -> Any {
        let mirror = Mirror(reflecting: any)
        guard mirror.displayStyle == .optional,
              let first = mirror.children.first else {
            return any
        }
        return first.value
    }
    
    var components: [(String, String)] = []
    switch value {
        // 在, Get 里面, 其实没有统一的解码思路, 所以一般就是传递 JSON 字符串作为最终的传值的方案.
    case let dictionary as [String: Any]:
        for nestedKey in dictionary.keys.sorted() {
            let value = dictionary[nestedKey]!
            let escapedNestedKey = escape(nestedKey)
            // student[age] = 10
            components += queryComponents(fromKey: "\(key)[\(escapedNestedKey)]", value: value)
        }
    case let array as [Any]:
        for (index, value) in array.enumerated() {
            components += queryComponents(fromKey: "\(key)[\(index)]", value: value)
        }
    case let set as Set<AnyHashable>:
        for value in Array(set) {
            components += queryComponents(fromKey: "\(key)", value: value)
        }
    case let number as NSNumber:
        if number.isBool {
            components.append((key, escape(number.boolValue ? "true" : "false")))
        } else {
            components.append((key, escape("\(number)")))
        }
    case let bool as Bool:
        components.append((key, escape(bool ? "true" : "false")))
    default:
        let unwrappedValue = unwrap(value)
        components.append((key, escape("\(unwrappedValue)")))
    }
    
    return components
}

/// Creates a percent-escaped string following RFC 3986 for a query string key or value.
///
/// - Parameter string: `String` to be percent-escaped.
///
/// - Returns:          The percent-escaped `String`.
private func escape(_ string: String) -> String {
    string.addingPercentEncoding(withAllowedCharacters: URLQueryAllowed) ?? string
}

// 把一个字典, 变为一个字符串.
private func query(_ parameters: [String: Any]) -> String {
    // components 是 key value 的这种格式的.
    var components: [(String, String)] = []
    
    for key in parameters.keys.sorted(by: <) {
        let value = parameters[key]!
        components += queryComponents(fromKey: escape(key), value: value)
    }
    return components.map { "\($0)=\($1)" }.joined(separator: "&")
}

/// Creates a CharacterSet from RFC 3986 allowed characters.
///
/// RFC 3986 states that the following characters are "reserved" characters.
///
/// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
/// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
///
/// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
/// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
/// should be percent-escaped in the query string.
private let URLQueryAllowed: CharacterSet = {
    let generalDelimitersToEncode = ":#[]@"  // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="
    let encodableDelimiters = CharacterSet(
        charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
    
    return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
}()

extension NSNumber {
    fileprivate var isBool: Bool {
        // Use Obj-C type encoding to check whether the underlying type is a `Bool`, as it's guaranteed as part of
        // swift-corelibs-foundation, per [this discussion on the Swift forums](https://forums.swift.org/t/alamofire-on-linux-possible-but-not-release-ready/34553/22).
        String(cString: objCType) == "c"
    }
}
