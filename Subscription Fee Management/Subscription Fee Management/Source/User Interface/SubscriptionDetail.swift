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
    @State private var showDeleteAlert = false
    
    init(subscriptionList: SubscriptionList, subscription: Subscription, category: CustomCategory?, payment: Payment?) {
        self.subscriptionList = subscriptionList
        self.subscription = subscription
        self.category = category
        self.payment = payment
        
        let calendar = Calendar.current
        let date = calendar.date(from: subscription.payDate)
        let dateFormatter: DateFormatter = DateFormatter()
        
        let numterFormatter = NumberFormatter()
        numterFormatter.numberStyle = .decimal
        numterFormatter.locale = Locale(identifier: "es_MX")
        price = numterFormatter.string(for: subscription.price)!
        
        switch subscription.yearly {
        case false:
            dateFormatter.dateFormat = "d 일"
        case true:
            dateFormatter.dateFormat = "M 월 d 일"
        }
        
        dateString = dateFormatter.string(from: date!)
    }
    
    var body: some View {
        List {
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
            }
            Section(header: Text("부가 정보")) {
                HStack {
                    Text("카테고리").foregroundStyle(.gray)
                    Spacer()
                    Text(category?.name ?? "없음")
                }
                HStack {
                    Text("결제 수단 유형").foregroundStyle(.gray)
                    Spacer()
                    Text(payment?.pay.rawValue ?? "없음")
                }
                HStack {
                    Text("결제 수단 이름").foregroundStyle(.gray)
                    Spacer()
                    Text(payment?.name ?? "없음")
                }
            }
            Section {
                Button(action: editSubscription) {
                    Text("구독 수정")
                        .frame(maxWidth: .infinity)
                }
            }
            Section {
                Button(action: { self.showDeleteAlert = true }) {
                    Text("구독 삭제")
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                }
                .alert(isPresented: $showDeleteAlert){
                    Alert(
                        title: Text("정말 삭제하시겠습니까?"),
                        message: Text("이 작업은 되돌릴 수 없습니다."),
                        primaryButton: .destructive(Text("삭제"), action: {
                            deleteSubscription()
                        }),
                        secondaryButton: .cancel(Text("취소"))
                    )
                }
            }
        }
        .navigationTitle(subscription.name)
    }
    
    func editSubscription() {
        
    }
    
    func deleteSubscription() {
        subscriptionList.delete(subscription: subscription)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    SubscriptionDetail(subscriptionList: SubscriptionList(), subscription: subscriptionSample[0], category: categorySamples[0], payment: paymentSamples[0])
}
