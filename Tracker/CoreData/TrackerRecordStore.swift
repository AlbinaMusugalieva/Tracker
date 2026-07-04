//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Albina Musugalieva.
//

import Foundation
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init() {
        self.context = CoreDataStack.shared.context
    }
    
    func addRecord(with id: UUID, date: Date) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = id
        recordCoreData.date = Calendar.current.startOfDay(for: date)
        
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let trackerCoreData = try context.fetch(request).first {
            recordCoreData.tracker = trackerCoreData
        }
        
        CoreDataStack.shared.saveContext()
    }
    
    func removeRecord(with id: UUID, date: Date) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        let targetDate = Calendar.current.startOfDay(for: date)
        
        request.predicate = NSPredicate(format: "id == %@ AND date == %@", id as CVarArg, targetDate as NSDate)
        
        if let recordToDelete = try context.fetch(request).first {
            context.delete(recordToDelete)
            CoreDataStack.shared.saveContext()
        }
    }
    
    func fetchRecords() throws -> Set<TrackerRecord> {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let recordsCoreData = try context.fetch(request)
        
        let records = recordsCoreData.compactMap { recordCoreData -> TrackerRecord? in
            guard let id = recordCoreData.id, let date = recordCoreData.date else { return nil }
            return TrackerRecord(trackerId: id, date: date)
        }
        
        return Set(records)
    }
}
