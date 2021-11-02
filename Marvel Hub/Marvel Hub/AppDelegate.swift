//
//  AppDelegate.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 28/10/2021.
//

import UIKit
import CryptoKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


}
extension String{
    var md5 : String{
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
extension Date {
    func toMillis() -> Int64! {
            return Int64(self.timeIntervalSince1970 * 1000)
    }
}
