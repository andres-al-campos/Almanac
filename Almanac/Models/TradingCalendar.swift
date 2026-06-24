//
//  TradingCalendar.swift
//  Almanac
//
//  Handles NYSE trading calendar and business day calculations
//

import Foundation

class TradingCalendar {
    
    // NYSE Market Holidays 2026-2028 (official from NYSE)
    // TODO: Add 2029+ holidays when NYSE publishes them
    static let nyseHolidays: [Date] = {
        let calendar = Calendar.current
        var holidays: [Date] = []
        
        // 2026
        holidays.append(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!)  // New Year's Day
        holidays.append(calendar.date(from: DateComponents(year: 2026, month: 1, day: 19))!) // MLK Day
        holidays.append(calendar.date(from: DateComponents(year: 2026, month: 2, day: 16))!) // Presidents Day
        holidays.append(calendar.date(from: DateComponents(year: 2026, month: 4, day: 3))!)  // Good Friday
        holidays.append(calendar.date(from: DateComponents(year: 2026, month: 5, day: 25))!) // Memorial Day
        holidays.append(calendar.date(from: DateComponents(year: 2026, month: 6, day: 19))!) // Juneteenth
        holidays.append(calendar.date(from: DateComponents(year: 2026, month: 7, day: 3))!)  // Independence Day observed
        holidays.append(calendar.date(from: DateComponents(year: 2026, month: 9, day: 7))!)  // Labor Day
        holidays.append(calendar.date(from: DateComponents(year: 2026, month: 11, day: 26))!) // Thanksgiving
        holidays.append(calendar.date(from: DateComponents(year: 2026, month: 12, day: 25))!) // Christmas
        
        // 2027
        holidays.append(calendar.date(from: DateComponents(year: 2027, month: 1, day: 1))!)  // New Year's Day
        holidays.append(calendar.date(from: DateComponents(year: 2027, month: 1, day: 18))!) // MLK Day
        holidays.append(calendar.date(from: DateComponents(year: 2027, month: 2, day: 15))!) // Presidents Day
        holidays.append(calendar.date(from: DateComponents(year: 2027, month: 3, day: 26))!) // Good Friday
        holidays.append(calendar.date(from: DateComponents(year: 2027, month: 5, day: 31))!) // Memorial Day
        holidays.append(calendar.date(from: DateComponents(year: 2027, month: 6, day: 18))!) // Juneteenth observed
        holidays.append(calendar.date(from: DateComponents(year: 2027, month: 7, day: 5))!)  // Independence Day observed
        holidays.append(calendar.date(from: DateComponents(year: 2027, month: 9, day: 6))!)  // Labor Day
        holidays.append(calendar.date(from: DateComponents(year: 2027, month: 11, day: 25))!) // Thanksgiving
        holidays.append(calendar.date(from: DateComponents(year: 2027, month: 12, day: 24))!) // Christmas observed
        
        // 2028
        // No New Year's (falls on Saturday)
        holidays.append(calendar.date(from: DateComponents(year: 2028, month: 1, day: 17))!) // MLK Day
        holidays.append(calendar.date(from: DateComponents(year: 2028, month: 2, day: 21))!) // Presidents Day
        holidays.append(calendar.date(from: DateComponents(year: 2028, month: 4, day: 14))!) // Good Friday
        holidays.append(calendar.date(from: DateComponents(year: 2028, month: 5, day: 29))!) // Memorial Day
        holidays.append(calendar.date(from: DateComponents(year: 2028, month: 6, day: 19))!) // Juneteenth
        holidays.append(calendar.date(from: DateComponents(year: 2028, month: 7, day: 4))!)  // Independence Day
        holidays.append(calendar.date(from: DateComponents(year: 2028, month: 9, day: 4))!)  // Labor Day
        holidays.append(calendar.date(from: DateComponents(year: 2028, month: 11, day: 23))!) // Thanksgiving
        holidays.append(calendar.date(from: DateComponents(year: 2028, month: 12, day: 25))!) // Christmas
        
        return holidays
    }()
    
    // Check if a date is a trading day (not weekend, not holiday)
    static func isTradingDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        // Check if weekend (1 = Sunday, 7 = Saturday)
        if weekday == 1 || weekday == 7 {
            return false
        }
        
        // Check if holiday
        let dateOnly = calendar.startOfDay(for: date)
        for holiday in nyseHolidays {
            if calendar.isDate(dateOnly, inSameDayAs: holiday) {
                return false
            }
        }
        
        return true
    }
    
    // Get previous trading day
    static func previousTradingDay(before date: Date) -> Date {
        let calendar = Calendar.current
        var currentDate = calendar.date(byAdding: .day, value: -1, to: date)!
        
        while !isTradingDay(currentDate) {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return currentDate
    }
    
    // Calculate ex-dividend date for a given record date
    // Under T+1: if record date is a trading day, ex-div IS the record date
    // (buying on that day settles the next day, missing the record).
    // If record date is not a trading day, ex-div is the last trading day before it.
    static func exDividendDate(recordDate: Date) -> Date {
        if isTradingDay(recordDate) {
            return recordDate
        }
        return previousTradingDay(before: recordDate)
    }

    // Buy date = last day you can buy and still receive the dividend
    // = the trading day before the ex-div date
    static func buyDate(exDivDate: Date) -> Date {
        return previousTradingDay(before: exDivDate)
    }
    
    // Returns (buyDate, exDivDate) for STRC in a given month/year
    // STRC record date is the 15th (or prior business day if weekend/holiday)
    static func calculateSTRCDates(year: Int, month: Int) -> (buyDate: Date, exDivDate: Date) {
        let calendar = Calendar.current
        
        var recordDate = calendar.date(from: DateComponents(year: year, month: month, day: 15))!
        if !isTradingDay(recordDate) {
            recordDate = previousTradingDay(before: recordDate)
        }
        
        let exDiv = exDividendDate(recordDate: recordDate)
        let buy = buyDate(exDivDate: exDiv)
        return (buy, exDiv)
    }
    
    // Returns (buyDate, exDivDate) for STRC's second monthly record date.
    // STRC now pays twice per month: the 15th (calculateSTRCDates) and the 1st
    // of the following month — the slot the daily-paying SATA used to occupy.
    static func calculateSTRCMonthEndDates(year: Int, month: Int) -> (buyDate: Date, exDivDate: Date) {
        let calendar = Calendar.current

        // Record date is always the 1st of the following month
        let recordDate: Date
        if month == 12 {
            recordDate = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
        } else {
            recordDate = calendar.date(from: DateComponents(year: year, month: month + 1, day: 1))!
        }

        // Ex-div is the previous trading day before the record date
        let exDiv = exDividendDate(recordDate: recordDate)
        let buy = buyDate(exDivDate: exDiv)
        return (buy, exDiv)
    }

    // Both STRC (buyDate, exDivDate) pairs for a given month: the 15th and the
    // 1st of the following month, in chronological order.
    static func calculateAllSTRCDates(year: Int, month: Int) -> [(buyDate: Date, exDivDate: Date)] {
        return [calculateSTRCDates(year: year, month: month),
                calculateSTRCMonthEndDates(year: year, month: month)]
    }
    
    // 9:30 AM ET as a Date for "today" — used to avoid showing past buy dates
    static var marketOpenToday: Date {
        var components = Calendar.current.dateComponents(in: TimeZone(identifier: "America/New_York")!, from: Date())
        components.hour = 9
        components.minute = 30
        components.second = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}
