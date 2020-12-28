//
//  StringTable.swift
//  CurrencyExchange
//
//  Created by Thazin Nwe on 23/12/2020.
//

import Foundation

struct StringTable {
    
    static let ACCESS_KEY = "2cdc43cfaf3a9b7d5a44c3c4cfc88a8d"
    static let DATAMODEL = "Rate"
    static let ENTITYNAME = "ExchangeRate"
}

struct APILink {
    
    static let BASE_URL = "http://api.currencylayer.com/"
    static let GET_CURRENCY_LIST = "list"
    static let GET_CURRENCY_RATE = "live"
    
}

enum NetworkStatus {
    
    case Success
    case Error
    case Failure
    case Unauthorized
    case Null
}
