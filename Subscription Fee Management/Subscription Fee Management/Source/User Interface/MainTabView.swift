//
//  MainTabView.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/10/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var subscriptionList: SubscriptionList
    @StateObject var categoryList: CustomCategoryList
    @StateObject var paymentList: PaymentList
    
    private enum Tabs {
        case expenditure, subscription, settings
    }
    @State private var selectedTab: Tabs = .expenditure
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Group {
                expenditure
                subscription
                settings
            }
            //.toolbarBackground(.white, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
    }
    
    var expenditure: some View {
        ExpenditurePage(subscriptionList: subscriptionList, categoryList: categoryList, paymentList: paymentList)
            .tag(Tabs.expenditure)
            .tabItem(image: "scroll", text: "지출 확인")
    }
    
    var subscription: some View {
        SubscriptionPage(subscriptionList: subscriptionList, categoryList: categoryList, paymentList: paymentList)
            .tag(Tabs.subscription)
            .tabItem(image: "list.dash", text: "구독 목록")
    }
    
    var settings: some View {
        SettingsPage(subscriptionList: subscriptionList, categoryList: categoryList, paymentList: paymentList)
            .tag(Tabs.settings)
            .tabItem(image: "gear", text: "설정")
    }
    
    var edges: Edge.Set {
        if #available(iOS 13.4, *) {
            // 안전 영역 무시 안 함
            return .init()
        } else {
            // 안전 영억 무시하고 상단까지 채움
            return .top
        }
    }
}

extension View {
    func tabItem(image: String, text: String) -> some View {
        self.tabItem {
            Image(systemName: image)
                .environment(\.symbolVariants, .none)
                .font(Font.system(size: 17, weight: .light))
            Text(text)
        }
    }
}

#Preview {
    MainTabView(subscriptionList: SubscriptionList(), categoryList: CustomCategoryList(), paymentList: PaymentList())
}
