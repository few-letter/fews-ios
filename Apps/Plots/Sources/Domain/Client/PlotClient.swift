//
//  PlotClient.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import Foundation
import ComposableArchitecture
import SwiftData

public protocol PlotClient {
    @discardableResult
    func createOrUpdate(plot: PlotModel) -> PlotModel
    func fetches() -> [PlotModel]
    func fetches(folder: FolderModel?) -> [PlotModel]
    func delete(plot: PlotModel)
}

private struct PlotClientKey: TestDependencyKey {
    static var testValue: any PlotClient = PlotClientTest()
}

extension DependencyValues {
    var plotClient: any PlotClient {
        get { self[PlotClientKey.self] }
        set { self[PlotClientKey.self] = newValue }
    }
}

public struct PlotClientTest: PlotClient {
    public func createOrUpdate(plot: PlotModel) -> PlotModel {
        return plot
    }
    
    public func fetches() -> [PlotModel] {
        return []
    }
    
    public func fetches(folder: FolderModel?) -> [PlotModel] {
        return []
    }
    
    public func delete(plot: PlotModel) {
        // Test implementation
    }
}
