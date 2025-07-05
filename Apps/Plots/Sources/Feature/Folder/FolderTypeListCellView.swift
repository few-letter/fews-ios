//
//  FolderListCellView.swift
//  FewMemories
//
//  Created by Extension on 2024.
//

import SwiftUI

public struct FolderTypeListCellView: View {
    public let folderType: FolderType
    
    public init(folderType: FolderType) {
        self.folderType = folderType
    }
    
    public var body: some View {
        HStack {
            Image(systemName: "folder")
                .foregroundColor(.blue)
            
            Text(folderType.name)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(folderType.count)")
                .foregroundColor(.secondary)
                .font(.callout)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}
