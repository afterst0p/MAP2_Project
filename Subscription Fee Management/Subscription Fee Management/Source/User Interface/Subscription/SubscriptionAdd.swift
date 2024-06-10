//
//  SubscriptionAdd.swift
//  Subscription Fee Management
//
//  Created by S.Top on 5/24/24.
//

import SwiftUI
import Combine

struct SubscriptionAdd: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var subscriptionList: SubscriptionList
    @ObservedObject var categoryList: CustomCategoryList
    @ObservedObject var paymentList: PaymentList
    @State private var name: String = ""
    @State private var payDay: Int = 1
    @State private var payMonth: Int = 1
    @State private var isYearly: Bool = false
    @State private var priceString: String = ""
    @State private var categoryId: String = ""
    @State private var paymentPay: Payment.method? = nil
    @State private var paymentId: String = ""
    
    @State private var newCategoryName: String = ""
    @State private var newPaymentName: String = ""
    
    @State private var showWrongInputAlert = false
    @State private var showCategoryInputAlert = false
    @State private var showWrongCategoryInputAlert = false
    @State private var showPaymentInputAlert = false
    @State private var showWrongPaymentInputAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            List {
                necessaryInformation
                additionalInformation
                addButton
            }
            .navigationBarTitle("구독 추가")
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("취소")
            })
        }
    }
    
    var necessaryInformation: some View {
        Section(header: Text("필수 정보 입력")) {
            VStack(alignment: .leading) {
                Text("서비스 이름")
                TextField("서비스 이름을 입력해 주세요.", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Toggle(isOn: $isYearly) {
                Text("연간 구독")
            }
            
            if (isYearly) {
                HStack {
                    Text("결제월")
                    Picker("", selection: $payMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text("\(month) 월").font(.title3).tag(month)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            
            HStack {
                Text("결제일")
                if (isYearly) {
                    if (payMonth == 2) {
                        Picker("", selection: $payDay) {
                            ForEach(1...29, id: \.self) { day in
                                Text("\(day) 일").font(.title3).tag(day)
                            }
                        }
                        .pickerStyle(.menu)
                    } else if ([4, 6, 9, 11].contains(payMonth)) {
                        Picker("", selection: $payDay) {
                            ForEach(1...30, id: \.self) { day in
                                Text("\(day) 일").font(.title3).tag(day)
                            }
                        }
                        .pickerStyle(.menu)
                    } else {
                        Picker("", selection: $payDay) {
                            ForEach(1...31, id: \.self) { day in
                                Text("\(day) 일").font(.title3).tag(day)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } else {
                    Picker("", selection: $payDay) {
                        ForEach(1...31, id: \.self) { day in
                            Text("\(day) 일").font(.title3).tag(day)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            
            HStack {
                Text("구독료")
                TextField("구독료를 입력해 주세요.", text: $priceString)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .onReceive(Just(priceString)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.priceString = filtered
                        }
                        
                        // 3자리 마다 , 붙이기 // 뒤로가기 시 앱 멈춤
                        //                            if let number = NumberFormatter().number(from: filtered) {
                        //                                let formatter = NumberFormatter()
                        //                                formatter.numberStyle = .decimal
                        //                                if let formattedString = formatter.string(from: number) {
                        //                                    self.priceString = formattedString
                        //                                }
                        //                            }
                    }
                Text("원")
            }
        }
    }
    
    var additionalInformation: some View {
        Section(header: Text("부가 정보 입력")) {
            VStack {
                Picker("카테고리", selection: $categoryId) {
                    Text("( 미지정 )").tag("")
                    ForEach(categoryList.customCategories, id: \.id) { category in
                        Text(category.name).tag(category.id.uuidString)
                    }
                }
                .pickerStyle(.menu)
                HStack {
                    Spacer()
                    Button (action: {showCategoryInputAlert.toggle()}) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color.white)
                                .font(.subheadline)
                            Text("카테고리 추가")
                                .foregroundColor(Color.white)
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                    )
                    .alert("카테고리 추가", isPresented: $showCategoryInputAlert) {
                        TextField("카테고리 이름을 입력해주세요.", text: $newCategoryName)
                        Button(action: {
                            guard !newCategoryName.isEmpty else {
                                alertTitle = "카테고리 이름 입력"
                                alertMessage = "카테고리 이름을 입력해주세요."
                                showWrongCategoryInputAlert = true
                                return
                            }
                            if (categoryList.isDuplicate(name: newCategoryName)) {
                                alertTitle = "카테고리 이름 중복"
                                alertMessage = "다른 이름을 입력해주세요."
                                showWrongCategoryInputAlert = true
                                return
                            }
                            categoryList.customCategories.append(CustomCategory(name: newCategoryName))
                            categoryId = categoryList.getCategoryIdString(name: newCategoryName)
                            newCategoryName = ""
                        }, label: {Text("추가")})
                        Button(action: {newCategoryName = ""}, label: {Text("취소")})
                    } message: {
                        Text("카테고리 이름은 중복될 수 없습니다.")
                    }
                    .alert(isPresented: $showWrongCategoryInputAlert){
                        Alert(
                            title: Text(alertTitle),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("확인"), action: { showCategoryInputAlert = true })
                        )
                    }
                }
            }
            
            VStack {
                Picker("결제 수단 유형", selection: $paymentPay) {
                    Text("( 미지정 )").tag(nil as Payment.method?)
                    ForEach(Payment.method.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(method as Payment.method?)
                    }
                }
                .pickerStyle(.menu)
                if (paymentPay != nil) {
                    Picker("결제 수단 이름", selection: $paymentId) {
                        Text("( 미지정 )").tag("")
                        ForEach(paymentList.payments, id: \.id) { payment in
                            if (paymentPay == payment.pay) {
                                Text(payment.name).tag(payment.id.uuidString)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                    HStack {
                        Spacer()
                        Button (action: {showPaymentInputAlert.toggle()}) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color.white)
                                    .font(.subheadline)
                                Text("결제 수단 추가")
                                    .foregroundColor(Color.white)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                        )
                        .alert("결제 수단 추가", isPresented: $showPaymentInputAlert) {
                            TextField("결제 수단 이름을 입력해주세요.", text: $newPaymentName)
                            Button(action: {
                                guard !newPaymentName.isEmpty else {
                                    alertTitle = "결제 수단 이름 입력"
                                    alertMessage = "결제 수단 이름을 입력해주세요."
                                    showWrongPaymentInputAlert = true
                                    return
                                }
                                if (paymentList.isDuplicate(name: newPaymentName, pay: paymentPay!)) {
                                    alertTitle = "결제 수단 중복"
                                    alertMessage = "다른 유형을 선택하거나 다른 이름을 입력해주세요."
                                    showWrongPaymentInputAlert = true
                                    return
                                }
                                paymentList.payments.append(Payment(name: newPaymentName, pay: paymentPay!))
                                paymentId = paymentList.getPaymentIdString(name: newPaymentName, pay: paymentPay!)
                                newPaymentName = ""
                            }, label: {Text("추가")})
                            Button(action: {
                                newPaymentName = ""
                            }, label: {Text("취소")})
                        } message: {
                            Text("결제 수단은 중복될 수 없습니다.")
                        }
                        .alert(isPresented: $showWrongPaymentInputAlert){
                            Alert(
                                title: Text(alertTitle),
                                message: Text(alertMessage),
                                dismissButton: .default(Text("확인"), action: { showPaymentInputAlert = true })
                            )
                        }
                    }
                }
            }
        }
        
    }
    
    var addButton: some View {
        Button(action: {
            guard !name.isEmpty else {
                alertTitle = "서비스 이름 입력"
                alertMessage = "서비스 이름을 입력해주세요."
                showWrongInputAlert = true
                return
            }
            if subscriptionList.isDuplicate(name: name) {
                alertTitle = "서비스 이름 중복"
                alertMessage = "다른 이름을 입력해주세요."
                showWrongInputAlert = true
                return
            }
            guard !priceString.isEmpty else {
                alertTitle = "구독료 입력"
                alertMessage = "구독료를 입력해주세요."
                showWrongInputAlert = true
                return
            }
            if paymentPay != nil && paymentId.isEmpty {
                alertTitle = "결제 수단 이름 선택"
                alertMessage = "결제 수단 이름을 선택해 주세요."
                showWrongInputAlert = true
                return
            }
            
            if paymentPay == nil {
                paymentId = ""
            }
            addSubscription()
        }) {
            Text("저장")
                .frame(maxWidth: .infinity)
        }
        .alert(isPresented: $showWrongInputAlert){
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인"))
            )
        }
    }
    
    func addSubscription() {
        subscriptionList.subscriptions.append(Subscription(name: name, yearly: isYearly, price: Int(priceString) ?? 0, payDate: DateComponents(month:payMonth, day:payDay), categoryID: categoryId, paymentID: paymentId))
        presentationMode.wrappedValue.dismiss()
    }
}

//#Preview {
//    SubscriptionAdd(subscriptionList: SubscriptionList(), path: )
//}
