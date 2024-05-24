//
//  ContentView.swift
//  Subscription Fee Management
//
//  Created by S.Top on 5/22/24.
//

import SwiftUI

struct SubscriptionPage: View {
    @StateObject var subscriptionList: SubscriptionList
    @StateObject var categoryList: CustomCategoryList
    @StateObject var paymentList: PaymentList
    @State private var stackPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $stackPath) {
            List {
                ForEach(0..<subscriptionList.subscriptions.count, id: \.self) { i in
                    ZStack {
                        ListCell(subscription: subscriptionList.subscriptions[i], 
                                 category: categoryList.getCategoryByUUID(uuidString: subscriptionList.subscriptions[i].categoryID),
                                 payment: paymentList.getPaymentByUUID(uuidString: subscriptionList.subscriptions[i].paymentID)
                        )
                        NavigationLink(value: i) {
                            EmptyView()
                        }
                        .opacity(0)
                    }
                }
            }
            .navigationDestination(for: Int.self) { i in
                SubscriptionDetail(subscriptionList: subscriptionList,
                                   subscription: subscriptionList.subscriptions[i],
                                   category: categoryList.getCategoryByUUID(uuidString: subscriptionList.subscriptions[i].categoryID),
                                   payment: paymentList.getPaymentByUUID(uuidString: subscriptionList.subscriptions[i].paymentID))
            }
            .navigationDestination(for: String.self) { _ in
                SubscriptionAdd(subscriptionList: subscriptionList,
                                categoryList: categoryList,
                                paymentList: paymentList,
                                path: $stackPath)
            }
            .navigationBarTitle(Text("구독 목록"))
            .navigationBarItems(trailing: NavigationLink(
                value: "Add", 
                label: {
                    Text("구독 추가")
                }
            ))
        }
    }
}

struct ListCell: View {
    var subscription: Subscription
    var category: CustomCategory?
    var payment: Payment?
    let price: String
    let dateString: String
    
    init (subscription: Subscription, category: CustomCategory?, payment: Payment?) {
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
            dateFormatter.dateFormat = "매월 dd일"
        case true:
            dateFormatter.dateFormat = "매년 MM월 dd일"
        }
        
        dateString = dateFormatter.string(from: date!)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(subscription.name).font(.title2).bold()
                Spacer()
                Text(category?.name ?? "").foregroundStyle(Color.gray)
            }
            Spacer()
            HStack {
                Text(dateString)
                Spacer()
                Text(price + "원")
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    SubscriptionPage(subscriptionList: SubscriptionList(), categoryList: CustomCategoryList(), paymentList: PaymentList())
}
