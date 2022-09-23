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

func parseWeightsForHistory(weights: FetchedResults<WeightEntity>) -> [HistoryModel] {
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
    return result
}

func filterWeightsForChart(weight: WeightEntity, dateRange: ClosedRange<Date>?) -> Bool {
    if let dateRange = dateRange {
        if let date = weight.time {
            return dateRange.contains(date)
        }
        return false
    }
    return false
}

func getDateRange(filterIndex: Int) -> ClosedRange<Date> {
    let currentCalendar = Calendar.current
    let components = currentCalendar.dateComponents([.day, .month, .year, .weekday], from: Date.now)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    if filterIndex == 0 {
        let firstDay = (components.day ?? 0) - (components.weekday ?? 0) + 2
        let lastDay = firstDay + 6
        let firstArg = dateFormatter.date(from: "\(firstDay).\(components.month ?? 11).\(components.year ?? 2022)") ?? Date.now
        let lastArg = dateFormatter.date(from: "\(lastDay).\(components.month ?? 11).\(components.year ?? 2022)") ?? Date.now
        return firstArg...lastArg
    } else if filterIndex == 1 {
        let firstArg = dateFormatter.date(from: "01.\(components.month ?? 11).\(components.year ?? 2022)") ?? Date.now
        let lastArg = dateFormatter.date(from: "\(lastDay(of: components.month ?? 11, year: components.year ?? 2022)).\(components.month ?? 11).\(components.year ?? 2022)") ?? Date.now
        return firstArg...lastArg
    } else {
        return Date.now...Date.now
    }
}

func parseWeights(weights: FetchedResults<WeightEntity>, filterIndex: Int) -> LineChartData {
    let filteredWeights = weights.filter { weight in
        return filterWeightsForChart(weight: weight, dateRange: getDateRange(filterIndex: filterIndex) )
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
    } else {
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
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
