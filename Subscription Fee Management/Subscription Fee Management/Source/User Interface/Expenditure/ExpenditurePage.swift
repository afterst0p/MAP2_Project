//
//  ExpenditurePage.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/16/24.
//

import SwiftUI
import Charts

struct ExpenditurePage: View {
    @ObservedObject var subscriptionList: SubscriptionList
    @ObservedObject var categoryList: CustomCategoryList
    @ObservedObject var paymentList: PaymentList

    @State private var isYearly = false
    @State private var expenditureTitle = "이번 달 구독료"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Text("\(isYearly ? subscriptionList.getYearlyTotal() : subscriptionList.getMonthlyTotal())원")
                            .frame(alignment: .leading)
                            .font(.largeTitle)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    expenditureChart
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
            .navigationBarTitle(expenditureTitle)
            .navigationBarItems(trailing: Button(action: {
                isYearly.toggle()
                expenditureTitle = isYearly ? "올해 구독료" : "이번 달 구독료"
            }) {
                isYearly ? Text("이번 달 보기") : Text("올해 보기")
            })
            .contentMargins(.top, 20)
        }
    }
    
    var expenditureChart: some View {
        let today = Calendar.current.dateComponents([.month, .day], from: Date())
        let endDayOfMonth = Calendar.current.component(.day, from: Date().endDateOfMonth)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.white)
            
            ScrollView(.horizontal) {
                
                Chart {
                    if (isYearly) {
                        ForEach(subscriptionList.getMonthlyExpenses().sorted(by: { $0.key < $1.key }), id: \.key) { month, expense in
                            BarMark(
                                x: .value(today.month == month ? "ThisMonth" : "Month", month),
                                y: .value("Expense", expense),
                                width: 30
                            )
                            .foregroundStyle(today.month == month ? Color.red : Color.blue)
                            .annotation(position: .top) {
                                Text("\(expense)")
                                    .font(.caption)
                            }
                        }
                    } else {
                        ForEach(subscriptionList.getDailyExpenses().sorted(by: { $0.key < $1.key }), id: \.key) { day, expense in
                            BarMark(
                                x: .value(today.day == day ? "ThisDay" : "Day", day),
                                y: .value("Expense", expense),
                                width: 10
                            )
                            .foregroundStyle(today.day == day ? Color.red : Color.blue)
                            .annotation(position: .top) {
                                Text("\(expense)")
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .chartXAxisLabel(position: .bottomTrailing) {
                    Text(isYearly ? "월" : "일").font(.subheadline).padding(.bottom)
                }
                .chartXScale(
                    domain: isYearly
                    ? 0.5...12.5
                    : 0.1...Double(endDayOfMonth) + 0.9
                )
                .chartXAxis {
                    AxisMarks(values: .stride(by: 1)) { value in
                        AxisGridLine()
                        AxisValueLabel(anchor: .top)
                    }
                }
                .chartYAxisLabel(position: .topLeading) {
                    Text("￦(원)").font(.subheadline).padding(.bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(width: CGFloat(20 + (isYearly ? 13 * 60 : (endDayOfMonth + 2) * 20 )))
                
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ExpenditurePage(subscriptionList: SubscriptionList(), categoryList: CustomCategoryList(), paymentList: PaymentList())
}

