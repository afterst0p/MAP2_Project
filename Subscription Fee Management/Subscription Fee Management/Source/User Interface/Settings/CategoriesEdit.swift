//
//  CategoriesEdit.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/10/24.
//

import SwiftUI

struct CategoriesEdit: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var categoryList: CustomCategoryList
    
    @State private var selectedCategoryId = ""
    @State private var newCategoryName = ""
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isEditing = false
    @State private var showNameEditAlert = false
    @State private var showWrongInputAlert = false
    
    var body: some View {
        NavigationView {
            List {
                if (isEditing) {
                    Section() {
                        Text("영역을 터치하면 이름을 수정할 수 있습니다.")
                    }
                }
                ForEach(0..<categoryList.customCategories.count, id: \.self) { i in
                    Button(action: {
                        if (isEditing) {
                            newCategoryName = categoryList.customCategories[i].name
                            selectedCategoryId = categoryList.customCategories[i].id.uuidString
                            showNameEditAlert.toggle()
                        }
                    }) {
                        Text(categoryList.customCategories[i].name)
                    }
                    .alert("카테고리 이름 수정", isPresented: $showNameEditAlert) {
                        TextField("카테고리 이름을 입력해주세요.", text: $newCategoryName)
                        // isEditing 일 때만 action 내용이 실행되도록 하기
                        Button(action: {
                            guard !newCategoryName.isEmpty else {
                                alertTitle = "카테고리 이름 입력"
                                alertMessage = "카테고리 이름을 입력해주세요."
                                showWrongInputAlert = true
                                return
                            }
                            if (categoryList.isDuplicate(name: newCategoryName, uuidString: selectedCategoryId)) {
                                alertTitle = "카테고리 이름 중복"
                                alertMessage = "다른 이름을 입력해주세요."
                                showWrongInputAlert = true
                                return
                            }
                            categoryList.update(uuidString: selectedCategoryId, name: newCategoryName)
                            newCategoryName = ""
                            selectedCategoryId = ""
                        }, label: {Text("수정")})
                        Button(action: {
                            newCategoryName = ""
                            selectedCategoryId = ""
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
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            }
            .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive)).animation(Animation.spring())
            .navigationBarTitle("카테고리 관리")
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
        categoryList.customCategories.remove(atOffsets: offsets)
    }
    
    func moveItems(from source: IndexSet, to destination: Int) {
        categoryList.customCategories.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    CategoriesEdit(categoryList: CustomCategoryList())
}
