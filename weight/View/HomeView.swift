//
//  HomeView.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI
import SwiftUICharts
import HalfASheet

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    let weights: FetchedResults<WeightEntity>

    @AppStorage("weightUnit") private var unit: String = "kg"
    @AppStorage("isOnboardingView") private var onboardingViewShow = true

    @State private var isSheetActive: Bool = false
    @State private var isAddAlertActive: Bool = false
    @State private var lastWeight: Int = 40
    @State private var lastWeightTail: Int = 0

    @State private var goal: Int = UserDefaults.standard.integer(forKey: "goal")
    @State private var goalTail: Int = UserDefaults.standard.integer(forKey: "goalTail")

    @State private var date = Date()

    var body: some View {
        NavigationView {
            List {
//                Section("ESSENTIALS") {
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
                        Text("Difference").font(.callout).fontWeight(.bold)
                        Text(String(format: "%.1f \(unit)", (weights.last?.weight ?? 0) - (weights.first?.weight ?? 0))).fontWeight(.light).font(.title3)
                    }

                }.padding()
//                }
                Section {
                    Button {
                        isSheetActive.toggle()
                    } label: {
                        HStack {
                            Text("Add current weight")
                            Spacer()
                            Image(systemName: "plus")
                        }.padding().foregroundColor(.white)
                    }
                }.listRowBackground(Color.blue)
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
                                .frame(minWidth: 150, maxWidth: 900, minHeight: 150, idealHeight: 500, maxHeight: 600, alignment: .center)
                                .padding(.horizontal)
                        }
                    }
                }

            }
                .navigationTitle("Summary")

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
                    Section() {
                        DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date).onChange(of: date) { newValue in
                            date = newValue
                        }
                    }
                        .padding()
                        .background(light: Color(0xFF000000).opacity(0.05), dark: Color(0xFF000000).opacity(0.25))
                        .cornerRadius(8)
                        .padding()
                    Section() {
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
                        Spacer()
                        Button {
                            isSheetActive.toggle()
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(.red)
                                .font(.title3)
                        }.cornerRadius(16)
                    }.padding()
                    Spacer()
                }.onAppear {
                    date = Date()
                }
                HalfASheet(isPresented: $isAddAlertActive) {
                    GeometryReader { geometry in
                        VStack {
                            Text("Current Weight (\(unit))").fontWeight(.bold).padding(.top, 16)
                            HStack(spacing: 0) {
                                ResizeablePicker(selection: $lastWeight, data: Array(0..<770)).onChange(of: lastWeight) { newValue in
                                    lastWeight = newValue
                                }
                                ResizeablePicker(selection: $lastWeightTail, data: Array(0..<10)).onChange(of: lastWeightTail) { newValue in
                                    lastWeightTail = newValue
                                }
                            }
                        }
                    }
                }
                    .disableDragToDismiss
            }


        }
            .fullScreenCover(isPresented: $onboardingViewShow) {
            OnboardingView(onboardingShow: $onboardingViewShow)
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
