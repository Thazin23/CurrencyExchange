//
//  DataManager.swift
//  CurrencyExchange
//
//  Created by Thazin Nwe on 26/12/2020.
//

import Foundation
import CoreData

class DataManager{
    
    static let sharedManager = DataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: StringTable.DATAMODEL)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = DataManager.sharedManager.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: -
    func saveExchangeRate(code: String, desc: String, source: String, rate: Double)->ExchangeRate? {
      
        let managedContext = DataManager.sharedManager.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: StringTable.ENTITYNAME,
                                                in: managedContext)!
        let newExchangeRate = ExchangeRate(entity: entity,
                                     insertInto: managedContext)
        newExchangeRate.code = code
        newExchangeRate.desc = desc
        newExchangeRate.source = source
        newExchangeRate.rate = rate
        newExchangeRate.update_date = Date()
        
        do {
          try managedContext.save()
          return newExchangeRate as? ExchangeRate
        } catch let error as NSError {
          print("ExchangeRate Could not save. \(error), \(error.userInfo)")
          return nil
        }
    }
    
    func fetchAllExchangeRates() -> [ExchangeRate]?{
      
      let managedContext = DataManager.sharedManager.persistentContainer.viewContext
      
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: StringTable.ENTITYNAME)
      
      do {
        let obj = try managedContext.fetch(fetchRequest)
        return obj as? [ExchangeRate]
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
        return nil
      }
    }
    
    func deleteExchangeRate(excRate : ExchangeRate){
      
        let managedContext = DataManager.sharedManager.persistentContainer.viewContext
        do {
            managedContext.delete(excRate)
        } catch {
            print(error)
        }
      
        do {
            try managedContext.save()
        } catch {
            
        }
    }
    
    func deleteExchangeRateWith(code : String){
      
        let list = DataManager.sharedManager.fetchAllExchangeRates()
        let filtered = list!.filter{ ($0 as! ExchangeRate).code! == code } as NSArray
        for obj in filtered{
            let excRate = obj as! ExchangeRate
            deleteExchangeRate(excRate: excRate)
        }
    }
    
}
