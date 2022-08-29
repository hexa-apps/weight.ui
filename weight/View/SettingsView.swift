//
//  SettingsView.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI
import HalfASheet

struct SettingsView: View {
    @Environment(\.managedObjectContext) var manageObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.time, order: .forward)]) var weights: FetchedResults<WeightEntity>
    
    @AppStorage("birthday") private var birthday: Date = Date()

    @State private var clearAlert: Bool = false
    @State private var goalAlertActive: Bool = false
    @State private var goal: Int = UserDefaults.standard.integer(forKey: "goal")
    @State private var goalTail: Int = UserDefaults.standard.integer(forKey: "goalTail")
    
    @AppStorage("weightUnit") private var unit: String = "kg"
    let units = ["kg", "lb"]

    var body: some View {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        ZStack {
            NavigationView {
                List {
                    Section("PROFILE") {
                        Section {
                            DatePicker("Birthday", selection: $birthday, in: ...Date(), displayedComponents: .date).onChange(of: birthday) { newValue in
                                birthday = newValue
                            }
                        }
                        Section {
                            Button {
                                goalAlertActive.toggle()
                            } label: {
                                HStack {
                                    Text("Goal").foregroundColor(light: .black, dark: .white)
                                    Spacer()
                                    HStack {
                                        Text("\(goal).\(goalTail)")
                                        Image(systemName: "chevron.right")
                                    }.foregroundColor(.gray)
                                }
                            }
                        }
                        Section {
                            Picker("Unit", selection: $unit) {
                                ForEach(units, id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                    }
                    Section("SETTINGS") {
                        Section {
                            SettingButton(title: "Reminder", imageSystemName: "deskclock.fill") {
                                print("Reminder")
                            }.foregroundColor(light: .black.opacity(0.75), dark: .white)
                        }
                        Section {
                            SettingButton(title: "Clear History", imageSystemName: "trash.fill") {
                                clearAlert.toggle()
                            }
                                .foregroundColor(.red)
                                .alert(isPresented: $clearAlert) {
                                    Alert(
                                        title: Text("Clear All Data"),
                                        message: Text("Are you sure?"),
                                        primaryButton: .destructive(Text("Clear")) {
                                            for weight in weights {
                                                manageObjectContext.delete(weight)
                                            }
                                            if manageObjectContext.hasChanges {
                                                try? manageObjectContext.save()
                                            }
                                        },
                                        secondaryButton: .cancel(Text("Cancel")))
                                }
                        }
                    }
                    Section("ABOUT") {
                        Section {
                            SettingButton(title: "Suggestions", imageSystemName: "envelope.fill") {
                                print("Suggestions")
                            }.foregroundColor(light: .black.opacity(0.75), dark: .white)
                        }
                        Section {
                            SettingButton(title: "Share With Friends", imageSystemName: "square.and.arrow.up.fill") {
                                print("Share with friends")
                            }.foregroundColor(light: .black.opacity(0.75), dark: .white)
                        }
                        Section {
                            SettingButton(title: "Rate/Comment", imageSystemName: "star.fill") {
                                print("Rate/Comment")
                            }.foregroundColor(light: .black.opacity(0.75), dark: .white)
                        }
                        Section {
                            SettingButton(title: "Other Apps", imageSystemName: "rectangle.3.offgrid.fill") {
                                print("Other Apps")
                            }.foregroundColor(light: .black.opacity(0.75), dark: .white)
                        }
                    }
                    Section {
                        Text("Weight Tracker \(appVersion ?? "")").font(.callout).frame(maxWidth: .infinity, alignment: .center)
                    }.listRowBackground(Color.clear)
                }.navigationTitle("Settings")
            }
            HalfASheet(isPresented: $goalAlertActive) {
                GeometryReader { geometry in
                    VStack {
                        Text("Goal Weight (\(unit))").fontWeight(.bold).padding(.top, 16)
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
                .disableDragToDismiss
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
