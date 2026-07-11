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
                NSSortDescriptor(key: "isPinned", ascending: false),
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
        guard let sections = fetchedResultsController.sections,
                  section < sections.count,
                  let firstObject = sections[section].objects?.first as? TrackerCoreData else {
                return nil
            }
            
            if firstObject.isPinned {
                return "Закрепленные"
            }
            
            return sections[section].name
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return try? tracker(from: trackerCoreData)
    }
    
    func filterTrackers(for weekday: WeekDay, filter: TrackerFilter, completedIds: Set<UUID>) {
        let weekdayString = String(weekday.rawValue)
        
        var predicates: [NSPredicate] = [
            NSPredicate(format: "schedule CONTAINS %@", weekdayString)
        ]
        
        switch filter {
        case .all, .today:
            break
        case .completed:
            predicates.append(NSPredicate(format: "id IN %@", completedIds))
        case .uncompleted:
            predicates.append(NSPredicate(format: "NOT (id IN %@)", completedIds))
        }
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
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
              let scheduleString = trackerCoreData.schedule
              else {
            throw NSError(domain: "TrackerStoreError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось прочитать поля из Core Data"])
        }
        let isPinned = trackerCoreData.isPinned
        let color = UIColor.fromColorString(colorString)
        let schedule = ScheduleConverter.toSet(scheduleString)
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: isPinned
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
    
    func deleteTracker(at indexPath: IndexPath) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
            context.delete(trackerCoreData)
            CoreDataStack.shared.saveContext()
    }
    
    func togglePinTracker(at indexPath: IndexPath) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
            trackerCoreData.isPinned = !trackerCoreData.isPinned
            CoreDataStack.shared.saveContext()
    }
    
    func updateTracker(_ updatedTracker: Tracker, oldCategory: String, newCategory: String) throws {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "id == %@", updatedTracker.id as CVarArg)
        
        let results = try context.fetch(request)
        guard let trackerCoreData = results.first else { return }
        
        trackerCoreData.name = updatedTracker.name
        trackerCoreData.emoji = updatedTracker.emoji
        trackerCoreData.color = updatedTracker.color.toColorString
        trackerCoreData.schedule = ScheduleConverter.toString(updatedTracker.schedule)
        
        if oldCategory != newCategory {
            let categoryStore = TrackerCategoryStore()
            let newCategoryCoreData = try categoryStore.fetchOrCreateCategory(with: newCategory)
            trackerCoreData.category = newCategoryCoreData
        }
        
        CoreDataStack.shared.saveContext()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}
