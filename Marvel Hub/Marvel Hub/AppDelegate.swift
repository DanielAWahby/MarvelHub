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

// MARK:- A short-hand to quickly create the MD5 hash, that is required for the API calls to "MARVEL", from a string. CryptoKit Library is used to create such a hash.

extension String{
    var md5 : String{
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

// MARK:- A short-hand to quickly generate a timestamp, that is required for the API calls to "MARVEL", using the current date.
extension Date {
    func toMillis() -> Int64! {
            return Int64(self.timeIntervalSince1970 * 1000)
    }
}

// MARK:- A shortcut to easily get the localization string from the English and Arabic Localizable files
extension String {
    var localizableString: String {
        NSLocalizedString(self, comment: "")
    }
}
// MARK:- A shortcut to easily detect whether the language set for the application is Arabic. Needed make the necessary changes in some views.
extension UIViewController{
    var isAppArabic : Bool {
        Locale.current.languageCode == "ar"
    }
}
