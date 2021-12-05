//
//  NSMutableURLRequest+Stripe.swift
//  StripeCore
//
//  Created by Ben Guo on 4/22/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    
    @_spi(STP) public func stp_addParameters(toURL parameters: [String: Any]) {
        guard let url = url else {
            assertionFailure()
            return
        }
        
        let urlString = url.absoluteString
        let query = URLEncoder.queryString(from: parameters)
        // 如果, URL 的 query 不是空, 那么就是自己创建的就是就是 url 的 query, 否则, 自己创建的, 就是拼接在后面的 Query.
        self.url = URL(string: urlString + (url.query != nil ? "&\(query)" : "?\(query)"))
    }

    /*
        将, Dict 变为 Data 字符串, 然后赋值到 HttpRequest 里面.
     */
    @_spi(STP) public func stp_setFormPayload(_ formPayload: [String: Any]) {
        let formData = URLEncoder.queryString(from: formPayload).data(using: .utf8)
        httpBody = formData
        setValue(
            String(format: "%lu", UInt(formData?.count ?? 0)), forHTTPHeaderField: "Content-Length")
        setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }

    @_spi(STP) public func stp_setMultipartForm(_ data: Data?, boundary: String?) {
        httpBody = data
        setValue(
            String(format: "%lu", UInt(data?.count ?? 0)), forHTTPHeaderField: "Content-Length")
        setValue(
            "multipart/form-data; boundary=\(boundary ?? "")", forHTTPHeaderField: "Content-Type")
    }
}
