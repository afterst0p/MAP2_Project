//
//  Subscription_Fee_ManagementApp.swift
//  Subscription Fee Management
//
//  Created by S.Top on 5/22/24.
//

import SwiftUI

@main
struct Subscription_Fee_ManagementApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView(subscriptionList: SubscriptionList(), categoryList: CustomCategoryList(), paymentList: PaymentList())
        }
    }
}
