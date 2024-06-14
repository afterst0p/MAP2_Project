//
//  SubscriptionList.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/7/24.
//

import SwiftUI
import CoreData

// 구독 정보들을 모으는 뷰모델
class SubscriptionList: ObservableObject {
    private var viewContext: NSManagedObjectContext
    
    @Published var subscriptions : [Subscription] = []

    // 프로젝트에 포함된 json 파일, 수정 불가
//    init(filename: String = "SubscriptionData.json") {
//        self.subscriptions = Bundle.main.decode(filename: filename, as: [Subscription].self)
//    }
    
    init(context: NSManagedObjectContext = PersistenceController.shared.context) {
        self.viewContext = context
        fetch()
    }
    
    func fetch() {
        let request: NSFetchRequest<CDSubscription> = CDSubscription.fetchRequest()
        do {
            let cdSubscriptions = try viewContext.fetch(request)
            subscriptions = cdSubscriptions.map { Subscription(cdSubscription: $0) }
        } catch {
            print("Core Data에서 Subscription 불러오기 실패")
        }
    }
    
    func add(subscription: Subscription) {
        let cdSubscription = subscription.toCDSubscription(context: viewContext)
        saveContext()
    }
    
    func update(uuidString: String, subscription: Subscription) {
        let updateName: String
        
        // ViewModel에서 수정
        if let index = subscriptions.firstIndex(where: { $0.id.uuidString == uuidString }) {
            updateName = subscriptions[index].name
            //subscriptions[index] = subscription
        } else {
            updateName = ""
        }
        
        // Core Data에서 수정
        if !updateName.isEmpty {
            let request: NSFetchRequest<CDSubscription> = CDSubscription.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", updateName as CVarArg)
            
            do {
                let cdSubscriptions = try viewContext.fetch(request)
                if let cdSubscription = cdSubscriptions.first {
                    cdSubscription.name = subscription.name
                    cdSubscription.yearly = subscription.yearly
                    cdSubscription.price = Int32(subscription.price)
                    cdSubscription.payDate = Calendar.current.date(from: subscription.payDate) ?? Date()
                    cdSubscription.categoryID = subscription.categoryID
                    cdSubscription.paymentID = subscription.paymentID
                    
                    saveContext()
                }
            } catch {
                print("Core Data에 Subscription 수정 실패: \(error)")
            }
        }
    }
    
    func delete(subscription: Subscription) {
        let deleteName = subscription.name
        
        // ViewModel에서 삭제
        //subscriptions.removeAll { $0.id == subscription.id }
        
        // Core Data에서 삭제
        let request: NSFetchRequest<CDSubscription> = CDSubscription.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", deleteName as CVarArg)
        
        do {
            let cdSubscriptions = try viewContext.fetch(request)
            if let cdSubscription = cdSubscriptions.first {
                viewContext.delete(cdSubscription)
                saveContext()
            }
        } catch {
            print("Core Data에 Subscription 삭제 실패: \(error)")
        }
    }
    
    func saveContext() {
        do {
            try viewContext.save()
            fetch()
        } catch {
            print("Core Data에 Subscription 저장 실패")
        }
    }
    
    func isDuplicate(name: String) -> Bool {
        subscriptions.contains { $0.name == name }
    }
    
    func isDuplicate(name: String, uuidString: String) -> Bool {
        subscriptions.contains { $0.name == name && $0.id.uuidString != uuidString }
    }
}
