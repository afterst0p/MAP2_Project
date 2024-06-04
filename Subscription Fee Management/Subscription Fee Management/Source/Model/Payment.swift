//
//  Payment.swift
//  Subscription Fee Management
//
//  Created by S.Top on 5/22/24.
//

import Foundation

// 결제 방법 구조체
struct Payment {
    enum method: String, Decodable {
        case account = "계좌", card = "카드", payservice = "간편 결제"
    }
    
    let id: UUID
    var name: String
    var pay: method
    
    init(id: UUID = UUID(), name: String, pay: method) {
        self.id = id
        self.name = name
        self.pay = pay
    }
}

// 결제 수단을 모으는 클래스
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
    
    func isDuplicate(name: String, pay: Payment.method) -> Bool {
        payments.contains { $0.name == name } && payments.contains { $0.pay == pay }
    }
}


let paymentSamples = [
    Payment(id: UUID(uuidString: "A9A6E3F7-3422-4F90-9A79-EC98F59DCDB3") ?? UUID(), name: "하나 계좌", pay: Payment.method.account),
    Payment(id: UUID(uuidString: "6E0EF09B-94FD-4918-A7B7-52BC41A9B187") ?? UUID(), name: "국민 카드", pay: Payment.method.card),
    Payment(id: UUID(uuidString: "81DD1A61-B8FD-4A4D-9851-B7A2F9DF6BA9") ?? UUID(), name: "카카오페이", pay: Payment.method.payservice)
]

extension Payment: Decodable {}
extension Payment: Identifiable {}
