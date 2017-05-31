//
//  NSDateExtension.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation

extension Calendar {
    func dateRange(startDate: Foundation.Date, endDate: Foundation.Date, stepUnits: NSCalendar.Unit, stepValue: Int) -> DateRange {
        return DateRange(calendar: self, startDate: startDate, endDate: endDate,
                                  stepUnits: stepUnits, stepValue: stepValue, multiplier: 0)
    }
}

struct DateRange: Sequence {
    
    var calendar: Calendar
    var startDate: Foundation.Date
    var endDate: Foundation.Date
    var stepUnits: NSCalendar.Unit
    var stepValue: Int
    fileprivate var multiplier: Int
    
    func makeIterator() -> Iterator {
        return Iterator(range: self)
    }
    
    struct Iterator: IteratorProtocol {
        
        var range: DateRange
        
        mutating func next() -> Foundation.Date? {
            guard let nextDate = (range.calendar as NSCalendar).date(byAdding: range.stepUnits,
                                                                 value: range.stepValue * range.multiplier,
                                                                 to: range.startDate,
                                                                 options: []) else {
                                                                    return nil
            }
            range.multiplier += 1
            return nextDate > range.endDate ? nil : nextDate
        }
    }
}
