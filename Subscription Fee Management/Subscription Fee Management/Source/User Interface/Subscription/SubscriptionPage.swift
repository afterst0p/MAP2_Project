//
//  ContentView.swift
//  Subscription Fee Management
//
//  Created by S.Top on 5/22/24.
//

import SwiftUI

struct SubscriptionPage: View {
    @ObservedObject var subscriptionList: SubscriptionList
    @ObservedObject var categoryList: CustomCategoryList
    @ObservedObject var paymentList: PaymentList
    
    @State private var stackPath = NavigationPath()
    @State private var selectedSortMethod = sortMethod.allCases.first
    @State private var selectedCategoryId = ""
    @State private var selectedPaymentPay: Payment.method?
    @State private var selectedPaymentId = ""
    @State private var isUsingShowingOption = false
    @State private var isAddingSubscription = false
    
    var body: some View {
        NavigationStack(path: $stackPath) {
            List {
                subscriptionFilter
                ForEach(subscriptionList.subscriptions.sorted(by: sortSelect()), id: \.self) { subscription in
                    if (filterSelect(subscription: subscription)) {
                        ZStack {
                            ListCell(subscription: subscription,
                                     category: categoryList.getCategoryByUUID(uuidString: subscription.categoryID),
                                     payment: paymentList.getPaymentByUUID(uuidString: subscription.paymentID)
                            )
                            NavigationLink(value: subscriptionList.subscriptions.firstIndex(where: { $0.id == subscription.id })!) {
                                EmptyView()
                            }
                            .opacity(0)
                        }
                    }
                }
            }
            .navigationDestination(for: Int.self) { i in
                SubscriptionDetail(subscriptionList: subscriptionList,
                                   categoryList: categoryList,
                                   paymentList: paymentList,
                                   subscription: subscriptionList.subscriptions[i],
                                   category: categoryList.getCategoryByUUID(uuidString: subscriptionList.subscriptions[i].categoryID),
                                   payment: paymentList.getPaymentByUUID(uuidString: subscriptionList.subscriptions[i].paymentID))
            }
            .navigationBarTitle("구독 목록")
            .navigationBarItems(trailing: Button(action: {
                isAddingSubscription = true
            }) {
                Text("추가")
            })
            .sheet(isPresented: $isAddingSubscription) {
                SubscriptionAdd(subscriptionList: subscriptionList,
                                categoryList: categoryList,
                                paymentList: paymentList)
            }
            .contentMargins(.top, 20)
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
            dateFormatter.dateFormat = "매월 d일"
        case true:
            dateFormatter.dateFormat = "매년 M월 d일"
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

extension SubscriptionPage {
    enum sortMethod: String, CaseIterable {
        case nameUp = "가나다순", nameDown = "가나다 역순", priceUp = "낮은 가격순", priceDown = "높은 가격순"
    }
    
    func sortSelect() -> (Subscription, Subscription) -> Bool {
        switch (selectedSortMethod) {
        case .nameUp:
            return { $0.name < $1.name }
        case .nameDown:
            return { $0.name > $1.name }
        case.priceUp:
            return { $0.price < $1.price }
        case.priceDown:
            return { $0.price > $1.price }
        case .none:
            return { $0.name < $1.name }
        }
        
    }
    
    func filterSelect(subscription: Subscription) -> Bool {
        // 보기 조건 설정 꺼져있을 때 통과
        if (!isUsingShowingOption) {
            return true
        }
        // 카테고리 불일치 시 제외
        if (!selectedCategoryId.isEmpty && selectedCategoryId != subscription.categoryID) {
            return false
        }
        // 결제 수단 유형 불일치 시 제외
        if (selectedPaymentPay != nil && selectedPaymentPay != paymentList.getPaymentByUUID(uuidString: subscription.paymentID)?.pay) {
            return false
        }
        // 결제 수단 이름 불일치 시 제외
        if (!selectedPaymentId.isEmpty && selectedPaymentId != subscription.paymentID) {
            return false
        }
        // 나머지 통과
        return true
    }
    
    var subscriptionFilter: some View {
        Section {
            Picker("정렬", selection: $selectedSortMethod) {
                ForEach(sortMethod.allCases, id: \.self) { method in
                    Text(method.rawValue).tag(method as sortMethod?)
                }
            }
            .pickerStyle(.menu)
            Toggle(isOn: $isUsingShowingOption) {
                Text("보기 조건 설정")
            }
            if (isUsingShowingOption) {
                Picker("카테고리", selection: $selectedCategoryId) {
                    Text("( 미지정 )").tag("")
                    ForEach(categoryList.customCategories, id: \.id) { category in
                        Text(category.name).tag(category.id.uuidString)
                    }
                }
                .pickerStyle(.menu)
                Picker("결제 수단 유형", selection: $selectedPaymentPay) {
                    Text("( 미지정 )").tag(nil as Payment.method?)
                    ForEach(Payment.method.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(method as Payment.method?)
                    }
                }
                .pickerStyle(.menu)
                if (selectedPaymentPay != nil) {
                    Picker("결제 수단 이름", selection: $selectedPaymentId) {
                        Text("( 미지정 )").tag("")
                        ForEach(paymentList.payments, id: \.id) { payment in
                            if (selectedPaymentPay == payment.pay) {
                                Text(payment.name).tag(payment.id.uuidString)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }
}

#Preview {
    SubscriptionPage(subscriptionList: SubscriptionList(), categoryList: CustomCategoryList(), paymentList: PaymentList())
}
