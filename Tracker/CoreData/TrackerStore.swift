//
//  TrackerStore.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: TrackerStore)
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()
    
    override init() {
        self.context = CoreDataStack.shared.context
        super.init()
        
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка первичного performFetch в TrackerStore: \(error)")
        }
    }
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func headerTitleInSection(_ section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return try? tracker(from: trackerCoreData)
    }
    
    func filterTrackers(for weekday: WeekDay) {
        let weekdayString = String(weekday.rawValue)
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "schedule CONTAINS %@", weekdayString
        )
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка фильтрации в TrackerStore: \(error)")
        }
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let emoji = trackerCoreData.emoji,
              let colorString = trackerCoreData.color,
              let scheduleString = trackerCoreData.schedule else {
            throw NSError(domain: "TrackerStoreError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось прочитать поля из Core Data"])
        }
        
        let color = UIColor.fromColorString(colorString)
        let schedule = ScheduleConverter.toSet(scheduleString)
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    func createTracker(_ tracker: Tracker, toCategoryTitle categoryTitle: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        
        trackerCoreData.color = tracker.color.toColorString
        trackerCoreData.schedule = ScheduleConverter.toString(tracker.schedule)
        
        let categoryStore = TrackerCategoryStore()
        let categoryCoreData = try categoryStore.fetchOrCreateCategory(with: categoryTitle)
        
        trackerCoreData.category = categoryCoreData
        
        CoreDataStack.shared.saveContext()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}
