//
//  PlotModel.swift
//  Plots
//
//  Created by 송영모 on 7/5/25.
//

import Foundation
import SwiftData

public struct PlotModel: Identifiable, Comparable, Equatable {
    public var id: String
    public var content: String
    public var date: Date
    public var point: Double
    public var title: String
    public var type: Int
    
    // SwiftData 객체 참조 (저장용)
    public var plot: Plot?
    
    // Folder 관계 (특별 조건: SwiftData Folder 클래스 직접 참조)
    public var folder: Folder?
    
    public init(
        id: String = UUID().uuidString,
        content: String = "",
        date: Date = .now,
        point: Double = 0.0,
        title: String = "",
        type: Int = 0,
        plot: Plot? = nil,
        folder: Folder? = nil
    ) {
        self.id = id
        self.content = content
        self.date = date
        self.point = point
        self.title = title
        self.type = type
        self.plot = plot
        self.folder = folder
    }
    
    // Equatable
    public static func == (lhs: PlotModel, rhs: PlotModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Comparable
    public static func < (lhs: PlotModel, rhs: PlotModel) -> Bool {
        return lhs.date < rhs.date
    }
}

// MARK: - SwiftData <-> Model Conversion Extensions
extension PlotModel {
    /// SwiftData Plot 객체로부터 PlotModel 생성
    public init(from swiftDataPlot: Plot) {
        self.init(
            id: .init(swiftDataPlot.persistentModelID.id.hashValue),
            content: swiftDataPlot.content ?? "",
            date: swiftDataPlot.date ?? .now,
            point: swiftDataPlot.point ?? 0.0,
            title: swiftDataPlot.title ?? "",
            type: swiftDataPlot.type ?? 0,
            plot: swiftDataPlot,
            folder: swiftDataPlot.folder
        )
    }
    
    /// PlotModel을 SwiftData Plot 객체로 변환
    public func toSwiftDataPlot() -> Plot {
        return Plot(
            content: self.content,
            date: self.date,
            point: self.point,
            title: self.title,
            type: self.type,
            folder: self.folder
        )
    }
    
    /// PlotModel의 값들로 참조하고 있는 SwiftData Plot 객체를 업데이트
    public func updateSwiftData() {
        guard let swiftDataPlot = self.plot else { return }
        
        swiftDataPlot.content = self.content
        swiftDataPlot.date = self.date
        swiftDataPlot.point = self.point
        swiftDataPlot.title = self.title
        swiftDataPlot.type = self.type
        swiftDataPlot.folder = self.folder
    }
}

