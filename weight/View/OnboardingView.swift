//
//  OnboardingView.swift
//  weight
//
//  Created by berkay on 23.08.2022.
//

import SwiftUI

struct OnboardingView: View {

    @Binding var onboardingShow: Bool

    @AppStorage("reminderCheck") private var reminderCheck: Bool = false
    @AppStorage("reminderTime") private var reminderTime: Date = Date()

    @AppStorage("weightUnit") private var unit: String = "kg"
    let units = ["kg", "lb"]

    @State private var goal: Int = 70
    @State private var goalTail: Int = 0

    @State private var current: Int = 70
    @State private var currentTail: Int = 0

    @State private var selectedPage = 0

    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TabView(selection: $selectedPage) {
            VStack {
                Text("Choose weight unit")
                    .font(.system(size: 36))
                    .padding()
                HStack {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding(.leading, 16)
                    Spacer()
                    Image(systemName: "ruler.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50, alignment: .center)
                        .foregroundColor(.white)
                        .padding(24)
                        .background(Color(0xFF3E2AD1))
                        .clipShape(Circle())
                        .padding()
                    Spacer()
                    Button {
                        withAnimation {
                            selectedPage += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(0xFF3E2AD1))
                            .padding(.trailing, 16)
                    }
                }
                Form {
                    Section {
                        Picker("Unit", selection: $unit) {
                            ForEach(units, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                            .onChange(of: unit) { newValue in
                            if newValue == "kg" {
                                current = 70
                                goal = 60
                            } else {
                                current = 150
                                goal = 130
                            }
                        }
                    }
                }
            }.tag(0)
            VStack {
                Text("Set goal weight")
                    .font(.system(size: 36))
                    .padding()
                HStack {
                    Button {
                        withAnimation {
                            selectedPage -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(0xFF3E2AD1))
                            .padding(.leading, 16)
                    }
                    Spacer()
                    Image(systemName: "flag.2.crossed.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50, alignment: .center)
                        .foregroundColor(.white)
                        .padding(24)
                        .background(Color(0xFF3E2AD1))
                        .clipShape(Circle())
                        .padding()
                    Spacer()
                    Button {
                        withAnimation {
                            selectedPage += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(0xFF3E2AD1))
                            .padding(.trailing, 16)
                    }
                }
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
            }.tag(1)
            VStack {
                Text("Set current weight")
                    .font(.system(size: 36))
                    .padding()
                HStack {
                    Button {
                        withAnimation {
                            selectedPage -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(0xFF3E2AD1))
                            .padding(.leading, 16)
                    }
                    Spacer()
                    Image(systemName: "person.badge.clock.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50, alignment: .center)
                        .foregroundColor(.white)
                        .padding(24)
                        .background(Color(0xFF3E2AD1))
                        .clipShape(Circle())
                        .padding()
                    Spacer()
                    Button {
                        withAnimation {
                            selectedPage += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(0xFF3E2AD1))
                            .padding(.trailing, 16)
                    }
                }
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
            }.tag(2)
            VStack(alignment: .center) {
                VStack {
                    Text("Let's reach our goals!")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 36))
                        .padding()
                    HStack {
                        Button {
                            withAnimation {
                                selectedPage -= 1
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color(0xFF3E2AD1))
                                .padding(.leading, 16)
                        }
                        Spacer()
                        Image(systemName: "star.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50, alignment: .center)
                            .foregroundColor(.white)
                            .padding(24)
                            .background(Color(0xFF3E2AD1))
                            .clipShape(Circle())
                            .padding()
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .padding(.trailing, 16)
                    }
                    Button {
                        let date = Date()
                        let weight = Double(current) + (Double(currentTail) * 0.1)
                        UserDefaults.standard.set(goal, forKey: "goal")
                        UserDefaults.standard.set(goalTail, forKey: "goalTail")
                        WeightDataController().add(weight: weight, when: date, context: managedObjectContext)
                        onboardingShow.toggle()
                        let center = UNUserNotificationCenter.current()
                        center.getNotificationSettings { settings in
                            switch settings.authorizationStatus {
                            case .authorized:
                                // TODO: Set reminder
                                reminderCheck = true
                            case .denied:
                                // TODO: Open informative alert
                                reminderCheck = false
                            case .ephemeral:
                                print("Some permissions")
                            case .notDetermined:
                                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                    if success {
                                        // TODO: Set reminder
                                        reminderCheck = true
                                    } else {
                                        // TODO: Open informative alert
                                        reminderCheck = false
                                    }
                                    setReminder(isChecked: reminderCheck, date: reminderTime)
                                }
                            case .provisional:
                                print("Don't know")
                            default:
                                print("New case")
                            }
                            setReminder(isChecked: reminderCheck, date: reminderTime)
                        }
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
            }.tag(3)
        }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onAppear {
            setupAppearance()
            if unit == "kg" {
                current = 70
                goal = 60
            } else {
                current = 150
                goal = 140
            }
        }
    }

    func setupAppearance() {
        let color: Color = colorScheme == .light ? Color(0xFF3E2AD1) : Color(0xFF6753F4)
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(color)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(color).withAlphaComponent(0.2)

    }
}
