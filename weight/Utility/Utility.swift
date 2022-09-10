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

func parseWeights(weights: FetchedResults<WeightEntity>) -> LineChartData {
    var weightValues = weights.map { $0.weight }
    let goal: Int = UserDefaults.standard.integer(forKey: "goal")
    let goalTail: Int = UserDefaults.standard.integer(forKey: "goalTail")
    let goalValue: Double = Double(goal) + (Double(goalTail) / 10)
    weightValues.append(goalValue)
    weightValues.sort()
    var dataPoints: [LineChartDataPoint] = []
    if weights.count == 1 {
        let timeString = formattedDate(date: weights[0].time, withYear: false)
        dataPoints.append(LineChartDataPoint(value: weights[0].weight, xAxisLabel: timeString, description: timeString, date: weights[0].time))
        dataPoints.append(LineChartDataPoint(value: weights[0].weight, xAxisLabel: timeString, description: timeString, date: weights[0].time))
    } else {
        dataPoints = weights.map {
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
