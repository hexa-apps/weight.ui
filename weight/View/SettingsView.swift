//
//  SettingsView.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI
import HalfASheet

struct SettingsView: View {
    @State private var gender = "Male"
    let genders = ["Male", "Female", "None"]

    @State private var birthday: Date = Date()

    @State private var goalAlertActive: Bool = false
    @State var goal: Int = 90
    @State var goalTail: Int = 0

    var body: some View {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        ZStack {
            NavigationView {
                List {
                    Section("PROFILE") {
                        Section {
                            Picker("Gender", selection: $gender) {
                                ForEach(genders, id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                        Section {
                            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
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
                    }
                    Section("SETTINGS") {
                        Section {
                            SettingButton(title: "Reminder", imageSystemName: "deskclock.fill") {
                                print("Reminder")
                            }.foregroundColor(light: .black, dark: .white)
                        }
                        Section {
                            SettingButton(title: "Remove", imageSystemName: "trash.fill") {
                                print("Remove")
                            }.foregroundColor(.red)
                        }
                    }
                    Section("ABOUT") {
                        Section {
                            SettingButton(title: "Suggestions", imageSystemName: "envelope.fill") {
                                print("Suggestions")
                            }.foregroundColor(light: .black, dark: .white)
                        }
                        Section {
                            SettingButton(title: "Share With Friends", imageSystemName: "square.and.arrow.up.fill") {
                                print("Share with friends")
                            }.foregroundColor(light: .black, dark: .white)
                        }
                        Section {
                            SettingButton(title: "Rate/Comment", imageSystemName: "star.fill") {
                                print("Rate/Comment")
                            }.foregroundColor(light: .black, dark: .white)
                        }
                        Section {
                            SettingButton(title: "Other Apps", imageSystemName: "rectangle.3.offgrid.fill") {
                                print("Other Apps")
                            }.foregroundColor(light: .black, dark: .white)
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
                        Text("Goal Weight").fontWeight(.bold).padding(.top, 16)
                        HStack(spacing: 0) {
                            ResizeablePicker(selection: $goal, data: Array(0..<770))
                            ResizeablePicker(selection: $goalTail, data: Array(0..<10))
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
