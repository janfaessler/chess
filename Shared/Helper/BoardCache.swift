//
//  File.swift
//  SwiftChess
//
//  Created by Jan Fässler on 09.03.2024.
//

import Foundation

public class BoardCache {
    
    private var cache:[Int:[Int:Figure]]
    
    private init(input:[Int:[Int:Figure]]) {
        cache = input
    }
    
    public static func create(_ figures: [Figure]) -> BoardCache {
        var dict:[Int:[Int:Figure]] = [:]
        for f in figures {
            if dict[f.getRow()] == nil {
                dict[f.getRow()] = [:]
            }
            dict[f.getRow()]![f.getFile()] = f
        }
        return BoardCache(input: dict)
    }
    
    public func get(atRow:Int, atFile:Int) -> Figure? {
        return cache[atRow]?[atFile]
    }
    
    public func clearField(atRow:Int, atFile:Int) {
        cache[atRow]?[atFile] = nil
    }
    
    public func set(_ figure:Figure) {
        if cache[figure.getRow()] == nil {
            cache[figure.getRow()] = [:]
        }
        cache[figure.getRow()]![figure.getFile()] = figure
    }
    
    public func isEmpty(atRow:Int, atFile:Int) -> Bool {
        return get(atRow: atRow, atFile: atFile) == nil
    }
    
    public func isNotEmpty(atRow:Int, atFile:Int) -> Bool {
        return isEmpty(atRow: atRow, atFile: atFile) == false
    }
}
