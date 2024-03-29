//
//  SettingsView.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI
import HalfASheet
import SwiftCSV

struct SettingsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.openURL) var openURL

    @FetchRequest(sortDescriptors: [SortDescriptor(\.time, order: .reverse)]) var weights: FetchedResults<WeightEntity>

    @AppStorage("birthday") private var birthday: Date = Date()
    @AppStorage("reminderCheck") private var reminderCheck: Bool = false
    @AppStorage("reminderTime") private var reminderTime: Date = Date()

    @State private var clearAlert: Bool = false
    @State private var goalAlertActive: Bool = false
    @State private var informativeAlert: Bool = false
    @State private var reminderSheet: Bool = false
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    @State private var goal: Int = UserDefaults.standard.integer(forKey: "goal")
    @State private var goalTail: Int = UserDefaults.standard.integer(forKey: "goalTail")

    @AppStorage("weightUnit") private var unit: String = "kg"
    let units = ["kg", "lb"]
    
    func importCSVDocument(from url: URL, weights: FetchedResults<WeightEntity>) {
        if url.pathExtension == "csv" {
            do {
                let csvFile: CSV = try CSV<Named>(url: url)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let weightTimes = weights.map{ $0.time }
                let filteredList = csvFile.rows.filter { row in
                    guard let timeString = row["time"] else { return false }
                    guard let time = dateFormatter.date(from: timeString) else { return false }
                    if weightTimes.contains(time) {
                        return false
                    }
                    guard let weightString = row["weight"] else { return false}
                    guard let weight = Double(weightString) else { return false }
                    WeightDataController().startAddingWeightProcess(weight: Double(weight), when: time, weights: weights, context: managedObjectContext)
                    return true
                }
                print(filteredList.count)
            } catch {
                print("Error import csv")
            }
            
        }
    }

    var body: some View {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        ZStack {
            VStack {
                TitleComponent(title: "Settings")
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
                            HStack {
                                Text("Unit")
                                Spacer()
                                Picker("Unit", selection: $unit) {
                                    ForEach(units, id: \.self) {
                                        Text($0)
                                    }
                                }.pickerStyle(.segmented)
                                    .fixedSize()
                            }

                        }
                    }
                    Section("SETTINGS") {
                        Section {
                            Toggle("Reminder", isOn: $reminderCheck).onChange(of: reminderCheck) { newValue in
                                if newValue {
                                    let center = UNUserNotificationCenter.current()
                                    center.getNotificationSettings { settings in
                                        switch settings.authorizationStatus {
                                        case .authorized:
                                            // TODO: Set reminder
                                            setReminder(isChecked: true, date: reminderTime)
                                        case .denied:
                                            // TODO: Open informative alert
                                            informativeAlert.toggle()
                                            reminderCheck = false
                                        case .ephemeral:
                                            print("Some permissions")
                                        case .notDetermined:
                                            center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                                if success {
                                                    // TODO: Set reminder
                                                    setReminder(isChecked: true, date: reminderTime)
                                                } else {
                                                    // TODO: Open informative alert
                                                    informativeAlert.toggle()
                                                    reminderCheck = false
                                                }
                                            }
                                        case .provisional:
                                            print("Don't know")
                                        default:
                                            print("New case")
                                        }
                                    }
                                } else {
                                    setReminder(isChecked: false, date: reminderTime)
                                }
                            }
                        }.alert(isPresented: $informativeAlert) {
                            Alert(
                                title: Text("Notification Permission"),
                                message: Text("You need to give permission to use the reminder."),
                                primaryButton: .default(Text("Go to settings")) {
                                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                },
                                secondaryButton: .cancel(Text("Cancel")))
                        }
                        if reminderCheck {
                            withAnimation {
                                Section {
                                    HStack {
                                        DatePicker("Everyday", selection: $reminderTime, displayedComponents: .hourAndMinute).onChange(of: reminderTime) { newValue in
                                            reminderTime = newValue
                                            setReminder(isChecked: reminderCheck, date: reminderTime)
                                        }
                                    }

                                }
                            }
                        }
                    }
                    Section("DATA") {
                        Section {
                            SettingButton(title: "🗑 Clear History") {
                                clearAlert.toggle()
                            }
                                .foregroundColor(.red)
                                .alert(isPresented: $clearAlert) {
                                Alert(
                                    title: Text("Clear All Data"),
                                    message: Text("Are you sure?"),
                                    primaryButton: .destructive(Text("Clear")) {
                                        for weight in weights {
                                            managedObjectContext.delete(weight)
                                        }
                                        if managedObjectContext.hasChanges {
                                            try? managedObjectContext.save()
                                        }
                                    },
                                    secondaryButton: .cancel(Text("Cancel")))
                            }
                            SettingButton(title: "📥 Import CSV") {
                                isImporting = true
                            }
                                .foregroundColor(light: .black, dark: .white)
                            SettingButton(title: "📤 Export CSV") {
                                isExporting = true
                            }
                                .foregroundColor(light: .black, dark: .white)
                        }
                    }
                    Section("ABOUT") {
                        Section {
                            SettingButton(title: "📪 Suggestions") {
                                let email = "hexagameapps@gmail.com?subject=Hexa Weight Tracker \(appVersion ?? "")"
                                let mailto = "mailto:\(email)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                if let url = URL(string: mailto!) {
                                    openURL(url)
                                }

                            }.foregroundColor(light: .black.opacity(0.75), dark: .white)
                        }
                        Section {
                            SettingButton(title: "🎉 Share With Friends", onTapFunction: shareSheet)
                                .foregroundColor(light: .black.opacity(0.75), dark: .white)
                        }
                        Section {
                            SettingButton(title: "🌟 Rate & Comment") {
                                if let url = URL(string: "https://apps.apple.com/app/hexa-weight-tracker/id6443335021") {
                                    openURL(url)
                                }
                            }.foregroundColor(light: .black.opacity(0.75), dark: .white)
                        }
                        Section {
                            SettingButton(title: "📲 Other Apps") {
                                if let url = URL(string: "https://apps.apple.com/developer/berkay-oruc/id1636040465") {
                                    openURL(url)
                                }
                            }.foregroundColor(light: .black.opacity(0.75), dark: .white)
                        }
                    }
                    Section {
                        Text("Weight Tracker \(appVersion ?? "")").font(.callout).frame(maxWidth: .infinity, alignment: .center)
                    }.listRowBackground(Color.clear)
                }
                    .fileExporter(isPresented: $isExporting, document: exportCSVDocument(weights: weights), contentType: .plainText, defaultFilename: getCSVTitle()) { result in
                        
                }
                    .fileImporter(isPresented: $isImporting, allowedContentTypes: [.plainText], allowsMultipleSelection: false) { result in
                    do {
                        guard let selectedFile: URL = try result.get().first else { return }
                        importCSVDocument(from: selectedFile, weights: weights)
                    } catch {
                        // Handle failure.
                        print("Unable to read file contents")
                        print(error.localizedDescription)
                    }
                }

            }
            HalfASheet(isPresented: $goalAlertActive, title: "Goal Weight (\(unit))") {
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
                .height(.fixed(320))
                .disableDragToDismiss
        }
    }

    func shareSheet() {
        guard let urlShare = URL(string: "https://apps.apple.com/app/hexa-weight-tracker/id6443335021") else { return }
        let activityVC = UIActivityViewController(activityItems: ["If you want to track your weight, have a look at this app.\n", urlShare], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
