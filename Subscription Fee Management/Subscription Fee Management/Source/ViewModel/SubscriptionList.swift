//
//  SubscriptionList.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/7/24.
//

import Foundation

// 구독 정보들을 모으는 뷰모델
class SubscriptionList: ObservableObject {
    @Published var subscriptions : [Subscription]
    
    init(filename: String = "SubscriptionData.json") {
        self.subscriptions = Bundle.main.decode(filename: filename, as: [Subscription].self)
    }
    
    func update(uuidString: String, subscription: Subscription) {
        if let index = subscriptions.firstIndex(where: { $0.id.uuidString == uuidString }) {
            subscriptions[index] = subscription
        }
    }
    
    func delete(subscription: Subscription) {
        subscriptions.removeAll { $0.id == subscription.id }
    }
    
    func isDuplicate(name: String) -> Bool {
        subscriptions.contains { $0.name == name }
    }
    
    func isDuplicate(name: String, uuidString: String) -> Bool {
        subscriptions.contains { $0.name == name && $0.id.uuidString != uuidString }
    }
}
