//
//  Category.swift
//  Subscription Fee Management
//
//  Created by S.Top on 5/22/24.
//

import Foundation

// 카테고리 구조체
struct CustomCategory {
    let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

// 카테고리를 모으는 클래스
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
    
    func isDuplicate(name: String) -> Bool {
        customCategories.contains { $0.name == name }
    }
}

let categorySamples = [
    CustomCategory(id: UUID(uuidString: "3B34D425-6C38-4FC9-A59E-8B71F62492C6") ?? UUID(), name: "음악"),
    CustomCategory(id: UUID(uuidString: "72B527C5-907F-4A22-B51D-832634BF86B3") ?? UUID(), name: "동영상"),
    CustomCategory(id: UUID(uuidString: "E708C03A-F4F2-4B54-8362-541F4C7B5E5B") ?? UUID(), name: "멤버십")
]

extension CustomCategory: Decodable {}
extension CustomCategory: Identifiable {}
extension CustomCategory: Hashable {}
