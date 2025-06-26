//
//  ImageToTextClient.swift
//  Capts
//
//  Created by 송영모 on 6/26/25.
//

import Foundation
import ComposableArchitecture
import UIKit

public protocol ImageToTextClient {
    func extractText(from image: UIImage) async throws -> String
}

// MARK: - DependencyKey
private struct ImageToTextClientKey: TestDependencyKey {
    static var testValue: any ImageToTextClient = ImageToTextClientTest()
}

extension DependencyValues {
    var imageToTextClient: any ImageToTextClient {
        get { self[ImageToTextClientKey.self] }
        set { self[ImageToTextClientKey.self] = newValue }
    }
}

// MARK: - Test Implementation
public struct ImageToTextClientTest: ImageToTextClient {
    public func extractText(from image: UIImage) async throws -> String {
        return "테스트 추출된 텍스트"
    }
}

