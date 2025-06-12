//
//  PlotClientLive.swift
//  FewMemories
//
//  Created by 송영모 on 6/10/25.
//

import Foundation
import SwiftData

public class PlotClientLive: PlotClient {
    private var context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public func create(folder: Folder?) -> Plot {
        let plot = Plot(folder: folder)
        save(plot: plot)
        return plot
    }
    
    public func fetches(folder: Folder?) -> [Plot] {
        do {
            var descriptor: FetchDescriptor<Plot>
            if let folderID = folder?.id {
                descriptor = FetchDescriptor<Plot>(
                    predicate: #Predicate { plot in
                        plot.folder?.id == folderID
                    },
                    sortBy: [.init(\.date)]
                )
            } else {
                descriptor = FetchDescriptor<Plot>(
                    sortBy: [.init(\.date)]
                )
            }
            let result = try context.fetch(descriptor)
            return result
        } catch {
            return []
        }
    }
    
    public func update(plot: Plot) -> Void {
        do {
            try context.save()
        } catch {
        }
    }
    
    public func delete(plot: Plot) -> Void {
        do {
            context.delete(plot)
            try context.save()
        } catch {

        }
    }
    
    private func save(plot: Plot) {
        do {
            context.insert(plot)
            try context.save()
        } catch {
        }
    }
}

public class PlotClientTest: PlotClient {
    public func create(folder: Folder?) -> Plot {
        fatalError()
    }
    
    public func fetches(folder: Folder?) -> [Plot] {
        fatalError()
    }
    
    public func update(plot: Plot) {
        fatalError()
    }
    
    public func delete(plot: Plot) {
        fatalError()
    }
}
