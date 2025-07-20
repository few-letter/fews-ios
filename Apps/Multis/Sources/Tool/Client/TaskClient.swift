//
//  TaskClient.swift
//  Multis
//
//  Created by 송영모 on 6/24/25.
//

import Foundation
import ComposableArchitecture
import SwiftData

public protocol TaskClient {
    func createOrUpdate(taskModel: TaskModel) -> TaskModel
    func fetches() -> [TaskModel]
    func delete(taskModel: TaskModel)
}

private struct TaskClientKey: TestDependencyKey {
    static var testValue: any TaskClient = TaskClientTest()
}

extension DependencyValues {
    var taskClient: any TaskClient {
        get { self[TaskClientKey.self] }
        set { self[TaskClientKey.self] = newValue }
    }
}
