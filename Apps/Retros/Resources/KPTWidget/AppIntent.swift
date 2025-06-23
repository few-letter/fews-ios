//
//  AppIntent.swift
//  KPTWidget
//
//  Created by 송영모 on 3/20/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
    
    @Parameter(title: "Show Keep", default: true)
    var isShowKeep: Bool
    
    @Parameter(title: "Show Problem", default: true)
    var isShowProblem: Bool
    
    @Parameter(title: "Show Try", default: true)
    var isShowTry: Bool
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
