//
//  SubscriptionList.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/7/24.
//

import SwiftUI
import CoreData
import UserNotifications

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
        
        if UserDefaults.standard.bool(forKey: "alertService") {
            enablePayDateAlert()
        }
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
                    
                    if UserDefaults.standard.bool(forKey: "alertService") {
                        enablePayDateAlert()
                    }
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
                
                if UserDefaults.standard.bool(forKey: "alertService") {
                    enablePayDateAlert()
                }
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
    
    func usePayDateAlert(enabled: Bool) {
        if enabled {
            enablePayDateAlert()
        } else {
            disablePayDateAlert()
        }
    }

    private func enablePayDateAlert() {
        let center = UNUserNotificationCenter.current()
        
        // 알림 권한 없으면 요청
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted == true && error == nil {
                // 알림 권한 획득
            }
        }
        
        // 기존 알림 요청 지우기
        center.removeAllPendingNotificationRequests()
        
        for subscription in subscriptions {
            var triggerDateComponents = DateComponents()
            triggerDateComponents.hour = 8 // 알림 시간, 오전 8시
            
            // 월간, 연간 구독 구분
            if subscription.yearly {
                triggerDateComponents.month = subscription.payDate.month
                triggerDateComponents.day = subscription.payDate.day
            } else {
                triggerDateComponents.day = subscription.payDate.day
            }
            
            // 현재를 기준으로 알림의 트리거 날짜 설정
            if let date = Calendar.current.date(from: triggerDateComponents) {
                let content = UNMutableNotificationContent()
                content.title = "구독 결제일 알림"
                content.body = "\(subscription.name) 구독료 \(subscription.price)원이 결제될 예정입니다."
                content.sound = UNNotificationSound.default
                
                let trigger: UNCalendarNotificationTrigger
                if subscription.yearly {
                    trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: true)
                } else {
                    trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: true)
                }
                let request = UNNotificationRequest(identifier: subscription.id.uuidString, content: content, trigger: trigger)
                
                center.add(request) { error in
                    if let error = error {
                        print("알림 요청 실패: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // 알림 등록 디버깅
//        center.getPendingNotificationRequests { requests in
//            for request in requests {
//                print("알림 ID: \(request.identifier)")
//                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
//                    print("알림 시간: \(trigger.dateComponents)")
//                }
//                print("알림 내용: \(request.content.title) - \(request.content.body)")
//            }
//        }
        
        // UserDefault에 알림 활성화 여부 저장
        UserDefaults.standard.set(true, forKey: "alertService")
    }
    
    private func disablePayDateAlert() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // UserDefault에 알림 활성화 여부 저장
        UserDefaults.standard.set(false, forKey: "alertService")
    }
    
    func isDuplicate(name: String) -> Bool {
        subscriptions.contains { $0.name == name }
    }
    
    func isDuplicate(name: String, uuidString: String) -> Bool {
        subscriptions.contains { $0.name == name && $0.id.uuidString != uuidString }
    }
}
