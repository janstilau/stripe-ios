//
//  STPMultipartFormDataPart.swift
//  Stripe
//
//  Created by Charles Scalesse on 12/1/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

import Foundation

/*
    这里, 模拟的是, post 的 Multipart 的设计思路. 
 */
class STPMultipartFormDataPart: NSObject {
    /// The data for this part.
    var data: Data?
    /// The name for this part.
    var name: String?
    /// The filename for this part. As a rule of thumb, this can be ommitted when the data is just an encoded string. However, this is typically required for other types of binary file data (like images).
    var filename: String?
    /// The content type for this part. When omitted, the multipart/form-data standard assumes text/plain.
    var contentType: String?
    
    /// Returns the fully-composed data for this part.
    // MARK: - Data Composition
    
    func composedData() -> Data {
        var data = Data()
        
        var contentDisposition = "Content-Disposition: form-data; name=\"\(name ?? "")\""
        if filename != nil {
            contentDisposition += "; filename=\"\(filename ?? "")\""
        }
        contentDisposition += "\r\n"
        
        if let data1 = contentDisposition.data(using: .utf8) {
            data.append(data1)
        }
        
        var contentType = ""
        if let _contentType = self.contentType {
            contentType.append("Content-Type: \(_contentType)\r\n")
        }
        contentType += "\r\n"
        if let data1 = contentType.data(using: .utf8) {
            data.append(data1)
        }
        
        // 真正的数据拼接的部分, 是在这里.
        if let _data = self.data {
            data.append(_data)
        }
        if let data1 = "\r\n".data(using: .utf8) {
            data.append(data1)
        }
        
        return data
    }
}
