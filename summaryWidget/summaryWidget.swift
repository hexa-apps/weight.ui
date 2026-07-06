//
//  summaryWidget.swift
//  summaryWidget
//
//  Created by berkay on 24.07.2023.
//

import WidgetKit
import CoreData
import SwiftUI

// MARK: - Data Models

struct CalendarDay: Identifiable {
    let id = UUID()
    let day: Int            // 0 = empty padding cell
    let weight: Double?
    let trend: TrendDirection
    let isToday: Bool
}

enum TrendDirection {
    case up, down, same, first, none
    
    var color: Color {
        switch self {
        case .up:    return Color(red: 0.95, green: 0.3, blue: 0.3)
        case .down:  return Color(red: 0.2, green: 0.78, blue: 0.4)
        case .same:  return Color.gray
        case .first: return Color(red: 0.4, green: 0.33, blue: 0.96)
        case .none:  return Color.clear
        }
    }
}

// MARK: - Timeline Entry

struct WeightCalendarEntry: TimelineEntry {
    let date: Date
    let monthTitle: String
    let weekdayHeaders: [String]
    let calendarRows: [[CalendarDay]]
    let unit: String
    let latestWeight: Double?
    let goalWeight: Double
    let entryCount: Int
}

// MARK: - Provider

struct CalendarProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> WeightCalendarEntry {
        buildEntry(date: Date(), weights: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeightCalendarEntry) -> Void) {
        let weights = fetchWeights()
        completion(buildEntry(date: Date(), weights: weights))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeightCalendarEntry>) -> Void) {
        let weights = fetchWeights()
        let entry = buildEntry(date: Date(), weights: weights)
        let midnight = Calendar.current.startOfDay(for: Date())
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }
    
    private func fetchWeights() -> [(date: Date, weight: Double)] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WeightEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        do {
            let results = try WeightDataController.standard.container.viewContext.fetch(request) as? [NSManagedObject] ?? []
            return results.compactMap { obj in
                guard let time = obj.value(forKey: "time") as? Date,
                      let weight = obj.value(forKey: "weight") as? Double else { return nil }
                return (date: time, weight: weight)
            }
        } catch {
            return []
        }
    }
    
    private func buildEntry(date: Date, weights: [(date: Date, weight: Double)]) -> WeightCalendarEntry {
        let calendar = Calendar.current
        let defaults = WeightDataController.sharedDefaults
        let unit = defaults.string(forKey: "weightUnit") ?? "kg"
        let goal = defaults.integer(forKey: "goal")
        let goalTail = defaults.integer(forKey: "goalTail")
        let goalWeight = Double(goal) + Double(goalTail) * 0.1
        
        // Month info
        let monthComponents = calendar.dateComponents([.year, .month], from: date)
        let firstOfMonth = calendar.date(from: monthComponents)!
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)!.count
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        // Monday-start offset: Sunday=1 → offset 6, Monday=2 → offset 0, etc.
        let startOffset = (firstWeekday + 5) % 7
        
        let todayDay = calendar.component(.day, from: date)
        let todayMonth = calendar.component(.month, from: date)
        let todayYear = calendar.component(.year, from: date)
        let isCurrentMonth = (monthComponents.month == todayMonth && monthComponents.year == todayYear)
        
        // Month title
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "LLLL yyyy"
        let monthTitle = formatter.string(from: date).capitalized
        
        // Weekday headers (Monday first)
        let weekdayHeaders = ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pz"]
        
        // Map weights by day for this month
        var weightByDay: [Int: Double] = [:]
        for w in weights {
            let wc = calendar.dateComponents([.year, .month, .day], from: w.date)
            if wc.year == monthComponents.year && wc.month == monthComponents.month {
                weightByDay[wc.day!] = w.weight
            }
        }
        
        // Find previous weight before this month (for trend of first entry)
        var prevWeight: Double? = nil
        for w in weights.reversed() {
            let wc = calendar.dateComponents([.year, .month], from: w.date)
            if wc.year! < monthComponents.year! ||
                (wc.year == monthComponents.year && wc.month! < monthComponents.month!) {
                prevWeight = w.weight
                break
            }
        }
        
        // Build calendar days with trend info
        var allDays: [CalendarDay] = []
        // Leading empty cells
        for _ in 0..<startOffset {
            allDays.append(CalendarDay(day: 0, weight: nil, trend: .none, isToday: false))
        }
        // Actual days
        var lastKnownWeight = prevWeight
        var entryCount = 0
        for day in 1...daysInMonth {
            let weight = weightByDay[day]
            var trend: TrendDirection = .none
            if let w = weight {
                entryCount += 1
                if let prev = lastKnownWeight {
                    if w < prev { trend = .down }
                    else if w > prev { trend = .up }
                    else { trend = .same }
                } else {
                    trend = .first
                }
                lastKnownWeight = w
            }
            let today = isCurrentMonth && day == todayDay
            allDays.append(CalendarDay(day: day, weight: weight, trend: trend, isToday: today))
        }
        // Trailing empty cells to fill last row
        let remainder = allDays.count % 7
        if remainder > 0 {
            for _ in 0..<(7 - remainder) {
                allDays.append(CalendarDay(day: 0, weight: nil, trend: .none, isToday: false))
            }
        }
        // Split into rows
        var rows: [[CalendarDay]] = []
        for i in stride(from: 0, to: allDays.count, by: 7) {
            rows.append(Array(allDays[i..<min(i + 7, allDays.count)]))
        }
        
        return WeightCalendarEntry(
            date: date,
            monthTitle: monthTitle,
            weekdayHeaders: weekdayHeaders,
            calendarRows: rows,
            unit: unit,
            latestWeight: weights.last?.weight,
            goalWeight: goalWeight,
            entryCount: entryCount
        )
    }
}

// MARK: - Calendar Day Cell View

struct CalendarDayCellView: View {
    let day: CalendarDay
    let showWeight: Bool
    
    private var dayTextColor: Color {
        if day.isToday { return .white }
        if day.weight != nil { return day.trend.color }
        return Color.white.opacity(0.4)
    }
    
    var body: some View {
        if day.day == 0 {
            Color.clear
                .frame(maxWidth: .infinity, minHeight: 28)
        } else {
            VStack(spacing: 1) {
                ZStack {
                    // Today highlight
                    if day.isToday {
                        Circle()
                            .fill(Color(red: 0.4, green: 0.33, blue: 0.96))
                            .frame(width: 24, height: 24)
                    }
                    // Entry background (non-today)
                    else if day.weight != nil {
                        Circle()
                            .fill(day.trend.color.opacity(0.25))
                            .frame(width: 24, height: 24)
                    }
                    
                    Text("\(day.day)")
                        .font(.system(size: 11, weight: day.isToday ? .bold : (day.weight != nil ? .semibold : .regular)))
                        .foregroundColor(dayTextColor)
                }
                
                // Trend dot
                if day.weight != nil {
                    Circle()
                        .fill(day.trend.color)
                        .frame(width: 4, height: 4)
                } else {
                    Spacer().frame(height: 4)
                }
                
                // Weight value (large widget only)
                if showWeight, let w = day.weight {
                    Text(String(format: "%.0f", w))
                        .font(.system(size: 7, weight: .medium))
                        .foregroundColor(day.trend.color)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, minHeight: showWeight ? 42 : 32)
        }
    }
}

// MARK: - Widget Entry View

struct SummaryWidgetEntryView: View {
    var entry: CalendarProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(spacing: 4) {
            // Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.monthTitle)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    if family == .systemLarge {
                        HStack(spacing: 8) {
                            Label("\(entry.entryCount) kayıt", systemImage: "scalemass")
                                .font(.system(size: 10))
                                .foregroundColor(Color.white.opacity(0.6))
                            if let latest = entry.latestWeight {
                                Text(String(format: "Son: %.1f %@", latest, entry.unit))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(red: 0.6, green: 0.55, blue: 1.0))
                            }
                        }
                    }
                }
                Spacer()
                if family == .systemMedium, let latest = entry.latestWeight {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(String(format: "%.1f", latest))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.6, green: 0.55, blue: 1.0))
                        Text(entry.unit)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                }
            }
            .padding(.bottom, 2)
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(entry.weekdayHeaders, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            ForEach(0..<entry.calendarRows.count, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    ForEach(entry.calendarRows[rowIndex]) { day in
                        CalendarDayCellView(day: day, showWeight: family == .systemLarge)
                    }
                }
            }
            
            // Legend (large only)
            if family == .systemLarge {
                Spacer(minLength: 4)
                HStack(spacing: 12) {
                    legendItem(color: Color(red: 0.2, green: 0.78, blue: 0.4), label: "Düşüş")
                    legendItem(color: Color(red: 0.95, green: 0.3, blue: 0.3), label: "Artış")
                    legendItem(color: .gray, label: "Aynı")
                    if entry.goalWeight > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 8))
                                .foregroundColor(Color(red: 0.6, green: 0.55, blue: 1.0))
                            Text(String(format: "%.1f %@", entry.goalWeight, entry.unit))
                                .font(.system(size: 9))
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                    }
                }
            }
        }
        .padding(12)
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 3) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(Color.white.opacity(0.5))
        }
    }
}

// MARK: - Widget Definition

struct summaryWidget: Widget {
    let kind: String = "summaryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarProvider()) { entry in
            if #available(iOS 17.0, *) {
                SummaryWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color(red: 0.08, green: 0.08, blue: 0.12)
                    }
            } else {
                SummaryWidgetEntryView(entry: entry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.08, green: 0.08, blue: 0.12))
            }
        }
        .configurationDisplayName("Kilo Takvimi")
        .description("Aylık kilo kayıtlarınızı takvim görünümünde takip edin.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Preview

struct summaryWidget_Previews: PreviewProvider {
    static var previews: some View {
        let entry = WeightCalendarEntry(
            date: Date(),
            monthTitle: "Temmuz 2026",
            weekdayHeaders: ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pz"],
            calendarRows: [],
            unit: "kg",
            latestWeight: 78.5,
            goalWeight: 72.0,
            entryCount: 5
        )
        SummaryWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        SummaryWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
