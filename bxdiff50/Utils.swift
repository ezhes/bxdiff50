//
//  Utils.swift
//  bxdiff50
//
//  Created by Salman Husain on 8/8/19.
//  Copyright © 2019 Salman Husain. All rights reserved.
//

import Foundation

class Utils {
    /// Attempt to read a uint64 from the buffer at a given offset, either as a big or a little endian value
    public static func readUINT64(from data:Data,offset:uint64,bigEndian:Bool) -> uint64 {
        let n = bigEndian ? Data.init(data[offset..<offset+8].reversed()) : data[offset..<offset+8]
        return n.withUnsafeBytes { (buffer) -> uint64 in
            return buffer.bindMemory(to: uint64.self).baseAddress!.pointee
        }
    }
    
    /// Attempt to read out an array of bytes from the buffer at a given offset
    public static func readUINT8Array(from data:Data,count:Int,offset:uint64) -> [uint8] {
        var results = [uint8].init(repeating: 0x0, count: count)
        for i in 0..<count {
            results[i] = data[Int(offset) + i]
        }
        
        return results
    }
    
    /// Load a file at a local path
    public static func load(path:String) -> Data? {
        return try? Data.init(contentsOf: URL.init(fileURLWithPath: path))
    }

    /// Write data to a path, overwriting if it exists
    public static func write(data:Data, path:String) -> Bool {
        do {
            try data.write(to: URL.init(fileURLWithPath: path))
            return true
        }catch {
            return false
        }
    }
}
