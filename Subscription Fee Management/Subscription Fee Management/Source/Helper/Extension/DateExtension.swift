//
//  DateExtension.swift
//  Subscription Fee Management
//
//  Created by S.Top on 6/18/24.
//

import Foundation

extension Date {
    var startDateOfMonth: Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) else {
            fatalError("Unable to get start date from date")
        }
        return date
    }

    var endDateOfMonth: Date {
        guard let date = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startDateOfMonth) else {
            fatalError("Unable to get end date from date")
        }
        return date
    }
}
