//
//  Images.swift
//  StripeiOS
//
//  Created by Yuki Tokuhiro on 5/19/21.
//  Copyright © 2021 Stripe, Inc. All rights reserved.
//

import Foundation
import UIKit

// 将, 所有特殊的图片, 使用特殊的命名, 用面向对象的方式, 进行管理. 
enum Image: String, CaseIterable {
    /// https://developer.apple.com/apple-pay/marketing/
    case apple_pay_mark = "apple_pay_mark"

    // Payment Method Type images
    case pm_type_afterpay = "icon-pm-afterpay"
    case pm_type_bancontact = "icon-pm-bancontact"
    case pm_type_card = "icon-pm-card"
    case pm_type_eps = "icon-pm-eps"
    case pm_type_giropay = "icon-pm-giropay"
    case pm_type_ideal = "icon-pm-ideal"
    case pm_type_p24 = "icon-pm-p24"
    case pm_type_sepa = "icon-pm-sepa"
    case pm_type_sofort = "icon-pm-sofort"

    // Icons/symbols
    case icon_checkmark = "icon_checkmark"
    case icon_chevron_left = "icon_chevron_left"
    case icon_chevron_down = "icon_chevron_down"
    case icon_lock = "icon_lock"
    case icon_plus = "icon_plus"
    case icon_x = "icon_x"

    func makeImage(template: Bool = false) -> UIImage {
        return STPImageLibrary.safeImageNamed(
            self.rawValue,
            templateIfAvailable: template
        )
    }
}
