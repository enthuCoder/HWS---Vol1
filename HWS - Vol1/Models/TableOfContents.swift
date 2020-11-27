//
//  TableOfContents.swift
//  HWS - Vol1
//
//  Created by Dilgir Siddiqui on 11/26/20.
//

import Foundation

struct TableOfContents {
    
    var contents: [String] {
        get {
            return loadContents()
        }
    }
    
    // Load the Contents of Volume 1
    func loadContents() -> [String] {
        guard let path = Bundle.main.path(forResource: "TableOfContents", ofType: "plist") else {
            fatalError("Failed to load Table of Contents plist")
        }
        var contents = [String]()
        do {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            let serializedResult = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            if let result = serializedResult as? [String] {
                contents = result
            }
        } catch {
            fatalError("Failed to read Table of Contents: \(error)")
        }
        return contents
    }
}
