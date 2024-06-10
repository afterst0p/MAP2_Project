//
//  PaymentList.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/7/24.
//

import SwiftUI


// 결제 수단을 모으는 뷰모델
class PaymentList: ObservableObject {
    @Published var payments : [Payment]
    
    init(filename: String = "PaymentData.json") {
        self.payments = Bundle.main.decode(filename: filename, as: [Payment].self)
    }
    
    func update(uuidString: String, name: String) {
        if let index = payments.firstIndex(where: { $0.id.uuidString == uuidString }) {
            payments[index].name = name
        }
    }
    
    func getPaymentByUUID(uuidString: String?) -> Payment? {
        guard let uuidStringUnwrapped = uuidString else {
                    return nil
            }
        guard let uuid = UUID(uuidString: uuidStringUnwrapped) else {
                    return nil
            }
        return payments.first { $0.id == uuid }
    }
    
    func getPaymentIdString(name: String, pay: Payment.method) -> String {
        let find = payments.first { $0.name == name && $0.pay == pay }
        return find?.id.uuidString ?? ""
    }
    
    func isDuplicate(name: String, pay: Payment.method) -> Bool {
        payments.contains { $0.name == name && $0.pay == pay }
    }
    
    func isDuplicate(name: String, pay: Payment.method, uuidString: String) -> Bool {
        payments.contains { $0.name == name && $0.pay == pay && $0.id.uuidString != uuidString }
    }
}
