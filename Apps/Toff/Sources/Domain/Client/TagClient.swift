//
//  TagClient.swift
//  Toff
//
//  Created by 송영모 on 6/15/25.
//

import Foundation
import ComposableArchitecture
import SwiftData

public protocol TagClient {
    func create() -> Tag
    func fetches() -> [Tag]
    func update(tag: Tag) -> Void
    func delete(tag: Tag) -> Void
}

private struct TagClientKey: TestDependencyKey {
    static var testValue: any TagClient = TagClientTest()
}

extension DependencyValues {
    var tagClient: any TagClient {
        get { self[TagClientKey.self] }
        set { self[TagClientKey.self] = newValue }
    }
}
