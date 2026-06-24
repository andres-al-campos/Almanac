//
//  NotificationManager.swift
//  Almanac
//
//  Handles scheduling and managing local notifications
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // Request notification permissions
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // Schedule all notifications for next 10 months (60 total, within iOS 64 limit)
    // 3 types × 2 STRC dates/month × 10 months = 60
    func scheduleAllNotifications() {
        // Clear existing notifications first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        var notifications = 0

        for monthOffset in 0..<10 {
            let month = (currentMonth + monthOffset - 1) % 12 + 1
            let year = currentYear + (currentMonth + monthOffset - 1) / 12

            // STRC pays twice per month (mid-month 15th + 1st of next month).
            // Each date gets: buy-date + approaching-close + extended-hours-closed.
            let strcDates = TradingCalendar.calculateAllSTRCDates(year: year, month: month)
            for (index, dates) in strcDates.enumerated() {
                let slot = index == 0 ? "mid" : "end"
                scheduleNotification(
                    for: dates.buyDate,
                    title: "STRC Buy Date",
                    exDivDate: dates.exDivDate,
                    identifier: "STRC-\(year)-\(month)-\(slot)"
                )
                scheduleApproachingCloseNotification(for: dates.exDivDate, ticker: "STRC", identifier: "STRC-\(year)-\(month)-\(slot)-close")
                scheduleExtendedHoursClosedNotification(for: dates.exDivDate, ticker: "STRC", identifier: "STRC-\(year)-\(month)-\(slot)-exthours")
                notifications += 3
            }
        }

        print("Scheduled \(notifications) notifications")
    }
    
    // Schedule a single notification
    private func scheduleNotification(for date: Date, title: String, exDivDate: Date, identifier: String) {
        let calendar = Calendar.current
        
        // Format ex-div date as e.g. "Monday the 16th"
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEEE"
        let dayOfWeek = dayOfWeekFormatter.string(from: exDivDate)
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let day = dayFormatter.string(from: exDivDate)
        let ordinal = ordinalSuffix(for: Int(day) ?? 0)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        let month = monthFormatter.string(from: exDivDate)
        
        let exDivDescription = "\(dayOfWeek), \(month) \(day)\(ordinal)"
        let body = "Ex-div date: \(exDivDescription). Buy today to capture the dividend."
        
        // Create date components for 9:30 AM ET
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = 9
        dateComponents.minute = 30
        dateComponents.timeZone = TimeZone(identifier: "America/New_York")
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification \(identifier): \(error.localizedDescription)")
            }
        }
    }
    
    // 3:55 PM ET on ex-div date — last chance to buy during regular hours
    private func scheduleApproachingCloseNotification(for exDivDate: Date, ticker: String, identifier: String) {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: exDivDate)
        dateComponents.hour = 15
        dateComponents.minute = 55
        dateComponents.timeZone = TimeZone(identifier: "America/New_York")

        let content = UNMutableNotificationContent()
        content.title = "\(ticker) — Market Close in 5 min"
        content.body = "Last chance to buy \(ticker) during regular hours and capture the dividend."
        content.sound = .default
        content.badge = 1
        content.interruptionLevel = .timeSensitive

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification \(identifier): \(error.localizedDescription)")
            }
        }
    }

    // 8:00 PM ET on ex-div date — extended hours just ended, sell window open
    private func scheduleExtendedHoursClosedNotification(for exDivDate: Date, ticker: String, identifier: String) {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: exDivDate)
        dateComponents.hour = 20
        dateComponents.minute = 0
        dateComponents.timeZone = TimeZone(identifier: "America/New_York")

        let content = UNMutableNotificationContent()
        content.title = "\(ticker) — Sell Window Open"
        content.body = "Extended hours just ended. You can now sell \(ticker). Dividend captured ✓"
        content.sound = .default
        content.badge = 1
        content.interruptionLevel = .timeSensitive

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification \(identifier): \(error.localizedDescription)")
            }
        }
    }

    private func ordinalSuffix(for day: Int) -> String {
        switch day {
        case 11, 12, 13: return "th"
        case _ where day % 10 == 1: return "st"
        case _ where day % 10 == 2: return "nd"
        case _ where day % 10 == 3: return "rd"
        default: return "th"
        }
    }
    
    // Get count of pending notifications
    func getPendingNotificationsCount(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests.count)
            }
        }
    }
    
    // Get latest notification date (to check coverage window)
    func getLatestNotificationDate(completion: @escaping (Date?) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let dates = requests.compactMap { request -> Date? in
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger,
                      let nextTriggerDate = trigger.nextTriggerDate() else {
                    return nil
                }
                return nextTriggerDate
            }
            
            DispatchQueue.main.async {
                completion(dates.max())
            }
        }
    }
    
    // Check if notifications need refresh (if coverage window is less than 3 months out)
    func needsRefresh(completion: @escaping (Bool) -> Void) {
        getLatestNotificationDate { latestDate in
            guard let latestDate = latestDate else {
                // No notifications scheduled, needs refresh
                completion(true)
                return
            }
            
            let threeMonthsFromNow = Calendar.current.date(byAdding: .month, value: 3, to: Date())!
            completion(latestDate < threeMonthsFromNow)
        }
    }
}
