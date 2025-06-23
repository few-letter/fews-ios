//
//  KPTWidget.swift
//  KPTWidget
//
//  Created by 송영모 on 3/20/24.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

extension Provider {
    private static let container: ModelContainer = {
        do {
            return try ModelContainer(for: Record.self)
        } catch {
            fatalError("\(error)")
        }
    }()
    
    private func fetches() -> [Record]? {
        do {
            let records = try modelContext.fetch(FetchDescriptor<Record>())
            return records
        } catch {
            return nil
        }
    }
}

struct Provider: AppIntentTimelineProvider {
    private let modelContext = ModelContext(Self.container)
    
    func placeholder(in context: Context) -> DocEntry {
        DocEntry(date: Date(), doc: nil, configuration: .init())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> DocEntry {
        return .init(date: .now, doc: nil, configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<DocEntry> {
        guard let records = fetches()
        else {
            return .init(entries: [], policy: .never)
        }
        
        let doc = Doc(records: records, originDate: .now, date: .now)
        let entry = DocEntry(date: .now, doc: doc, configuration: configuration)
        return .init(entries: [entry], policy: .never)
    }
}

struct DocEntry: TimelineEntry {
    let date: Date
    let doc: Doc?
    let configuration: ConfigurationAppIntent
    
    var maxLength: Int {
        var count = 0
        if configuration.isShowKeep { count += 1 }
        if configuration.isShowProblem { count += 1 }
        if configuration.isShowTry { count += 1 }
        guard count != 0 else { return 0 }
        return Int(6/count)
    }
}

struct KPTWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        if entry.doc == nil {
            emptyView
        } else {
            containerView
        }
    }
    
    private var emptyView: some View {
        VStack(alignment: .leading, spacing: 5) {
            recordSection(
                type: .keep,
                records: ["keep1", "keep2"]
            )
            recordSection(
                type: .problem,
                records: ["problem1", "problem2"]
            )
            recordSection(
                type: .try,
                records: ["try1", "try2"]
            )
            HStack {
                Spacer()
            }
        }
    }
    
    private var containerView: some View {
        VStack(alignment: .leading, spacing: 5) {
            if entry.configuration.isShowKeep {
                recordSection(
                    type: .keep,
                    records: entry.doc?.keeps.compactMap({ $0.context }) ?? []
                )
            }
            if entry.configuration.isShowProblem {
                recordSection(
                    type: .problem,
                    records: entry.doc?.problems.compactMap({ $0.context }) ?? []
                )
            }
            if entry.configuration.isShowTry {
                recordSection(
                    type: .try,
                    records: entry.doc?.tries.compactMap({ $0.context }) ?? []
                )
            }
            HStack {
                Spacer()
            }
        }
    }
    
    private func recordSection(type: RecordType, records: [String]) -> some View {
        VStack(alignment: .leading) {
            Text(toString(type: type))
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(toColor(type: type))
            
            ForEach(records.prefix(entry.maxLength), id: \.self) { record in
                Text(record)
                    .font(.caption)
            }
        }
    }
    
    private func toString(type: RecordType) -> String {
        switch type {
        case .keep: return "Keep"
        case .problem: return "Problem"
        case .try: return "Try"
        }
    }
    
    private func toColor(type: RecordType) -> Color {
        switch type {
        case .keep: return .brown
        case .problem: return .orange
        case .try: return .teal
        }
    }
}

struct KPTWidget: Widget {
    let kind: String = "KPTWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            KPTWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall])
    }
}
