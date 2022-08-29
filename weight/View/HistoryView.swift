//
//  HistoryView.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI
import HalfASheet

struct HistoryView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    let weights: FetchedResults<WeightEntity>
    
    @AppStorage("weightUnit") private var unit: String = "kg"
    
    @State private var isAddAlertActive: Bool = false
    @State private var isSheetActive: Bool = false
    @State private var lastWeight: Int = 0
    @State private var lastWeightTail: Int = 0
    @State private var date = Date()

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                List {
                    if weights.count > 0 {
                        let parsedWeights = parseWeightsForHistory(weights: weights)
                        ForEach(parsedWeights, id: \.self) {
                            HistoryCard(weight: $0.weight, date: $0.date, icon: $0.icon, color: $0.color, unit: unit)
                                .padding(.all, 4)
                        }
                    } else {
                        Text("No data")
                    }
                }
                Button {
                    isSheetActive.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .padding(.bottom, 36)
                        .padding(.trailing, 36)
                }
            }
                .navigationTitle("History")
        }.sheet(isPresented: $isSheetActive) {
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
    }
}
