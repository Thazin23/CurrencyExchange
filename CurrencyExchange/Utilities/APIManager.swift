//
//  APIManager.swift
//  CurrencyExchange
//
//  Created by Thazin Nwe on 23/12/2020.
//

import Foundation
import SwiftyJSON
import Alamofire
import SVProgressHUD

class APIManager: NSObject {
    
    static let shareManager = APIManager()
    
    // MARK: - Get full list of supported currencies
    
    func getCurrencyList(completion: @escaping (JSON, NetworkStatus) -> Void) {
        
        //http://api.currencylayer.com/list?access_key=2cdc43cfaf3a9b7d5a44c3c4cfc88a8d
        guard let url = URL(string: "\(APILink.BASE_URL)\(APILink.GET_CURRENCY_LIST)?access_key=\(StringTable.ACCESS_KEY)") else {
            completion(JSON.null, .Failure)
            return
        }
        print("url: \(url)")
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            print(response.result)
            let status = Utility.getStatus(status: response.response?.statusCode)
            switch (status) {
            case .Success:
                if let json = response.value{
                    completion(JSON(json),status)
                }
                break
            case .Failure:
                completion(JSON.null, status)
                break
            case .Error:
                completion(JSON.null, status)
                break
            case .Unauthorized:
                completion(JSON.null, status)
                break
            case .Null:
                completion(JSON.null, status)
                break
            }
        }
    }
    

    func getExchangeRate(fromCurrency: String, toCurrency: String ,completion: @escaping (JSON, NetworkStatus) -> Void) {
        
       // http://api.currencylayer.com/live?access_key=2cdc43cfaf3a9b7d5a44c3c4cfc88a8d&currencies=USD,AUD,CAD,PLN,MXN&format=1
        guard let url = URL(string: "\(APILink.BASE_URL)\(APILink.GET_CURRENCY_RATE)?access_key=\(StringTable.ACCESS_KEY)&currencies=\(fromCurrency),\(toCurrency)") else {
            completion(JSON.null, .Failure)
            return
        }
        print("url: \(url)")
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            print(response.result)
            let status = Utility.getStatus(status: response.response?.statusCode)
            switch (status) {

            case .Success:
                if let json = response.value{
                    completion(JSON(json),status)
                }
                break
            case .Failure:
                completion(JSON.null, status)
                break
            case .Error:
                completion(JSON.null, status)
                break
            case .Unauthorized:
                completion(JSON.null, status)
                break
            case .Null:
                completion(JSON.null, status)
                break
            }
        }
    }
}
