//
//  SubscriptionAdd.swift
//  Subscription Fee Management
//
//  Created by S.Top on 5/24/24.
//

import SwiftUI

struct SubscriptionAdd: View {
    @StateObject var subscriptionList: SubscriptionList
    @StateObject var categoryList: CustomCategoryList
    @StateObject var paymentList: PaymentList
    @Binding var path: NavigationPath
    @State private var name: String = ""
    @State private var isYearly = false
    
    var body: some View {
        Form {
            Section(header: Text("구독 정보 입력")) {
                DataInput(title: "서비스 이름", userInput: $name)
                
                Toggle(isOn: $isYearly) {
                    Text("연간 구독").font(.subheadline)
                }
            }
            
            Button(action: addSubscription) {
                Text("구독 추가")
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    func addSubscription() {
        
    }
}

struct DataInput: View {
    var title: String
    @Binding var userInput: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.subheadline)
            TextField("\(title)을 입력해 주세요.", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

//#Preview {
//    SubscriptionAdd(subscriptionList: SubscriptionList(), path: )
//}
