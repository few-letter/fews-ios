//
//  FolderModel.swift
//  Plots
//
//  Created by 송영모 on 7/5/25.
//

import Foundation
import SwiftData

public struct FolderModel: Identifiable, Comparable, Equatable {
    public var id: String
    public var name: String
    public var createdDate: Date
    
    // SwiftData 객체 참조 (저장용)
    public var folder: Folder?
    
    // 특별 조건: recursive struct 방지를 위해 SwiftData Folder 클래스 직접 참조
    public var folders: [Folder]
    public var parentFolder: Folder?
    
    public init(
        id: String = UUID().uuidString,
        name: String = "",
        createdDate: Date = .now,
        folder: Folder? = nil,
        folders: [Folder] = [],
        parentFolder: Folder? = nil
    ) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
        self.folder = folder
        self.folders = folders
        self.parentFolder = parentFolder
    }
    
    // Equatable
    public static func == (lhs: FolderModel, rhs: FolderModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Comparable
    public static func < (lhs: FolderModel, rhs: FolderModel) -> Bool {
        return lhs.createdDate < rhs.createdDate
    }
}

// MARK: - SwiftData <-> Model Conversion Extensions
extension FolderModel {
    /// SwiftData Folder 객체로부터 FolderModel 생성
    public init(from swiftDataFolder: Folder) {
        self.init(
            id: swiftDataFolder.id ?? UUID().uuidString,
            name: swiftDataFolder.name ?? "",
            createdDate: swiftDataFolder.createdDate ?? .now,
            folder: swiftDataFolder,
            folders: swiftDataFolder.folders ?? [],
            parentFolder: swiftDataFolder.parentFolder
        )
    }
    
    /// FolderModel을 SwiftData Folder 객체로 변환
    public func toSwiftDataFolder() -> Folder {
        return Folder(
            id: self.id,
            name: self.name,
            createdDate: self.createdDate
        )
    }
    
    /// FolderModel의 값들로 참조하고 있는 SwiftData Folder 객체를 업데이트
    public func updateSwiftData() {
        guard let swiftDataFolder = self.folder else { return }
        
        swiftDataFolder.name = self.name
        swiftDataFolder.createdDate = self.createdDate
        swiftDataFolder.parentFolder = self.parentFolder
        // folders 관계는 SwiftData에서 자동으로 관리되므로 직접 업데이트하지 않음
    }
}

