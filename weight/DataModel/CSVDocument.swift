//
//  MessageDocument.swift
//  weight
//
//  Created by berkay on 21.09.2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct CSVDocument: FileDocument {
    
    var content: String
    
    init(content: String) {
        self.content = content
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        content = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: content.data(using: .utf8)!)
    }
    
    static var readableContentTypes: [UTType] { [.plainText] }
    
}
