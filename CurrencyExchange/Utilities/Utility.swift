//
//  Utility.swift
//  CurrencyExchange
//
//  Created by Thazin Nwe on 23/12/2020.
//

import Foundation
import UIKit
import Alamofire

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}

class Utility : NSObject {
    
    // MARK: - get network status
    class func getStatus(status code: Int?) -> NetworkStatus {
        
        guard let statusCode = code else {
            return .Null
        }
        switch statusCode {

            case 500...599:
                return .Failure
            case 200:
                return .Success
            case 401:
                return .Unauthorized
            default:
                return .Error
        }
    }
    
    // MARK: - show alert
    class func showAlertWith(Title title: String, AndMessage message: String, On viewController: UIViewController, completion: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion()
        }))
        viewController.present(alertController, animated: true, completion: {
        })
    }
    
    // MARK: - formatting date
    class func displayDateFrom(date : Date, format: String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

}
