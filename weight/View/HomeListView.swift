//
//  HomeListView.swift
//  weight
//
//  Created by berkay on 18.09.2022.
//

import SwiftUI
import SwiftUICharts
import HalfASheet

struct HomeListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var isSheetActive: Bool = false
    @State private var isAddAlertActive: Bool = false
    @State private var lastWeight: Int = 40
    @State private var lastWeightTail: Int = 0
    @State private var date = Date()
    
    @FetchRequest var weights: FetchedResults<WeightEntity>

    @AppStorage("dateFilter") private var dateFilter: Int = 0
    @AppStorage("goal") private var goal: Int = 40
    @AppStorage("goalTail") private var goalTail: Int = 0
    @AppStorage("weightUnit") private var unit: String = "kg"
    
    init(filterIndex: Int) {
        var filter: NSPredicate
        if filterIndex == 0 {
            filter = NSPredicate(format: "time >= %@", Calendar.current.startOfDay(for: Date() - 86500) as CVarArg)
        } else {
            filter = NSPredicate(format: "time >= %@", Calendar.current.startOfDay(for: Date() - 1000000) as CVarArg)
        }
        _weights = FetchRequest<WeightEntity>(sortDescriptors: [SortDescriptor(\.time, order: .forward)], predicate: filter)
    }

    var body: some View {
        List {
            Menu {
                Button("0") {
                    dateFilter = 0
                }
                Button("1") {
                    dateFilter = 1
                }
                Button("2") {
                    dateFilter = 2
                }
            } label: {
                Label("\(dateFilter)", systemImage: "calendar")
            }.padding()
            HStack {
                VStack {
                    Text("Initial").font(.callout).fontWeight(.bold)
                    Text(String(format: "%.1f \(unit)", weights.first?.weight ?? 0)).fontWeight(.light).font(.title3)
                }
                Spacer()
                Divider()
                Spacer()
                VStack {
                    Text("Last").font(.callout).fontWeight(.bold)
                    Text(String(format: "%.1f \(unit)", weights.last?.weight ?? 0)).fontWeight(.light).font(.title3)
                }
                Spacer()
                Divider()
                Spacer()
                VStack {
                    let difference = (weights.last?.weight ?? 0) - (weights.first?.weight ?? 0)
                    let color: Color = difference == 0 ? Color.primary : difference < 0 ? .green : .red
                    Text("Difference").font(.callout).fontWeight(.bold).foregroundColor(color)
                    Text(String(format: "%.1f \(unit)", difference)).fontWeight(.bold).font(.title3).foregroundColor(color)
                }
            }.padding()
            Section {
                Button {
                    isSheetActive.toggle()
                } label: {
                    HStack {
                        Text("Add weight")
                        Spacer()
                        Image(systemName: "plus")
                    }.padding().foregroundColor(.white)
                }
            }.listRowBackground(Color(0xFF3E2AD1))
            if weights.count > 0 {
                Section("CHART") {
                    VStack(spacing: 16) {
                        HStack {
                            Spacer()
                            Image(systemName: "square.fill").foregroundColor(.green)
                            Text("Mean").fontWeight(.light)
                            Image(systemName: "square.fill").foregroundColor(.red)
                            Text("Goal").fontWeight(.light)
                            Image(systemName: "square.fill").foregroundColor(.blue)
                            Text("Weight").fontWeight(.light)
                            Spacer()
                        }
                            .font(.callout)
                            .padding(.top, 16)
                        let data = parseWeights(weights: weights)
                        LineChart(chartData: data)
                            .pointMarkers(chartData: data)
                            .touchOverlay(chartData: data,
                            formatter: numberFormatter)
                            .yAxisPOI(chartData: data,
                            markerName: "",
                            markerValue: Double(goal) + (Double(goalTail) * 0.1),
                            lineColour: .red,
                            strokeStyle: StrokeStyle(lineWidth: 3, dash: [5, 10]))
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
                            .infoBox(chartData: data, height: 1)
                            .headerBox(chartData: data)
                            .id(data.id)
                            .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 300, maxHeight: 600, alignment: .center)
                            .padding(.horizontal)
                    }
                }
            }
        }
            .onAppear {
            if let lastWeightDouble = weights.last {
                lastWeight = Int(lastWeightDouble.weight)
                lastWeightTail = Int((lastWeightDouble.weight - Double(lastWeight)) * 10.0)
            }
        }
            .sheet(isPresented: $isSheetActive) {
            ZStack {
                VStack {
                    Section {
                        HStack {
                            Text("Add Weight").font(.title2).fontWeight(.bold)
                            Spacer()
                            Button {
                                isSheetActive.toggle()
                            } label: {
                                Image(systemName: "x.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.gray)
                            }
                        }
                            .padding(24)

                    }
                        .padding(.top, 32)
                    Section {
                        DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date).onChange(of: date) { newValue in
                            date = newValue
                        }
                    }
                        .padding()
                        .background(light: Color(0xFF000000).opacity(0.05), dark: Color(0xFF000000).opacity(0.25))
                        .cornerRadius(8)
                        .padding()
                    Section {
                        Button {
                            isAddAlertActive.toggle()
                        } label: {
                            HStack {
                                Text("Weight").foregroundColor(light: .black, dark: .white)
                                Spacer()
                                HStack {
                                    Text("\(lastWeight).\(lastWeightTail) \(unit)")
                                    Image(systemName: "chevron.right")
                                }.foregroundColor(.gray)
                            }
                        }
                    }
                        .padding()
                        .background(light: Color(0xFF000000).opacity(0.05), dark: Color(0xFF000000).opacity(0.25))
                        .cornerRadius(8)
                        .padding()
                    HStack {
                        Button {
                            let weight = Double(lastWeight) + (Double(lastWeightTail) * 0.1)
                            WeightDataController().startAddingWeightProcess(weight: weight, when: date, weights: weights, context: managedObjectContext)
                            isSheetActive.toggle()
                        } label: {
                            Text("Save")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .font(.title3)
                        }.cornerRadius(16)
                    }.padding()
                    Spacer()
                }.onAppear {
                    date = Date()
                }
                HalfASheet(isPresented: $isAddAlertActive, title: "Current Weight (\(unit))") {
                    HStack(spacing: 0) {
                        ResizeablePicker(selection: $lastWeight, data: Array(0..<770)).onChange(of: lastWeight) { newValue in
                            lastWeight = newValue
                        }
                        ResizeablePicker(selection: $lastWeightTail, data: Array(0..<10)).onChange(of: lastWeightTail) { newValue in
                            lastWeightTail = newValue
                        }
                    }
                }
                    .height(.fixed(320))
                    .disableDragToDismiss
            }
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
}
