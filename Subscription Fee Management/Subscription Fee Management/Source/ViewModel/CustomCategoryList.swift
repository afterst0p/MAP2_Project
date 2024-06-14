//
//  CustomCategoryList.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/7/24.
//

import SwiftUI
import CoreData

// 카테고리를 모으는 뷰모델
class CustomCategoryList: ObservableObject {
    private var viewContext: NSManagedObjectContext
    
    @Published var customCategories : [CustomCategory] = []
    
    // 프로젝트에 포함된 json 파일, 수정 불가
//    init(filename: String = "CustomCategoryData.json") {
//        self.customCategories = Bundle.main.decode(filename: filename, as: [CustomCategory].self)
//    }
    
    init(context: NSManagedObjectContext = PersistenceController.shared.context) {
        self.viewContext = context
        fetch()
    }
    
    func fetch() {
        let request: NSFetchRequest<CDCustomCategory> = CDCustomCategory.fetchRequest()
        do {
            let cdCustomCategories = try viewContext.fetch(request)
            customCategories = cdCustomCategories.map { CustomCategory(cdCustomCategory: $0) }
        } catch {
            print("Core Data에서 CustomCategory 불러오기 실패")
        }
    }
    
    func add(customCategory: CustomCategory) {
        let cdCustomCategory = customCategory.toCDCustomCategory(context: viewContext)
        saveContext()
    }
    
    func update(uuidString: String, name: String) {
        let request: NSFetchRequest<CDCustomCategory> = CDCustomCategory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", uuidString as CVarArg)
        
        do {
            let cdCustomCategories = try viewContext.fetch(request)
            if let cdCustomCategory = cdCustomCategories.first {
                cdCustomCategory.name = name
                
                saveContext()
            }
        } catch {
            print("Core Data에 CustomCategory 수정 실패: \(error)")
        }
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            let customCategory = customCategories[index]
            let request: NSFetchRequest<CDCustomCategory> = CDCustomCategory.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", customCategory.id as CVarArg)
            
            do {
                let cdCustomCategories = try viewContext.fetch(request)
                if let cdCustomCategory = cdCustomCategories.first {
                    viewContext.delete(cdCustomCategory)
                    saveContext()
                }
            } catch {
                print("Core Data에 CustomCategory 삭제 실패: \(error)")
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        customCategories.move(fromOffsets: source, toOffset: destination)
        saveContext()
    }
    
    func saveContext() {
        do {
            try viewContext.save()
            fetch()
        } catch {
            print("Core Data에 CustomCategory 저장 실패")
        }
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
    
    func isDuplicate(name: String, uuidString: String) -> Bool {
        customCategories.contains { $0.name == name && $0.id.uuidString != uuidString }
    }
}
