//
//  ExchangeRate+CoreDataProperties.swift
//  CurrencyExchange
//
//  Created by Thazin Nwe on 26/12/2020.
//
//

import Foundation
import CoreData


extension ExchangeRate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExchangeRate> {
        return NSFetchRequest<ExchangeRate>(entityName: "ExchangeRate")
    }

    @NSManaged public var code: String?
    @NSManaged public var desc: String?
    @NSManaged public var source: String?
    @NSManaged public var rate: Double
    @NSManaged public var update_date: Date?

}

extension ExchangeRate : Identifiable {

}
