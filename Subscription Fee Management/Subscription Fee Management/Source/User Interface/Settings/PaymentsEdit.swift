//
//  CategoriesEdit.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/10/24.
//

import SwiftUI

struct PaymentsEdit: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var paymentList: PaymentList
    
    @State private var selectedPaymentId = ""
    @State private var selectedPaymentPay = Payment.method.allCases.first
    @State private var newPaymentName = ""
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isEditing = false
    @State private var showNameEditAlert = false
    @State private var showWrongInputAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if (isEditing) {
                        Text("영역을 터치하면 이름을 수정할 수 있습니다.")
                    }
                    else {
                        Picker("결제 수단 유형", selection: $selectedPaymentPay) {
                            ForEach(Payment.method.allCases, id: \.self) { method in
                                Text(method.rawValue).tag(method as Payment.method?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                ForEach(0..<paymentList.payments.count, id: \.self) { i in
                    if (paymentList.payments[i].pay == selectedPaymentPay) {
                        Button(action: {
                            if (isEditing) {
                                newPaymentName = paymentList.payments[i].name
                                selectedPaymentId = paymentList.payments[i].id.uuidString
                                showNameEditAlert.toggle()
                            }
                        }) {
                            Text(paymentList.payments[i].name)
                        }
                        .alert("결제 수단 이름 수정", isPresented: $showNameEditAlert) {
                            TextField("결제 수단 이름을 입력해주세요.", text: $newPaymentName)
                            // isEditing 일 때만 action 내용이 실행되도록 하기
                            Button(action: {
                                guard !newPaymentName.isEmpty else {
                                    alertTitle = "결제 수단 이름 입력"
                                    alertMessage = "결제 수단 이름을 입력해주세요."
                                    showWrongInputAlert = true
                                    return
                                }
                                if (paymentList.isDuplicate(name: newPaymentName, pay: selectedPaymentPay!,uuidString: selectedPaymentId)) {
                                    alertTitle = "결제 수단 이름 중복"
                                    alertMessage = "다른 이름을 입력해주세요."
                                    showWrongInputAlert = true
                                    return
                                }
                                paymentList.update(uuidString: selectedPaymentId, name: newPaymentName)
                                newPaymentName = ""
                                selectedPaymentId = ""
                            }, label: {Text("수정")})
                            Button(action: {
                                newPaymentName = ""
                                selectedPaymentId = ""
                            }, label: {Text("취소")})
                        }
                        .alert(isPresented: $showWrongInputAlert){
                            Alert(
                                title: Text(alertTitle),
                                message: Text(alertMessage),
                                dismissButton: .default(Text("확인"), action: { showNameEditAlert = true })
                            )
                        }
                    }
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            }
            .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive)).animation(Animation.spring())
            .navigationBarTitle("결제 수단 관리")
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    self.isEditing.toggle()
                }) {
                    Text(isEditing ? "완료" : "수정").frame(width: 40)
                }
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("닫기")
                }
            })
            .contentMargins(.top, 20)
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        paymentList.payments.remove(atOffsets: offsets)
    }
    
    func moveItems(from source: IndexSet, to destination: Int) {
        paymentList.payments.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    PaymentsEdit(paymentList: PaymentList())
}
