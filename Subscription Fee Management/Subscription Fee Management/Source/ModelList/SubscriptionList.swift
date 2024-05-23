//
//  SubscriptionList.swift
//  Subscription Fee Management
//
//  Created by S.Top on 5/23/24.
//

import Foundation

final class Store: ObservableObject {
    @Published var products: [Product]
    @Published var orders: [Order] = []
    
    init(filename: String = "ProductData.json") {
        self.products = Bundle.main.decode(filename: filename, as: [Product].self)
    }
}
