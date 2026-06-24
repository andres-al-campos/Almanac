//
//  ContentView.swift
//  Almanac
//
//  Main app UI
//

import SwiftUI
import UserNotifications

// A single upcoming STRC buy date entry
struct BuyDateEntry: Identifiable {
    let id = UUID()
    let ticker: String
    let buyDate: Date
    let exDivDate: Date
    let color: Color
}

struct ContentView: View {
    @State private var permissionGranted = false
    @State private var pendingNotifications = 0
    @State private var lastUpdated: Date?
    @State private var upcomingDates: [BuyDateEntry] = []
    @State private var isRefreshing = false
    
    // The very next STRC date (for the lead hero card)
    private var nextSTRC: BuyDateEntry? {
        upcomingDates.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Almanac")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("STRC Buy Dates")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Hero cards — nearest date first
                    VStack(spacing: 12) {
                        if let first = upcomingDates.first {
                            DateCard(
                                title: "Next \(first.ticker) Buy",
                                date: first.buyDate,
                                exDivDate: first.exDivDate,
                                color: first.color
                            )
                        }

                        // Second STRC hero card (the one after the next)
                        if let second = upcomingDates.dropFirst().first {
                            DateCard(
                                title: "Next \(second.ticker) Buy",
                                date: second.buyDate,
                                exDivDate: second.exDivDate,
                                color: second.color
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Last updated
                    if let updated = lastUpdated {
                        Text("Last updated: \(updated, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Refresh button
                    Button(action: refreshNotifications) {
                        HStack {
                            if isRefreshing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text("Refresh Notifications")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isRefreshing)
                    .padding(.horizontal)
                    
                    // Permission message
                    if !permissionGranted {
                        Text("Notifications not enabled. Tap refresh to enable.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Upcoming dates timeline
                    if !upcomingDates.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Upcoming Dates")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.bottom, 12)
                            
                            ForEach(upcomingDates) { entry in
                                TimelineRow(entry: entry)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            checkPermissionAndUpdate()
        }
    }
    
    private func checkPermissionAndUpdate() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                permissionGranted = settings.authorizationStatus == .authorized
                if permissionGranted {
                    updateStatus()
                }
            }
        }
    }
    
    private func refreshNotifications() {
        isRefreshing = true
        
        NotificationManager.shared.requestPermission { granted in
            self.permissionGranted = granted
            
            if granted {
                NotificationManager.shared.scheduleAllNotifications()
                self.lastUpdated = Date()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.updateStatus()
                    self.isRefreshing = false
                }
            } else {
                self.isRefreshing = false
            }
        }
    }
    
    private func updateStatus() {
        NotificationManager.shared.getPendingNotificationsCount { count in
            self.pendingNotifications = count
        }
        
        let cutoff = TradingCalendar.marketOpenToday
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        
        var dates: [BuyDateEntry] = []

        // Collect all upcoming STRC dates (twice per month) for ~2 years
        for monthOffset in 0..<10 {
            let month = (currentMonth + monthOffset - 1) % 12 + 1
            let year = currentYear + (currentMonth + monthOffset - 1) / 12

            for (buy, exDiv) in TradingCalendar.calculateAllSTRCDates(year: year, month: month) {
                if buy >= cutoff {
                    dates.append(BuyDateEntry(
                        ticker: "STRC",
                        buyDate: buy,
                        exDivDate: exDiv,
                        color: .blue
                    ))
                }
            }
        }
        
        // Sort by date (nearest first)
        self.upcomingDates = dates.sorted(by: { $0.buyDate < $1.buyDate })
    }
}

struct DateCard: View {
    let title: String
    let date: Date
    let exDivDate: Date
    let color: Color

    private let exDivFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)

            Text(date, formatter: dateFormatter)
                .font(.title3)
                .fontWeight(.semibold)

            Text(daysUntil(date: date))
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Ex-div: \(exDivFormatter.string(from: exDivDate)) · sell after 8 PM ET")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }

    private func daysUntil(date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days == 0 {
            return "Today!"
        } else if days == 1 {
            return "Tomorrow"
        } else {
            return "\(days) days away"
        }
    }
}

struct TimelineRow: View {
    let entry: BuyDateEntry
    
    private var daysAway: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: entry.buyDate).day ?? 0
    }
    
    private var daysLabel: String {
        if daysAway == 0 { return "Today" }
        if daysAway == 1 { return "Tomorrow" }
        return "\(daysAway)d"
    }
    
    private var exDivLabel: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE M/d"
        return "ex-div \(fmt.string(from: entry.exDivDate))"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Ticker badge
            Text(entry.ticker)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 48, height: 26)
                .background(entry.color)
                .cornerRadius(6)
            
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.buyDate, formatter: dateFormatter)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(exDivLabel)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("sell after 8 PM ET ex-div day")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Days away
            Text(daysLabel)
                .font(.subheadline)
                .foregroundColor(daysAway <= 3 ? .orange : .secondary)
                .fontWeight(daysAway <= 3 ? .bold : .regular)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(daysAway <= 1 ? entry.color.opacity(0.1) : Color.clear)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
