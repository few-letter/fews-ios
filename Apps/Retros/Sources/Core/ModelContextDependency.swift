import Foundation
import SwiftData
import ComposableArchitecture

extension DependencyValues {
    public var modelContext: ModelContext {
        get { self[ModelContextKey.self] }
        set { self[ModelContextKey.self] = newValue }
    }
}

private enum ModelContextKey: DependencyKey {
    static var liveValue: ModelContext = {
        // 백그라운드에서 ModelContext를 생성하기 위한 별도의 컨테이너
        do {
            let schema = Schema([Record.self])
            let containerConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .private("iCloud.com.annapo.kpt"))
            let container = try ModelContainer(for: Record.self, configurations: containerConfig)
            return ModelContext(container)
        } catch {
            print("SwiftData 초기화 오류: \(error)")
            fatalError("Failed to create ModelContext: \(error)")
        }
    }()
    
    static let previewValue: ModelContext = {
        do {
            let schema = Schema([Record.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Record.self, configurations: configuration)
            return ModelContext(container)
        } catch {
            fatalError("Failed to create preview model container: \(error)")
        }
    }()
    
    static let testValue = previewValue
} 
