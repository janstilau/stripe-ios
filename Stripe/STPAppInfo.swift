//
//  STPAppInfo.swift
//  StripeiOS
//
//  Created by Yuki Tokuhiro on 6/20/19.
//  Copyright © 2019 Stripe, Inc. All rights reserved.
//

import Foundation

/*
    关于商家的一些信息, 在示例里面, 其实也没有专门进行设置. 
 */
/// Libraries wrapping the Stripe SDK should use this object to provide information about the library, and set it
/// in on `STPAPIClient`.  This information is passed to Stripe so that we can contact you about future issues or critical updates.
/// - seealso: https://stripe.com/docs/building-plugins#setappinfo
public class STPAppInfo: NSObject {
    /// Initializes an instance of `STPAppInfo`.
    /// - Parameters:
    ///   - name:        The name of your library (e.g. "MyAwesomeLibrary").
    ///   - partnerId:   Your Stripe Partner ID (e.g. "pp_partner_1234"). Required for Stripe Verified Partners, optional otherwise.
    ///   - version:     The version of your library (e.g. "1.2.34"). Optional.
    ///   - url:         The website for your library (e.g. "https://myawesomelibrary.info"). Optional.
    @objc
    public init(
        name: String,
        partnerId: String?,
        version: String?,
        url: String?
    ) {
        self.name = name
        self.partnerId = partnerId
        self.version = version
        self.url = url
        super.init()
    }

    /// The name of your library (e.g. "MyAwesomeLibrary").
    @objc public private(set) var name: String
    /// Your Stripe Partner ID (e.g. "pp_partner_1234").
    @objc public private(set) var partnerId: String?
    /// The version of your library (e.g. "1.2.34").
    @objc public private(set) var version: String?
    /// The website for your library (e.g. "https://myawesomelibrary.info").
    @objc public private(set) var url: String?
}
