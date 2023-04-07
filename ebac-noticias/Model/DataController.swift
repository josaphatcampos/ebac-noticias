//
//  DataController.swift
//  ebac-noticias
//
//  Created by Josaphat Campos Pereira on 07/04/23.
//

import Foundation
import CoreData

class DataController{
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func loadData(completion: (() -> Void)? = nil){
        persistentContainer.loadPersistentStores{ storeDescription, error in
            guard error == nil else {
                print("error: \(String(describing: error?.localizedDescription))")
                return
            }
            
            completion?()
        }
    }
}
