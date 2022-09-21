//
//  MessageDocument.swift
//  weight
//
//  Created by berkay on 21.09.2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct MessageDocument: FileDocument {
    
    var message: String
    
    init(message: String) {
        self.message = message
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        message = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: message.data(using: .utf8)!)
    }
    
    static var readableContentTypes: [UTType] { [.plainText] }
    
}
