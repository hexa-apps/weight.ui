//
//  summaryWidget.swift
//  summaryWidget
//
//  Created by berkay on 24.07.2023.
//

import WidgetKit
import CoreData
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let midnight = Calendar.current.startOfDay(for: Date())
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        let entries = [SimpleEntry(date: midnight)]
        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct summaryWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text("berkya \(itemsCount)").foregroundColor(.red)
    }
    
    private var itemsCount: Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WeightEntity")
        do {
            print("v")
            let result = try WeightDataController.standart.container.viewContext.fetch(request)
            print("a")
            return 5
            let lastThing = result.last as? WeightEntity
            guard let thingName = lastThing?.weight else { return -2 }
            return Int(thingName)
        } catch {
            print("ebkaa \(error.localizedDescription)")
            return -1
        }
    }
}

struct summaryWidget: Widget {
    let kind: String = "summaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            summaryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Summary")
        .description("Display your progress summary.")
    }
}

struct summaryWidget_Previews: PreviewProvider {
    static var previews: some View {
        summaryWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
