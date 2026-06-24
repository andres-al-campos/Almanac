//
//  TradingCalendarTests.swift
//  AlmanacTests
//
//  Unit tests for TradingCalendar date calculations
//

import XCTest
@testable import Almanac

class TradingCalendarTests: XCTestCase {

    // MARK: - Helpers

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func assertSameDay(_ date1: Date, _ date2: Date,
                               file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(
            Calendar.current.isDate(date1, inSameDayAs: date2),
            "Expected \(date1) to be same day as \(date2)",
            file: file, line: line
        )
    }

    // MARK: - isTradingDay

    func testIsTradingDay_normalWeekday() {
        // Wed Apr 15, 2026 — regular weekday, no holiday
        XCTAssertTrue(TradingCalendar.isTradingDay(makeDate(year: 2026, month: 4, day: 15)))
    }

    func testIsTradingDay_saturday() {
        // Sat Aug 15, 2026
        XCTAssertFalse(TradingCalendar.isTradingDay(makeDate(year: 2026, month: 8, day: 15)))
    }

    func testIsTradingDay_sunday() {
        // Sun Mar 15, 2026
        XCTAssertFalse(TradingCalendar.isTradingDay(makeDate(year: 2026, month: 3, day: 15)))
    }

    func testIsTradingDay_holiday() {
        // Thu Nov 26, 2026 — Thanksgiving
        XCTAssertFalse(TradingCalendar.isTradingDay(makeDate(year: 2026, month: 11, day: 26)))
    }

    func testIsTradingDay_observedHoliday() {
        // Fri Jul 3, 2026 — Independence Day observed (Jul 4 is Sat)
        XCTAssertFalse(TradingCalendar.isTradingDay(makeDate(year: 2026, month: 7, day: 3)))
    }

    func testIsTradingDay_dayAfterHoliday() {
        // Fri Nov 27, 2026 — day after Thanksgiving, NOT an NYSE holiday
        XCTAssertTrue(TradingCalendar.isTradingDay(makeDate(year: 2026, month: 11, day: 27)))
    }

    // MARK: - previousTradingDay

    func testPreviousTradingDay_fromMonday() {
        // Mon Mar 16, 2026 → should skip Sat/Sun → Fri Mar 13
        let result = TradingCalendar.previousTradingDay(before: makeDate(year: 2026, month: 3, day: 16))
        assertSameDay(result, makeDate(year: 2026, month: 3, day: 13))
    }

    func testPreviousTradingDay_fromTuesdayAfterMLK() {
        // Tue Jan 20, 2026 → Jan 19 is MLK (Mon holiday), skip weekend → Fri Jan 16
        let result = TradingCalendar.previousTradingDay(before: makeDate(year: 2026, month: 1, day: 20))
        assertSameDay(result, makeDate(year: 2026, month: 1, day: 16))
    }

    func testPreviousTradingDay_afterGoodFriday() {
        // Sat Apr 4, 2026 → Apr 3 is Good Friday (holiday), skip → Thu Apr 2
        let result = TradingCalendar.previousTradingDay(before: makeDate(year: 2026, month: 4, day: 4))
        assertSameDay(result, makeDate(year: 2026, month: 4, day: 2))
    }

    // MARK: - calculateSTRCDates (STRC mid-month date, the 15th)

    func testSTRCBuyDate_normalWeekday_Jan2026() {
        // 15th is Thu (trading day) → record=Jan 15, ex-div=Jan 15, buy=Jan 14 (Wed)
        let result = TradingCalendar.calculateSTRCDates(year: 2026, month: 1).buyDate
        assertSameDay(result, makeDate(year: 2026, month: 1, day: 14))
    }

    func testSTRCBuyDate_15thIsSaturday_Aug2026() {
        // 15th is Sat → record=Fri 14, ex-div=Fri 14 (trading day), buy=Thu 13
        let result = TradingCalendar.calculateSTRCDates(year: 2026, month: 8).buyDate
        assertSameDay(result, makeDate(year: 2026, month: 8, day: 13))
    }

    func testSTRCBuyDate_15thIsSunday_Mar2026() {
        // 15th is Sun → record=Fri 13, ex-div=Fri 13 (trading day), buy=Thu 12
        let result = TradingCalendar.calculateSTRCDates(year: 2026, month: 3).buyDate
        assertSameDay(result, makeDate(year: 2026, month: 3, day: 12))
    }

    func testSTRCBuyDate_holidayCollision_Apr2028() {
        // 15th is Sat, 14th is Good Friday → record=Thu 13, ex-div=Thu 13, buy=Wed 12
        let result = TradingCalendar.calculateSTRCDates(year: 2028, month: 4).buyDate
        assertSameDay(result, makeDate(year: 2028, month: 4, day: 12))
    }

    func testSTRCBuyDate_normalWeekday_Sep2026() {
        // 15th is Tue (trading day) → record=Sep 15, ex-div=Sep 15, buy=Mon 14
        let result = TradingCalendar.calculateSTRCDates(year: 2026, month: 9).buyDate
        assertSameDay(result, makeDate(year: 2026, month: 9, day: 14))
    }

    func testSTRCBuyDate_nearJuneteenth_Jun2026() {
        // 15th is Mon (trading day) → record=Jun 15, ex-div=Jun 15, buy=Fri 12
        let result = TradingCalendar.calculateSTRCDates(year: 2026, month: 6).buyDate
        assertSameDay(result, makeDate(year: 2026, month: 6, day: 12))
    }

    // MARK: - calculateSTRCMonthEndDates (STRC second monthly date, 1st of next month)

    func testSTRCMonthEndBuyDate_31DayMonth_Jul2026() {
        // Record=Aug 1 (Sat, not trading), ex-div=Jul 31 (Fri), buy=Jul 30 (Thu)
        let result = TradingCalendar.calculateSTRCMonthEndDates(year: 2026, month: 7).buyDate
        assertSameDay(result, makeDate(year: 2026, month: 7, day: 30))
    }

    func testSTRCMonthEndBuyDate_30DayMonth_Jun2026() {
        // Record=Jul 1 (Wed, trading day), ex-div=Jul 1, buy=Jun 30 (Tue)
        let result = TradingCalendar.calculateSTRCMonthEndDates(year: 2026, month: 6).buyDate
        assertSameDay(result, makeDate(year: 2026, month: 6, day: 30))
    }

    func testSTRCMonthEndBuyDate_february28_2026() {
        // Record=Mar 1 (Sun, not trading), ex-div=Feb 27 (Fri), buy=Feb 26 (Thu)
        let result = TradingCalendar.calculateSTRCMonthEndDates(year: 2026, month: 2).buyDate
        assertSameDay(result, makeDate(year: 2026, month: 2, day: 26))
    }

    func testSTRCMonthEndBuyDate_februaryLeapYear_2028() {
        // Record=Mar 1 (Wed, trading day), ex-div=Mar 1, buy=Feb 29 (Tue)
        let result = TradingCalendar.calculateSTRCMonthEndDates(year: 2028, month: 2).buyDate
        assertSameDay(result, makeDate(year: 2028, month: 2, day: 29))
    }

    func testSTRCMonthEndBuyDate_lastDayIsSaturday_Oct2026() {
        // Record=Nov 1 (Sun, not trading), ex-div=Oct 30 (Fri), buy=Oct 29 (Thu)
        let result = TradingCalendar.calculateSTRCMonthEndDates(year: 2026, month: 10).buyDate
        assertSameDay(result, makeDate(year: 2026, month: 10, day: 29))
    }

    func testSTRCMonthEndBuyDate_lastDayIsSunday_May2026() {
        // Record=Jun 1 (Mon, trading day), ex-div=Jun 1, buy=May 29 (Fri)
        let result = TradingCalendar.calculateSTRCMonthEndDates(year: 2026, month: 5).buyDate
        assertSameDay(result, makeDate(year: 2026, month: 5, day: 29))
    }

    func testSTRCMonthEndBuyDate_december2026() {
        // Record=Jan 1, 2027 (Fri, New Year's holiday), ex-div=Dec 31 (Thu), buy=Dec 30 (Wed)
        let result = TradingCalendar.calculateSTRCMonthEndDates(year: 2026, month: 12).buyDate
        assertSameDay(result, makeDate(year: 2026, month: 12, day: 30))
    }

    func testSTRCMonthEndBuyDate_december2027() {
        // Record=Jan 1, 2028 (Sat, not trading), ex-div=Dec 31 (Fri), buy=Dec 30 (Thu)
        let result = TradingCalendar.calculateSTRCMonthEndDates(year: 2027, month: 12).buyDate
        assertSameDay(result, makeDate(year: 2027, month: 12, day: 30))
    }

    func testSTRCMonthEndBuyDate_nearThanksgiving_Nov2026() {
        // Record=Dec 1 (Tue, trading day), ex-div=Dec 1, buy=Nov 30 (Mon)
        let result = TradingCalendar.calculateSTRCMonthEndDates(year: 2026, month: 11).buyDate
        assertSameDay(result, makeDate(year: 2026, month: 11, day: 30))
    }

    func testSTRCBuyDate_nearMLK_Jan2027() {
        // 15th is Fri (trading day) → record=Jan 15, ex-div=Jan 15, buy=Thu 14
        let result = TradingCalendar.calculateSTRCDates(year: 2027, month: 1).buyDate
        assertSameDay(result, makeDate(year: 2027, month: 1, day: 14))
    }

    // MARK: - calculateAllSTRCDates

    func testAllSTRCDates_returnsBothMonthlyDates_Jan2026() {
        // Should return the mid-month (15th) pair then the month-end (1st of Feb) pair
        let dates = TradingCalendar.calculateAllSTRCDates(year: 2026, month: 1)
        XCTAssertEqual(dates.count, 2)

        // Mid-month: 15th is Thu → buy=Jan 14
        assertSameDay(dates[0].buyDate, makeDate(year: 2026, month: 1, day: 14))
        // Month-end: record=Feb 1 (Sun, not trading), ex-div=Jan 30 (Fri), buy=Jan 29 (Thu)
        assertSameDay(dates[1].buyDate, makeDate(year: 2026, month: 1, day: 29))

        // The two buy dates must be distinct and chronological
        XCTAssertLessThan(dates[0].buyDate, dates[1].buyDate)
    }
}
