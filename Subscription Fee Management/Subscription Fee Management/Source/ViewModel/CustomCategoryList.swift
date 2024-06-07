//
//  CustomCategoryList.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/7/24.
//

import Foundation

// 카테고리를 모으는 뷰모델
class CustomCategoryList: ObservableObject {
    @Published var customCategories : [CustomCategory]
    
    init(filename: String = "CustomCategoryData.json") {
        self.customCategories = Bundle.main.decode(filename: filename, as: [CustomCategory].self)
    }
    
    func getCategoryByUUID(uuidString: String?) -> CustomCategory? {
        guard let uuidStringUnwrapped = uuidString else {
                    return nil
            }
        guard let uuid = UUID(uuidString: uuidStringUnwrapped) else {
                    return nil
            }
        return customCategories.first { $0.id == uuid }
    }
    
    func getCategoryIdString(name: String) -> String {
        let find = customCategories.first { $0.name == name }
        return find?.id.uuidString ?? ""
    }
    
    func isDuplicate(name: String) -> Bool {
        customCategories.contains { $0.name == name }
    }
}
