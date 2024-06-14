//
//  PaymentList.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/7/24.
//

import SwiftUI
import CoreData


// 결제 수단을 모으는 뷰모델
class PaymentList: ObservableObject {
    private var viewContext: NSManagedObjectContext
    
    @Published var payments : [Payment] = []
    
    // 프로젝트에 포함된 json 파일, 수정 불가
//    init(filename: String = "PaymentData.json") {
//        self.payments = Bundle.main.decode(filename: filename, as: [Payment].self)
//    }
    
    init(context: NSManagedObjectContext = PersistenceController.shared.context) {
        self.viewContext = context
        fetch()
    }
    
    func fetch() {
        let request: NSFetchRequest<CDPayment> = CDPayment.fetchRequest()
        do {
            let cdPayments = try viewContext.fetch(request)
            payments = cdPayments.map { Payment(cdPayment: $0) }
        } catch {
            print("Core Data에서 Payment 불러오기 실패")
        }
    }
    
    func add(payment: Payment) {
        let cdPayment = payment.toCDPayment(context: viewContext)
        saveContext()
    }
    
    func update(uuidString: String, name: String) {
        let request: NSFetchRequest<CDPayment> = CDPayment.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", uuidString as CVarArg)
        
        do {
            let cdPayments = try viewContext.fetch(request)
            if let cdPayment = cdPayments.first {
                cdPayment.name = name
                
                saveContext()
            }
        } catch {
            print("Core Data에 Payment 수정 실패: \(error)")
        }
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            let payment = payments[index]
            let request: NSFetchRequest<CDPayment> = CDPayment.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", payment.id as CVarArg)
            
            do {
                let cdPayments = try viewContext.fetch(request)
                if let cdPayment = cdPayments.first {
                    viewContext.delete(cdPayment)
                    saveContext()
                }
            } catch {
                print("Core Data에 Payment 삭제 실패: \(error)")
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        payments.move(fromOffsets: source, toOffset: destination)
        saveContext()
    }
    
    func saveContext() {
        do {
            try viewContext.save()
            fetch()
        } catch {
            print("Core Data에 Payment 저장 실패")
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
