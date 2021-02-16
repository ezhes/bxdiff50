//
//  BXDIFF_Control.swift
//  BXDIFF50-Swift
//
//  Created by Allison Husain on 8/7/19.
//  Copyright © 2019 Allison Husain. All rights reserved.
//

import Foundation

/// A class which interprets a BXDIFF50 control command at a given offset in the control section of a patch
class Control:CustomStringConvertible {
    /// How many bytes a control element is in the decompressed buffer
    public static let controlSize:Int = 24 // 3 * 8 bytes

    /// How many bytes to "mix" (add from the current patch offset to the current input offset, mod 256)
    let mixlen:off_t
    
    /// How many bytes should be copied off the "extra" section
    let copylen:off_t
    
    /// How many bytes to advance (or reverse) the input pointer
    let seeklen:off_t
    
    
    /// Attempt to parse a new control command from the decompressed control buffer
    /// - Parameter data: The decompressed control buffer
    /// - Parameter number: The index to decompress
    init?(data:Data, number:Int) {
        let selfOffset = Int(Control.controlSize * number)
        
        mixlen = Control.read_off_t(data: data, offset: 0 + selfOffset)
        copylen = Control.read_off_t(data: data, offset: 8 + selfOffset)
        seeklen = Control.read_off_t(data: data, offset: 16 + selfOffset)
    }
    
    
    /// Convert a uint64 represented value in to an off_t
    /// - Parameter data: The backing buffer
    /// - Parameter offset: the offset at which to read (8 bytes)
    private static func read_off_t(data:Data,offset:Int) -> off_t {
        let b = Data.init(data[offset..<(offset + 8)])
        
        var y:off_t = off_t(b[7]) & 0x7f
        for i in (0...6).reversed() {
            y <<= 8
            y += off_t(b[i])
        }
        if b[7] & 0x80 != 0 {
            y = -y
        }
        return y
    }
        
    var description: String {
        return "BXDIFF50_Control {mixlen: \(mixlen), copylen: \(copylen), seeklen: \(seeklen)}"
    }
}
