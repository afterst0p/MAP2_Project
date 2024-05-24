//
//  SubscriptionDetail.swift
//  Subscription Fee Management
//
//  Created by S.Top on 5/23/24.
//

import SwiftUI

struct SubscriptionDetail: View {
    @ObservedObject var subscriptionList: SubscriptionList
    @Environment(\.presentationMode) var presentationMode
    let subscription: Subscription
    let category: CustomCategory?
    let payment: Payment?
    var price: String
    var dateString: String
    
    init(subscriptionList: SubscriptionList, subscription: Subscription, category: CustomCategory?, payment: Payment?) {
        self.subscriptionList = subscriptionList
        self.subscription = subscription
        self.category = category
        self.payment = payment
        
        let numterFormatter = NumberFormatter()
        let calendar = Calendar.current
        let date = calendar.date(from: subscription.payDate)
        let dateFormatter: DateFormatter = DateFormatter()
        
        numterFormatter.numberStyle = .decimal
        numterFormatter.locale = Locale(identifier: "es_MX")
        price = numterFormatter.string(for: subscription.price)!
        
        switch subscription.yearly {
        case false:
            dateFormatter.dateFormat = "dd 일"
        case true:
            dateFormatter.dateFormat = "MM 월 dd 일"
        }
        
        dateString = dateFormatter.string(from: date!)
    }
    
    var body: some View {
        Form {
            Section(header: Text("구독 정보")) {
                HStack {
                    Text("구독 유형").foregroundStyle(.gray)
                    Spacer()
                    Text(subscription.yearly ? "연간 구독" : "월간 구독")
                }
                HStack {
                    Text("결제일").foregroundStyle(.gray)
                    Spacer()
                    Text(dateString)
                }
                HStack {
                    Text("구독료").foregroundStyle(.gray)
                    Spacer()
                    Text(price + " 원")
                }
                HStack {
                    Text("카테고리").foregroundStyle(.gray)
                    Spacer()
                    Text(category?.name ?? "없음")
                }
                HStack {
                    Text("결제 수단").foregroundStyle(.gray)
                    Spacer()
                    Text(payment?.name ?? "없음")
                }
                HStack {
                    Text("결제 유형").foregroundStyle(.gray)
                    Spacer()
                    Text(payment?.pay.rawValue ?? "없음")
                }
            }
            Button(action: deleteSubscription) {
                Text("구독 삭제")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(subscription.name)
    }
    
    func deleteSubscription() {
        subscriptionList.delete(subscription: subscription)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    SubscriptionDetail(subscriptionList: SubscriptionList(), subscription: subscriptionSample[0], category: categorySamples[0], payment: paymentSamples[0])
}
