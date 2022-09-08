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
    @State private var isEdit: Bool = false
    @State private var lastWeight: Int = 40
    @State private var lastWeightTail: Int = 0
    @State private var date = Date()

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                List {
                    if weights.count > 0 {
                        let parsedWeights = parseWeightsForHistory(weights: weights)
                        ForEach(parsedWeights, id: \.self) { weight in
                            Button {
                                lastWeight = Int(weight.weight)
                                lastWeightTail = Int(String(weight.weight).suffix(1)) ?? 0
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "dd.MM.yyyy"
                                date = dateFormatter.date(from: weight.date) ?? Date()
                                isEdit = true
                                isSheetActive.toggle()
                            } label: {
                                HistoryCard(weight: weight, unit: unit)
                                    .padding(.all, 4)
                            }
                            
                        }
                    } else {
                        Text("No data")
                    }
                }
                Button {
                    isEdit = false
                    isSheetActive.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(light: Color(0xFF3E2AD1), dark: Color(0xFF6753F4))
                        .padding(.bottom, 36)
                        .padding(.trailing, 36)
                }
            }
                .navigationTitle("History")
        }.sheet(isPresented: $isSheetActive) {
            ZStack {
                VStack {
                    Section {
                        HStack {
                            Text("Add/Update Weight").font(.title2).fontWeight(.bold)
                            Spacer()
                            Button {
                                isEdit = false
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
                        if isEdit {
                            Spacer()
                            Button {
                                isEdit = false
                                isSheetActive.toggle()
                            } label: {
                                Text("Delete")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(.red)
                                    .font(.title3)
                            }.cornerRadius(16)
                        }
                    }.padding()
                    Spacer()
                }.onAppear {
                    date = date
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
                .onAppear {
                    if let weight = weights.last {
                        lastWeight =  Int(weight.weight)
                        lastWeightTail = Int(String(weight.weight).suffix(1)) ?? 0
                    } else {
                        lastWeight =  UserDefaults.standard.integer(forKey: "goal")
                        lastWeightTail = UserDefaults.standard.integer(forKey: "goalTail")
                    }
                    
                }
                    
            }
        }
    }
}
