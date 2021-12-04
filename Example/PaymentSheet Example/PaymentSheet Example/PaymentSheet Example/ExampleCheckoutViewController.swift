//
//  ExampleCheckoutViewController.swift
//  PaymentSheet Example
//
//  Created by Yuki Tokuhiro on 12/4/20.
//  Copyright © 2020 stripe-ios. All rights reserved.
//

import Foundation
import Stripe
import UIKit

class ExampleCheckoutViewController: UIViewController {
    
    @IBOutlet weak var buyButton: UIButton!
    
    var paymentSheet: PaymentSheet?
    let backendCheckoutUrl = URL(string: "https://stripe-mobile-payment-sheet.glitch.me/checkout")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buyButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
        buyButton.isEnabled = false
        
        // MARK: Fetch the PaymentIntent and Customer information from the backend
        var request = URLRequest(url: backendCheckoutUrl)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            [weak self] (data, response, error) in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: [])
                        as? [String: Any],
                      let customerId = json["customer"] as? String,
                      let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
                      let paymentIntentClientSecret = json["paymentIntent"] as? String,
                      let publishableKey = json["publishableKey"] as? String,
                      let self = self else { return }
            // 这里的书写习惯, 和自己很像, 就是将所有应该取得值的, 都提前使用 guard 进行拦截.
            // 如果, 不能符合要求, 直接后面的逻辑, 就是有问题的.
            // 取得支付应该使用的各种信息.
                /*
                 {
                 "publishableKey": "pk_test_51HvTI7Lu5o3P18Zp6t5AgBSkMvWoTtA0nyA7pVYDqpfLkRtWun7qZTYCOHCReprfLM464yaBeF72UFfB7cY9WG4a00ZnDtiC2C",
                 "paymentIntent": "pi_3JzLlnLu5o3P18Zp0PrAjiwI_secret_otWMiyLzy3Xx1sSy05GwIz4YU",
                 "customer": "cus_Kef5cnPqI0s8PA",
                 "ephemeralKey": "ek_test_YWNjdF8xSHZUSTdMdTVvM1AxOFpwLEo3anpSSjRFWjlQV1E3d0hHcVJrOUFBNllmcnVRUG4_008cYCOr8o"
                 }
                 */
                // MARK: Set your Stripe publishable key - this allows the SDK to make requests to Stripe for your account
                /*
                 publishableKey 应该是标识商家的 id Code 字段. 可以写死在客户端. 这是商家在 Stripe 标识.
                 */
                STPAPIClient.shared.publishableKey = publishableKey
                
                // MARK: Create a PaymentSheet instance
                var configuration = PaymentSheet.Configuration()
                // 商家的展示信息.
                configuration.merchantDisplayName = "Yami Tech Food"
                //                configuration.applePay = .init(
                //                    merchantId: "com.foo.example", merchantCountryCode: "US")
                configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
                configuration.returnURL = "payments-example://stripe-redirect"
                
                /*
                 通过网络请求, 获取到应该拿到的数据. 然后, 才会生成一个 PaymentSheet.
                 */
                self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
                DispatchQueue.main.async {
                    self.buyButton.isEnabled = true
                }
            })
        task.resume()
    }
    
    
    @objc
    func didTapCheckoutButton() {
        
        /*
         然后, 所有的操作, 都移交给了 paymentSheet 去处理了.
         PaymentSheet 是一个控制类, 它并不是一个 VC. 提交一个完成回调给 PaymentSheet, 然后, 所有的中间逻辑, 都是 PaySheet 去处理. 
         */
        paymentSheet?.present(from: self) { paymentResult in
            // MARK: Handle the payment result
            switch paymentResult {
            case .completed:
                self.displayAlert("Your order is confirmed!")
            case .canceled:
                print("Canceled!")
            case .failed(let error):
                print(error)
                self.displayAlert("Payment failed: \n\(error.localizedDescription)")
            }
        }
    }
    
    func displayAlert(_ message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alertController.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}
