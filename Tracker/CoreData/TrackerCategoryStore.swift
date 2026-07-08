//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidUpdate()
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    override init() {
        self.context = CoreDataStack.shared.context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        self.fetchedResultsController = controller
        
        try? controller.performFetch()
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        guard let coreDataCategories = fetchedResultsController?.fetchedObjects else { return [] }
        
        return coreDataCategories.compactMap { coreDataCategory in
            guard let title = coreDataCategory.title else { return nil }
            return TrackerCategory(title: title, trackers: [])
        }
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

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate()
    }
}
