//
//  HomeView.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI
import SwiftUICharts

struct HomeView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.time, order: .reverse)]) var things: FetchedResults<WeightEntity>

    let averageLineData: MultiLineChartData = getMultiLineData(isAverage: true)
    let multiLineData: MultiLineChartData = getMultiLineData(isAverage: false)

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {

                        VStack {
                            Text("Initial").font(.callout).fontWeight(.bold)
                            Text(String(format: "%.1f kg", 105))
                        }
                        Spacer()
                        Divider()
                        Spacer()
                        VStack {
                            Text("Last").font(.callout).fontWeight(.bold)
                            Text(String(format: "%.1f kg", 98.3))
                        }
                        Spacer()
                        Divider()
                        Spacer()
                        VStack {
                            Text("Difference").font(.callout).fontWeight(.bold)
                            Text(String(format: "%.1f kg", 6.7))
                        }

                    }.padding()
                }
                Section {
                    Button {
                        //
                    } label: {
                        HStack {
                            Text("Add current weight")
                            Spacer()
                            Image(systemName: "plus")
                        }.padding().foregroundColor(.white)
                    }
                }.listRowBackground(Color.purple)
                Section {
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
                        }
                        MultiLineChart(chartData: multiLineData)
                            .averageLine(chartData: averageLineData, lineColour: .green)
                            .frame(minHeight: 150)
                            .padding()
                    }
                }
            }.navigationTitle("Summary")
        }
    }

    static func getMultiLineData(isAverage: Bool) -> MultiLineChartData {
        if isAverage {
            let data = MultiLineChartData(
                dataSets: MultiLineDataSet(dataSets: [
                    LineDataSet(dataPoints: [LineChartDataPoint(value: 105, xAxisLabel: "F", description: "Friday"),
                        LineChartDataPoint(value: 97, xAxisLabel: "S", description: "Saturday"),
                        LineChartDataPoint(value: 99, xAxisLabel: "S", description: "Sunday")],
                        pointStyle: PointStyle(),
                        style: LineStyle(lineColour: ColourStyle(colour: .blue))
                    )
                    ]))
            return data
        } else {
            let data = MultiLineChartData(
                dataSets: MultiLineDataSet(dataSets: [
                    LineDataSet(dataPoints: [LineChartDataPoint(value: 90, xAxisLabel: "F", description: "Friday"),
                        LineChartDataPoint(value: 90, xAxisLabel: "S", description: "Saturday"),
                        LineChartDataPoint(value: 90, xAxisLabel: "S", description: "Sunday")]
                        , pointStyle: PointStyle(),
                        style: LineStyle(lineColour: ColourStyle(colour: .red))
                    ),
                    LineDataSet(dataPoints: [LineChartDataPoint(value: 105, xAxisLabel: "F", description: "Friday"),
                        LineChartDataPoint(value: 97, xAxisLabel: "S", description: "Saturday"),
                        LineChartDataPoint(value: 99, xAxisLabel: "S", description: "Sunday")],
                                pointStyle: PointStyle(pointSize: 5, borderColour: .blue, fillColour: .white, lineWidth: 1, pointType: .outline, pointShape: .circle),
                                style: LineStyle(lineColour: ColourStyle(colour: .blue), lineType: .curvedLine)
                    )
                    ]))

            return data
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
