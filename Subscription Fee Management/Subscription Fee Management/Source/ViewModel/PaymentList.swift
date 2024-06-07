//
//  PaymentList.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/7/24.
//

import Foundation


// 결제 수단을 모으는 뷰모델
class PaymentList: ObservableObject {
    @Published var payments : [Payment]
    
    init(filename: String = "PaymentData.json") {
        self.payments = Bundle.main.decode(filename: filename, as: [Payment].self)
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
        payments.contains { $0.name == name } && payments.contains { $0.pay == pay }
    }
}
