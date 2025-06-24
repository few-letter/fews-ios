//
//  RecordClient.swift
//  Retros
//
//  Created by 송영모 on 6/23/25.
//

import Foundation
import ComposableArchitecture
import SwiftData

public protocol RecordClient {
    func createOrUpdate(recordModel: RecordModel) -> RecordModel
    func fetches() -> [RecordModel]
    func delete(recordModel: RecordModel)
}

private struct RecordClientKey: TestDependencyKey {
    static var testValue: any RecordClient = RecordClientTest()
}

extension DependencyValues {
    var recordClient: any RecordClient {
        get { self[RecordClientKey.self] }
        set { self[RecordClientKey.self] = newValue }
    }
}
