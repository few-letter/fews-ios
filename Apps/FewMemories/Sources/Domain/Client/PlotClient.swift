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
    func create(folder: Folder?) -> Plot
    func fetches() -> [Plot]
    func fetches(folder: Folder) -> [Plot]
    func update(plot: Plot) -> Void
    func delete(plot: Plot) -> Void
}

private struct PlotClientKey: DependencyKey {
    static let liveValue: any PlotClient = PlotClientTest()
}

extension DependencyValues {
    var plotClient: any PlotClient {
        get { self[PlotClientKey.self] }
        set { self[PlotClientKey.self] = newValue }
    }
}


