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
    @State private var showNonInputAlert = false
    @State private var alertMessage = ""
    @StateObject var subscriptionList: SubscriptionList
    @StateObject var categoryList: CustomCategoryList
    @StateObject var paymentList: PaymentList
    @State private var name: String = ""
    @State private var payDay: Int = 1
    @State private var payMonth: Int = 1
    @State private var isYearly: Bool = false
    @State private var priceString: String = ""
    @State private var categoryId: String = ""
    @State private var paymentId: String = ""
    
    var body: some View {
        NavigationView {
            List {
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
                            .pickerStyle(MenuPickerStyle())
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
                                .pickerStyle(MenuPickerStyle())
                            } else if ([4, 6, 9, 11].contains(payMonth)) {
                                Picker("", selection: $payDay) {
                                    ForEach(1...30, id: \.self) { day in
                                        Text("\(day) 일").font(.title3).tag(day)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            } else {
                                Picker("", selection: $payDay) {
                                    ForEach(1...31, id: \.self) { day in
                                        Text("\(day) 일").font(.title3).tag(day)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        } else {
                            Picker("", selection: $payDay) {
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day) 일").font(.title3).tag(day)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
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
                    
                Section(header: Text("부가 정보 입력")) {
                    VStack {
                        Picker("카테고리", selection: $categoryId) {
                            Text("( 미지정 )").tag("")
                            ForEach(categoryList.customCategories, id: \.id) { category in
                                Text(category.name).tag(category.id.uuidString)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        HStack {
                            Spacer()
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color.white)
                                    .font(.subheadline)
                                Text("카테고리 추가")
                                    .foregroundColor(Color.white)
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                            )
                        }
                    }
                    
                    VStack {
                        Picker("결제 수단", selection: $paymentId) {
                            Text("( 미지정 )").tag("")
                            ForEach(paymentList.payments, id: \.id) { payment in
                                Text(payment.pay.rawValue + " : " + payment.name).tag(payment.id.uuidString)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        HStack {
                            Spacer()
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color.white)
                                    .font(.subheadline)
                                Text("결제 수단 추가")
                                    .foregroundColor(Color.white)
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                            )
                        }
                    }
                }
                
                
                Button(action: {
                    guard !name.isEmpty else {
                        alertMessage = "서비스 이름을 입력해주세요."
                        showNonInputAlert = true
                        return
                    }
                    guard !priceString.isEmpty else {
                        alertMessage = "구독료를 입력해주세요."
                        showNonInputAlert = true
                        return
                    }
                    addSubscription()
                }) {
                    Text("구독 추가")
                        .frame(maxWidth: .infinity)
                }
                .alert(isPresented: $showNonInputAlert){
                    Alert(
                        title: Text("필수 정보가 누락되었습니다."),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("확인"))
                    )
                }
            }
            .navigationTitle("구독 추가")
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("취소")
            })
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
