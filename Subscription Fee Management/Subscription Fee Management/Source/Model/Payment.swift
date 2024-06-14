//
//  Payment.swift
//  Subscription Fee Management
//
//  Created by S.Top on 5/22/24.
//

import Foundation
import CoreData

// 결제 방법 모델
struct Payment {
    enum method: String, Decodable, RawRepresentable, CaseIterable {
        case account = "계좌", card = "카드", payservice = "간편 결제"
    }
    
    let id: UUID
    var name: String
    var pay: method
    var order: Int
    
    init(id: UUID = UUID(), name: String, pay: method, order: Int = 0) {
        self.id = id
        self.name = name
        self.pay = pay
        self.order = order
    }
    
    init(cdPayment: CDPayment) {
        self.id = cdPayment.id!
        self.name = cdPayment.name!
        self.pay = method(rawValue: cdPayment.pay!)!
        self.order = Int(cdPayment.order)
    }
    
    func toCDPayment(context: NSManagedObjectContext) -> CDPayment {
        let cdPayment = CDPayment(context: context)
        
        cdPayment.id = self.id
        cdPayment.name = self.name
        cdPayment.pay = self.pay.rawValue
        cdPayment.order = Int32(self.order)
        
        return cdPayment
    }
}

let paymentSamples = [
    Payment(id: UUID(uuidString: "A9A6E3F7-3422-4F90-9A79-EC98F59DCDB3") ?? UUID(), name: "하나 계좌", pay: Payment.method.account),
    Payment(id: UUID(uuidString: "6E0EF09B-94FD-4918-A7B7-52BC41A9B187") ?? UUID(), name: "국민 카드", pay: Payment.method.card),
    Payment(id: UUID(uuidString: "81DD1A61-B8FD-4A4D-9851-B7A2F9DF6BA9") ?? UUID(), name: "카카오페이", pay: Payment.method.payservice)
]

extension Payment: Decodable {}
extension Payment: Identifiable {}
