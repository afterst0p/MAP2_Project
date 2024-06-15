//
//  SettingsPage.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/10/24.
//

import SwiftUI
import CoreData

struct SettingsPage: View {
    @ObservedObject var subscriptionList: SubscriptionList
    @ObservedObject var categoryList: CustomCategoryList
    @ObservedObject var paymentList: PaymentList
    
//    @State private var iCloudService = false
    @State private var alertService: Bool
    
    @State private var isCategoriesEditing = false
    @State private var isPaymentsEditing = false
    
    init(subscriptionList: SubscriptionList, categoryList: CustomCategoryList, paymentList: PaymentList) {
        self.subscriptionList = subscriptionList
        self.categoryList = categoryList
        self.paymentList = paymentList
        _alertService = State(initialValue: UserDefaults.standard.bool(forKey: "alertService"))
    }
    
    var body: some View {
        NavigationView {
            List {
                // Apple Developer Program 가입 필요
//                Section {
//                    Toggle(isOn: $iCloudService) {
//                        Text("iCloud 동기화")
//                    }
//                    .onChange(of: iCloudService) { value in
//                        handleiCloudSync(value)
//                    }
//                }
                Section {
                    Toggle(isOn: $alertService) {
                        Text("구독 결제일 알림")
                    }
                    .onChange(of: alertService) {
                        subscriptionList.usePayDateAlert(enabled: alertService)
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

    // Apple Developer Program 가입 필요
//    private func handleiCloudSync(_ isEnabled: Bool) {
//        let container = PersistenceController.shared.container
//        let description = container.persistentStoreDescriptions.first
//        
//        if isEnabled {
//            description?.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.yourdomain.SubscriptionDataModel")
//        } else {
//            description?.cloudKitContainerOptions = nil
//        }
//        
//        container.loadPersistentStores { storeDescription, error in
//            if let error = error as NSError? {
//                print("Container load failed: \(error)")
//            }
//        }
//    }
}

#Preview {
    SettingsPage(subscriptionList: SubscriptionList(), categoryList: CustomCategoryList(), paymentList: PaymentList())
}
