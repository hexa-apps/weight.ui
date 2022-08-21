//
//  HomeView.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI
import SwiftUICharts

struct HomeView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.time, order: .reverse)]) var weights: FetchedResults<WeightEntity>

    let data: LineChartData = weekOfData(length: 2)
    @AppStorage("weightUnit") private var unit: String = "kg"

    var body: some View {
        NavigationView {
            List {
                Section("ESSENTIALS") {
                    HStack {
                        VStack {
                            Text("Initial").font(.callout).fontWeight(.bold)
                            Text(String(format: "%.1f \(unit)", 105.0))
                        }
                        Spacer()
                        Divider()
                        Spacer()
                        VStack {
                            Text("Last").font(.callout).fontWeight(.bold)
                            Text(String(format: "%.1f \(unit)", 98.3))
                        }
                        Spacer()
                        Divider()
                        Spacer()
                        VStack {
                            Text("Difference").font(.callout).fontWeight(.bold)
                            Text(String(format: "%.1f \(unit)", 6.7))
                        }

                    }.padding()
                }
                Section {
                    Button {
                        print("add weight")
                    } label: {
                        HStack {
                            Text("Add current weight")
                            Spacer()
                            Image(systemName: "plus")
                        }.padding().foregroundColor(.white)
                    }
                }.listRowBackground(Color.blue)
                if data.dataSets.dataPoints.count > 0 {
                    Section("CHART") {
                        VStack(spacing: 16) {
                            HStack {
                                Spacer()
                                Image(systemName: "square.fill").foregroundColor(.green)
                                Text("Mean")
                                Image(systemName: "square.fill").foregroundColor(.red)
                                Text("Goal")
                                Image(systemName: "square.fill").foregroundColor(.blue)
                                Text("Weight")
                                Spacer()
                            }.padding(.top, 16)
                            if data.dataSets.dataPoints.count == 1 {
                                Text("1")
                            } else {
                                LineChart(chartData: data)
                                //                                .extraLine(chartData: data,
                                //                                           legendTitle: "Test",
                                //                                           datapoints: extraLineData,
                                //                                           style: extraLineStyle)
                                .pointMarkers(chartData: data)
                                    .touchOverlay(chartData: data,
                                    formatter: numberFormatter)
                                    .yAxisPOI(chartData: data,
                                    markerName: "",
                                    markerValue: 90,
                                    //                                      labelColour: .red,
                                    lineColour: .red,
                                    strokeStyle: StrokeStyle(lineWidth: 3, dash: [5, 10]))
                                //                                .yAxisPOI(chartData: data,
                                //                                          markerName: "Step Count Aim",
                                //                                          markerValue: 15_000,
                                //                                          labelPosition: .center(specifier: "%.0f",
                                //                                                                 formatter: numberFormatter),
                                //                                          labelColour: Color.black,
                                //                                          labelBackground: Color(red: 1.0, green: 0.75, blue: 0.25),
                                //                                          lineColour: Color(red: 1.0, green: 0.75, blue: 0.25),
                                //                                          strokeStyle: StrokeStyle(lineWidth: 3, dash: [5,10]))
                                //                                .yAxisPOI(chartData: data,
                                //                                          markerName: "Minimum Recommended",
                                //                                          markerValue: 10_000,
                                //                                          labelPosition: .center(specifier: "%.0f",
                                //                                                                 formatter: numberFormatter),
                                //                                          labelColour: Color.white,
                                //                                          labelBackground: Color(red: 0.25, green: 0.75, blue: 1.0),
                                //                                          lineColour: Color(red: 0.25, green: 0.75, blue: 1.0),
                                //                                          strokeStyle: StrokeStyle(lineWidth: 3, dash: [5,10]))
                                //                                .xAxisPOI(chartData: data,
                                //                                          markerName: "Worst",
                                //                                          markerValue: 2,
                                //                                          dataPointCount: data.dataSets.dataPoints.count,
                                //                                          lineColour: .red)
                                .averageLine(chartData: data,
                                    labelPosition: .yAxis(specifier: "",
                                        formatter: numberFormatter),
                                    lineColour: .green,
                                    strokeStyle: StrokeStyle(lineWidth: 3, dash: [5, 10]))
                                    .xAxisGrid(chartData: data)
                                    .yAxisGrid(chartData: data)
                                    .xAxisLabels(chartData: data)
                                    .yAxisLabels(chartData: data,
                                    formatter: numberFormatter,
                                    colourIndicator: .style(size: 12))
                                //                                .extraYAxisLabels(chartData: data, colourIndicator: .style(size: 12))
                                .infoBox(chartData: data, height: 1)
                                    .headerBox(chartData: data)
                                //                                .legends(chartData: data, columns: [GridItem(.flexible()), GridItem(.flexible())])
                                .id(data.id)
                                    .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
                                    .padding(.horizontal)
                            }

                        }

                    }
                }

            }.navigationTitle("Summary")
        }
    }

    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }

//        private var extraLineData: [ExtraLineDataPoint] {
//            [ExtraLineDataPoint(value: 8000),
//             ExtraLineDataPoint(value: 10000),
//             ExtraLineDataPoint(value: 15000),
//             ExtraLineDataPoint(value: 9000)]
//        }
//        private var extraLineStyle: ExtraLineStyle {
//            ExtraLineStyle(lineColour: ColourStyle(colour: .blue),
//                           lineType: .line,
//                           yAxisTitle: "Another Axis")
//        }

    static func weekOfData(length: Int) -> LineChartData {
        let dataPointsSource: [LineChartDataPoint] = [
            LineChartDataPoint(value: 98.1, xAxisLabel: "M", description: "Monday", pointColour: PointColour(border: .blue, fill: .blue)),
            LineChartDataPoint(value: 99.3, xAxisLabel: "T", description: "Tuesday", pointColour: PointColour(border: .blue, fill: .blue)),
            LineChartDataPoint(value: 99.4, xAxisLabel: "W", description: "Wednesday", pointColour: PointColour(border: .blue, fill: .blue)),
            LineChartDataPoint(value: 97.7, xAxisLabel: "T", description: "Thursday", pointColour: PointColour(border: .blue, fill: .blue)),
            LineChartDataPoint(value: 98.1, xAxisLabel: "F", description: "Friday", pointColour: PointColour(border: .blue, fill: .blue)),
            LineChartDataPoint(value: 97.8, xAxisLabel: "S", description: "Saturday", pointColour: PointColour(border: .blue, fill: .blue)),
            LineChartDataPoint(value: 97.7, xAxisLabel: "S", description: "Sunday", pointColour: PointColour(border: .blue, fill: .blue)),
        ]
        var dataPoints: [LineChartDataPoint] = []
        if length == 1 {
            dataPoints.append(dataPointsSource[0])
            dataPoints.append(dataPointsSource[0])
        } else if length > 1 {
            dataPoints = dataPointsSource
        }
        let data: LineDataSet = LineDataSet(dataPoints: dataPoints,
            legendTitle: "Steps",
            pointStyle: PointStyle(fillColour: .blue, pointType: .filled),
            style: LineStyle(lineColour: ColourStyle(colour: .blue), lineType: .curvedLine))

        let gridStyle = GridStyle(numberOfLines: 5,
            lineColour: Color(.lightGray).opacity(0.5),
            lineWidth: 1,
            dash: [8],
            dashPhase: 0)

        let chartStyle = LineChartStyle(infoBoxPlacement: .infoBox(isStatic: false),
            infoBoxContentAlignment: .horizontal,
            infoBoxBorderColour: Color.primary,
            infoBoxBorderStyle: StrokeStyle(lineWidth: 1),

            markerType: .vertical(attachment: .line(dot: .style(DotStyle(fillColour: .white, lineColour: .blue)))),

            xAxisGridStyle: gridStyle,
            xAxisLabelPosition: .bottom,
            xAxisLabelColour: Color.primary,
            xAxisLabelsFrom: .dataPoint(rotation: .degrees(0)),
//                                            xAxisTitle          : "xAxisTitle",

            yAxisGridStyle: gridStyle,
            yAxisLabelPosition: .leading,
            yAxisLabelColour: Color.primary,
            yAxisNumberOfLabels: 5,

            baseline: .minimumWithMaximum(of: 85),
            topLine: .maximum(of: data.maxValue() + 5),

            globalAnimation: .easeOut(duration: 1))



        let chartData = LineChartData(dataSets: data,
//                                          metadata       : ChartMetadata(title: "Step Count", subtitle: "Over a Week"),
            chartStyle: chartStyle)

        defer {
            chartData.touchedDataPointPublisher
                .map(\.value)
                .sink { value in
                var dotStyle: DotStyle
                if value < 90 {
                    dotStyle = DotStyle(fillColour: .red)
                } else if value >= 90 && value <= 105 {
                    dotStyle = DotStyle(fillColour: .blue)
                } else {
                    dotStyle = DotStyle(fillColour: .green)
                }
                withAnimation(.linear(duration: 0.5)) {
                    chartData.chartStyle.markerType = .vertical(attachment: .line(dot: .style(dotStyle)))
                }
            }
                .store(in: &chartData.subscription)
        }

        return chartData

    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
