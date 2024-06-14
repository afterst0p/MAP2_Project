//
//  PersistenceController.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/14/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "SubscriptionDataModel")
        
        // Apple Development Program 가입 필요
//        guard let description = container.persistentStoreDescriptions.first else {
//            fatalError("No Descriptions found")
//        }
//        
//        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
//        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.yourdomain.SubscriptionDataModel")

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Container load failed: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
}

