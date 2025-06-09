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
    func createPlot() -> Plot
    func fetches() -> [Plot]
    func update(plot: Plot) -> Void
    func delete(plot: Plot) -> Void
    func save(_ plot: Plot) -> Void
}

public class PlotClientLive: PlotClient {
    private var modelContext: ModelContext?
    
    public init(modelContext: ModelContext?) {
        self.modelContext = modelContext
        self.modelContext?.autosaveEnabled = true
    }
    
    public func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    public func createPlot() -> Plot {
        let plot = Plot()
        save(plot)
        print("Successfully create and save plot")
        
        return plot
    }
    
    public func fetches() -> [Plot] {
        guard let context = modelContext else { return [] }
        
        do {
            let descriptor = FetchDescriptor<Plot>(
                sortBy: [.init(\.date)]
            )
            let result = try context.fetch(descriptor)
            print("Successfully fetched plots | result:\(result)")
            return result
        } catch {
            print("Failed to fetch plots: \(error)")
            return []
        }
    }
    
    public func update(plot: Plot) -> Void {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
            print("Successfully updated plot")
        } catch {
            print("Failed to update plot: \(error)")
        }
    }
    
    public func delete(plot: Plot) -> Void {
        guard let context = modelContext else { return }
        
        do {
            context.delete(plot)
            try context.save()
        } catch {
            print("Failed to delete plot: \(error)")
        }
    }
    
    public func save(_ plot: Plot) {
        guard let context = modelContext else { 
            print("ModelContext is nil, cannot save plot")
            return 
        }
        
        do {
            context.insert(plot)
            try context.save()
            print("Successfully saved plot with title: \(plot.title ?? "No title")")
        } catch {
            print("Failed to save plot: \(error)")
        }
    }
}

private struct PlotClientKey: DependencyKey {
    static let liveValue: any PlotClient = PlotClientLive(modelContext: nil)
}

extension DependencyValues {
    var plotClient: any PlotClient {
        get { self[PlotClientKey.self] }
        set { self[PlotClientKey.self] = newValue }
    }
}


