//
//  PresistentManager.swift
//  KPT
//
//  Created by 송영모 on 3/18/24.
//

import Foundation
import SwiftData
import CloudKit

@MainActor
public class PresistentManager {
    public static var shared = PresistentManager()
    
    public var context: ModelContext
    public var container: ModelContainer
    
    private init() {
        do {
            // CloudKit 설정
            let schema = Schema([Record.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            let containerConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .private("iCloud.com.annapo.kpt"))
            let container = try ModelContainer(for: Record.self, configurations: containerConfig)
            
            self.container = container
            self.context = ModelContext(container)
        } catch {
            print("SwiftData 초기화 오류: \(error)")
            fatalError()
        }
    }
}
