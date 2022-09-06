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
                Text("Choose weight unit")
                    .font(.system(size: 36))
                    .padding()
                Image(systemName: "ruler.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(.white)
                    .padding(24)
                    .background(Color(0xFF3E2AD1))
                    .clipShape(Circle())
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
                Text("Set goal weight")
                    .font(.system(size: 36))
                    .padding()
                Image(systemName: "flag.2.crossed.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(.white)
                    .padding(24)
                    .background(Color(0xFF3E2AD1))
                    .clipShape(Circle())
                    .padding()
                Form {
                    Section {
                        VStack {
                            HStack {
                                Text("Goal Weight")
                                Spacer()
                                Text("\(goal).\(goalTail) \(unit)").fontWeight(.bold)
                            }.padding()
                            HStack(spacing: 0) {
                                ResizeablePicker(selection: $goal, data: Array(0..<770)).onChange(of: goal) { newValue in
                                    goal = newValue
                                }
                                ResizeablePicker(selection: $goalTail, data: Array(0..<10)).onChange(of: goalTail) { newValue in
                                    goalTail = newValue
                                }
                            }
                        }
                    }
                }
            }
            VStack {
                Text("Set current weight")
                    .font(.system(size: 36))
                    .padding()
                Image(systemName: "person.badge.clock.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(.white)
                    .padding(24)
                    .background(Color(0xFF3E2AD1))
                    .clipShape(Circle())
                    .padding()
                
                Form {
                    Section {
                        VStack {
                            HStack {
                                Text("Current Weight")
                                Spacer()
                                Text("\(current).\(currentTail) \(unit)").fontWeight(.bold)
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
            VStack(alignment: .center) {
                Text("Let's reach our goals!")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 36))
                    .padding()
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(.white)
                    .padding(24)
                    .background(Color(0xFF3E2AD1))
                    .clipShape(Circle())
                    .padding()
                Button {
                    let date = Date()
                    let weight = Double(current) + (Double(currentTail) * 0.1)
                    UserDefaults.standard.set(goal, forKey: "goal")
                    UserDefaults.standard.set(goalTail, forKey: "goalTail")
                    WeightDataController().add(weight: weight, when: date, context: managedObjectContext)
                    onboardingShow.toggle()
                } label: {
                    HStack(spacing: 16) {
                        Text("Get Started")
                            .bold()
                        Image(systemName: "arrow.right")
                    }
                        .padding()
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50, alignment: .center)
                        .background(Color(0xFF3E2AD1))
                        .cornerRadius(8)
                }
                .padding(.top, 36)
                .padding(.bottom, 24)
                Text("Goal: \(goal).\(goalTail) \(unit)")
                    .font(.system(size: 18))
                    .fontWeight(.light)
                Text("First: \(current).\(currentTail) \(unit)")
                    .font(.system(size: 18))
                    .fontWeight(.light)
                Spacer()
            }
        }.tabViewStyle(.page)
    }
}
