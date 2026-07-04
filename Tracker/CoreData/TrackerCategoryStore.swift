//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import CoreData
import UIKit

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init() {
        self.context = CoreDataStack.shared.context
    }
    
    func fetchOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", title)
        
        let categories = try context.fetch(request)
        
        if let existingCategory = categories.first {
            return existingCategory
        }
        
        let newCategoryCoreData = TrackerCategoryCoreData(context: context)
        newCategoryCoreData.title = title
        
        CoreDataStack.shared.saveContext()
        return newCategoryCoreData
    }
}
