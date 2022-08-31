//
//  OnboardingView.swift
//  weight
//
//  Created by berkay on 23.08.2022.
//

import SwiftUI

struct OnboardingView: View {
    
    @Binding var onboardingShow: Bool

    @AppStorage("weightUnit") private var unit: String = "kg"
    let units = ["kg", "lb"]

    @State private var goal: Int = 40
    @State private var goalTail: Int = 0
    
    @State private var current: Int = 40
    @State private var currentTail: Int = 0
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        TabView {
            VStack {
                Image(systemName: "star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150, alignment: .center)
                    .padding()
                Text("baslik")
                    .font(.system(size: 42))
                    .padding()
                Form {
                    Section {
                        Picker("Unit", selection: $unit) {
                            ForEach(units, id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(.inline)
                    }
                }
            }
            VStack {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150, alignment: .center)
                    .padding()
                Text("baslik")
                    .font(.system(size: 42))
                    .padding()
                Form {
                    Section {
                        VStack {
                            HStack {
                                Text("Goal Weight")
                                Spacer()
                                Text("\(goal).\(goalTail) \(unit)")
                            }.padding()
                            HStack(spacing: 0) {
                                ResizeablePicker(selection: $goal, data: Array(0..<770)).onChange(of: goal) { newValue in
                                    goal = newValue
                                    UserDefaults.standard.set(goal, forKey: "goal")
                                }
                                ResizeablePicker(selection: $goalTail, data: Array(0..<10)).onChange(of: goalTail) { newValue in
                                    goalTail = newValue
                                    UserDefaults.standard.set(goalTail, forKey: "goalTail")
                                }
                            }
                        }
                    }
                }
            }
            VStack {
                Image(systemName: "car")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150, alignment: .center)
                    .padding()
                Text("baslik")
                    .font(.system(size: 42))
                    .padding()
                Form {
                    Section {
                        VStack {
                            HStack {
                                Text("Current Weight")
                                Spacer()
                                Text("\(current).\(currentTail) \(unit)")
                            }.padding()
                            HStack(spacing: 0) {
                                ResizeablePicker(selection: $current, data: Array(0..<770)).onChange(of: current) { newValue in
                                    current = newValue
                                    UserDefaults.standard.set(current, forKey: "current")
                                }
                                ResizeablePicker(selection: $currentTail, data: Array(0..<10)).onChange(of: currentTail) { newValue in
                                    currentTail = newValue
                                    UserDefaults.standard.set(currentTail, forKey: "currentTail")
                                }
                            }
                        }
                    }
                }
            }
            VStack {
                Image(systemName: "star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150, alignment: .center)
                    .padding()
                Text("Let's reach our goals!")
                    .font(.system(size: 36))
                    .padding()
                Spacer()
                Button {
                    let date = Date()
                    let weight = Double(current) + (Double(currentTail) * 0.1)
                    WeightDataController().add(weight: weight, when: date, context: managedObjectContext)
                    onboardingShow.toggle()
                } label: {
                    Text("Get Started")
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50, alignment: .center)
                        .background(.green)
                }
                Spacer()
            }
        }.tabViewStyle(.page)
    }
}
