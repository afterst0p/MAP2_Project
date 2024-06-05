//
//  Subscription.swift
//  Subscription Fee Management
//
//  Created by S.Top on 5/22/24.
//

import Foundation

// 구독 정보 구조체
struct Subscription {
    let id: UUID = UUID()
    var name: String
    var yearly: Bool
    var price: Int
    var payDate: DateComponents
    var categoryID: String?
    var paymentID: String?
    
    init(name: String, yearly: Bool, price: Int, payDate: DateComponents, categoryID: String? = nil, paymentID: String? = nil) {
        self.name = name
        self.yearly = yearly
        self.price = price
        self.payDate = payDate
        if let categoryID = categoryID, !categoryID.isEmpty {
            self.categoryID = categoryID
        } else {
            self.categoryID = nil
        }
        if let paymentID = paymentID, !paymentID.isEmpty {
            self.paymentID = paymentID
        } else {
            self.paymentID = nil
        }
    }
}

// 구독 정보들을 모으는 클래스
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


let subscriptionSample = [
    Subscription(name: "스포티파이", yearly: false, price: 12000, payDate: DateComponents(day: 28), categoryID: "3B34D425-6C38-4FC9-A59E-8B71F62492C6", paymentID: "A9A6E3F7-3422-4F90-9A79-EC98F59DCDB3"),
    Subscription(name: "유튜브", yearly: false, price: 14000, payDate: DateComponents(day: 15), categoryID: "72B527C5-907F-4A22-B51D-832634BF86B3", paymentID: "6E0EF09B-94FD-4918-A7B7-52BC41A9B187"),
    Subscription(name: "네이버 맴버십", yearly: true, price: 12000, payDate: DateComponents(month: 4, day: 28), categoryID: "E708C03A-F4F2-4B54-8362-541F4C7B5E5B", paymentID: "81DD1A61-B8FD-4A4D-9851-B7A2F9DF6BA9")
]

extension Subscription: Decodable {}
extension Subscription: Identifiable {}
