//
//  Utility.swift
//  weight
//
//  Created by berkay on 17.08.2022.
//

import SwiftUI
import SwiftUICharts

extension Color {
    init(_ hex: UInt, alpha: Double = 1) {
        self.init(
                .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()

    public var rawValue: String {
        Date.formatter.string(from: self)
    }

    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}

func formattedDate(date: Date?, withYear: Bool) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM"
    if withYear {
        dateFormatter.dateFormat = "dd.MM.yyyy"
    }
    guard let date = date else {
        return ""
    }
    return dateFormatter.string(from: date)
}

func parseWeightsForHistory(weights: FetchedResults<WeightEntity>) -> [HistoryGroupModel] {
    let reversed = weights.reversed()
    let weightValues = reversed.map { $0.weight }
    var result: [HistoryModel] = []
    for (index, weight) in reversed.enumerated() {
        let weightValue = weight.weight
        let stringDate = formattedDate(date: weight.time, withYear: true)
        if index == reversed.count - 1 {
            result.append(HistoryModel(weight: weightValue, date: stringDate, icon: "flag.circle.fill", lightColor: Color(0xFF3E2AD1), darkColor: Color(0xFF6753F4), id: weight.id))
        } else if weight.weight == weightValues[index + 1] {
            result.append(HistoryModel(weight: weightValue, date: stringDate, icon: "minus.circle.fill", lightColor: .gray, darkColor: .gray, id: weight.id))
        } else if weight.weight > weightValues[index + 1] {
            result.append(HistoryModel(weight: weightValue, date: stringDate, icon: "arrow.up.circle.fill", lightColor: .red, darkColor: .red, id: weight.id))
        } else {
            result.append(HistoryModel(weight: weightValue, date: stringDate, icon: "arrow.down.circle.fill", lightColor: .green, darkColor: .green, id: weight.id))
        }
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    let groupedHistory = Dictionary(grouping: result) { (history) -> DateComponents in
        let weightDate = dateFormatter.date(from: history.date) ?? Date()
        let date = Calendar.current.dateComponents([.year, .month], from: weightDate)
        return date
    }
    return groupedHistory.sorted {
        $0.key.year! == $1.key.year! ? $0.key.month! > $1.key.month!: $0.key.year! > $1.key.year!
    }.map { HistoryGroupModel(title: "\($0.key.year ?? 2023), \(DateFormatter().monthSymbols[($0.key.month ?? 4) - 1])", weights: $0.value) }
}

func filterWeightsForChart(weight: WeightEntity, dateRange: ClosedRange<Date>? = nil) -> Bool {
    if let dateRange {
        if let date = weight.time {
            return dateRange.contains(date)
        }
        return false
    }
    return true
}

func getDateRange(filterIndex: Int) -> ClosedRange<Date>? {
    if filterIndex == 3 {
        return nil
    }
    let currentCalendar = Calendar.current
    let components = currentCalendar.dateComponents([.day, .month, .year, .weekday], from: Date.now)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    switch filterIndex {
    case 0: // This week
        let firstDay = (components.day ?? 0) - (components.weekday ?? 0) + 2
        let lastDay = firstDay + 6
        let firstArg = dateFormatter.date(from: "\(firstDay).\(components.month ?? 11).\(components.year ?? 2022)") ?? Date.now
        let lastArg = dateFormatter.date(from: "\(lastDay).\(components.month ?? 11).\(components.year ?? 2022)") ?? Date.now
        return firstArg...lastArg
    case 1: // This month
        let firstArg = dateFormatter.date(from: "01.\(components.month ?? 11).\(components.year ?? 2022)") ?? Date.now
        let lastArg = dateFormatter.date(from: "\(lastDay(of: components.month ?? 11, year: components.year ?? 2022)).\(components.month ?? 11).\(components.year ?? 2022)") ?? Date.now
        return firstArg...lastArg
    case 2: // Last 30 days
        let lastArg = Date.now
        let firstArg = currentCalendar.date(byAdding: .day, value: -30, to: lastArg) ?? Date.now
        return firstArg...lastArg
    default:
        return Date.now...Date.now
    }
}

func parseWeights(weights: FetchedResults<WeightEntity>, filterIndex: Int) -> LineChartData {
    let filteredWeights = weights.filter { weight in
        if (filterIndex == 3) {
            return filterWeightsForChart(weight: weight)
        }
        return filterWeightsForChart(weight: weight, dateRange: getDateRange(filterIndex: filterIndex))
    }
    var weightValues = filteredWeights.map { $0.weight }
    let goal: Int = UserDefaults.standard.integer(forKey: "goal")
    let goalTail: Int = UserDefaults.standard.integer(forKey: "goalTail")
    let goalValue: Double = Double(goal) + (Double(goalTail) / 10)
    weightValues.append(goalValue)
    weightValues.sort()
    var dataPoints: [LineChartDataPoint] = []
    if filteredWeights.count == 1 {
        let timeString = formattedDate(date: filteredWeights[0].time, withYear: false)
        dataPoints.append(LineChartDataPoint(value: filteredWeights[0].weight, xAxisLabel: timeString, description: timeString, date: filteredWeights[0].time))
        dataPoints.append(LineChartDataPoint(value: filteredWeights[0].weight, xAxisLabel: timeString, description: timeString, date: filteredWeights[0].time))
    } else {
        dataPoints = filteredWeights.map {
            let timeString = formattedDate(date: $0.time, withYear: false)
            return LineChartDataPoint(value: $0.weight, xAxisLabel: timeString, description: timeString, date: $0.time)
        }
    }
    let lineDataSet: LineDataSet = LineDataSet(
        dataPoints: dataPoints,
        pointStyle: PointStyle(fillColour: .blue, pointType: .filled),
        style: LineStyle(lineColour: ColourStyle(colour: .blue), lineType: .curvedLine)
    )
    let gridStyle: GridStyle = GridStyle(
        numberOfLines: 5,
        lineColour: Color(.lightGray).opacity(0.5),
        lineWidth: 1,
        dash: [8],
        dashPhase: 0
    )
    let chartStyle: LineChartStyle = LineChartStyle(
        infoBoxPlacement: .infoBox(isStatic: false),
        infoBoxContentAlignment: .horizontal,
        infoBoxBorderColour: Color.primary,
        infoBoxBorderStyle: StrokeStyle(lineWidth: 0),
        markerType: .vertical(attachment: .line(dot: .style(DotStyle(fillColour: .white, lineColour: .blue)))),
        xAxisGridStyle: gridStyle,
        xAxisLabelPosition: .bottom,
        xAxisLabelColour: Color.primary,
        xAxisLabelsFrom: .dataPoint(rotation: .degrees(45)),
        yAxisGridStyle: gridStyle,
        yAxisLabelPosition: .leading,
        yAxisLabelColour: Color.primary,
        yAxisNumberOfLabels: 5,
        baseline: .minimumWithMaximum(of: (weightValues.first ?? 0) - 1),
        topLine: .maximum(of: (weightValues.last ?? 0) + 1),
        globalAnimation: .easeOut(duration: 1)
    )
    let chartData: LineChartData = LineChartData(dataSets: lineDataSet, chartStyle: chartStyle)
    defer {
        chartData.touchedDataPointPublisher
            .map(\.value)
            .sink { value in
            var dotStyle: DotStyle
            if value < 90 {
                dotStyle = DotStyle(fillColour: .green)
            } else {
                dotStyle = DotStyle(fillColour: .red)
            }
            withAnimation(.linear(duration: 0.5)) {
                chartData.chartStyle.markerType = .vertical(attachment: .line(dot: .style(dotStyle)))
            }
        }.store(in: &chartData.subscription)
    }
    return chartData
}

func setReminder(isChecked: Bool, date: Date) {
    let center = UNUserNotificationCenter.current()
    center.removeAllDeliveredNotifications()
    center.removeAllPendingNotificationRequests()
    if isChecked {
        let content = UNMutableNotificationContent()
        content.title = "Heyyo"
        content.body = "Let's reach your goals"
        content.sound = .default
        var triggerDate = DateComponents()
        let calendar = Calendar.current
        triggerDate.hour = calendar.component(.hour, from: date)
        triggerDate.minute = calendar.component(.minute, from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Success")
            }
        }
    }
}

func lastDay(of month: Int, year: Int) -> Int {
    let calendar = Calendar.current
    var components = DateComponents(calendar: calendar, year: year, month: month)
    components.setValue(month + 1, for: .month)
    components.setValue(0, for: .day)
    let date = calendar.date(from: components) ?? Date.now
    return calendar.component(.day, from: date)
}

func getCSVTitle() -> String? {
    var csvTitle: String?
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy"
    csvTitle = "HexaWeight_\(dateFormatter.string(from: Date.now)).csv"
    return csvTitle
}

func exportCSVDocument(weights: FetchedResults<WeightEntity>) -> CSVDocument {
    var content: String = "time,weight\n"
    weights.forEach { weight in
        content += "\(weight.time ?? Date.now),\(weight.weight)\n"
    }
    return CSVDocument(content: content)
}

// MARK: - Liquid Glass Components

struct LiquidBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base background
            if colorScheme == .dark {
                Color(red: 0.05, green: 0.05, blue: 0.1)
            } else {
                Color(red: 0.98, green: 0.96, blue: 0.99)
            }
            
            // Organic blobs
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                
                Circle()
                    .fill(Color(red: 0.4, green: 0.33, blue: 0.96).opacity(colorScheme == .dark ? 0.4 : 0.5))
                    .frame(width: width * 0.8)
                    .offset(x: animate ? width * 0.1 : -width * 0.2, y: animate ? -height * 0.1 : -height * 0.2)
                    .blur(radius: 60)
                
                Circle()
                    .fill(Color(red: 0.95, green: 0.3, blue: 0.5).opacity(colorScheme == .dark ? 0.3 : 0.4))
                    .frame(width: width * 0.9)
                    .offset(x: animate ? width * 0.2 : width * 0.4, y: animate ? height * 0.4 : height * 0.3)
                    .blur(radius: 80)
                
                Circle()
                    .fill(Color(red: 0.2, green: 0.78, blue: 0.9).opacity(colorScheme == .dark ? 0.2 : 0.4))
                    .frame(width: width * 0.7)
                    .offset(x: animate ? -width * 0.1 : -width * 0.3, y: animate ? height * 0.7 : height * 0.5)
                    .blur(radius: 70)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.4), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 16) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }
    
    @ViewBuilder
    func hideScrollContentBackground() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self.onAppear {
                UITableView.appearance().backgroundColor = .clear
            }
        }
    }
}
