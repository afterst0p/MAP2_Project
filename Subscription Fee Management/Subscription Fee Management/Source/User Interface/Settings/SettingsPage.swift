//
//  SettingsPage.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/10/24.
//

import SwiftUI

struct SettingsPage: View {
    @ObservedObject var categoryList: CustomCategoryList
    @ObservedObject var paymentList: PaymentList
    @State private var iCloudService = false
    @State private var alertService = false
    
    @State private var isCategoriesEditing = false
    @State private var isPaymentsEditing = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle(isOn: $iCloudService) {
                        Text("iCloud 동기화")
                    }
                }
                Section {
                    Toggle(isOn: $alertService) {
                        Text("구독 결제일 알림")
                    }
                }
                Section {
                    Button(action: {isCategoriesEditing = true}) {
                        HStack {
                            Text("카테고리 관리")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.black)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    Button(action: {isPaymentsEditing = true}) {
                        HStack {
                            Text("결제 수단 관리")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.black)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationBarTitle("설정")
            .sheet(isPresented: $isCategoriesEditing) {
                CategoriesEdit(categoryList: categoryList)
            }
            .sheet(isPresented: $isPaymentsEditing) {
                PaymentsEdit(paymentList: paymentList)
            }
            .contentMargins(.top, 20)
        }
    }
}

#Preview {
    SettingsPage(categoryList: CustomCategoryList(), paymentList: PaymentList())
}
