//
//  BXDIFF_Control.swift
//  BXDIFF50-Swift
//
//  Created by Salman Husain on 8/7/19.
//  Copyright © 2019 Salman Husain. All rights reserved.
//

import Foundation

class BXDIFF_Control:CustomStringConvertible {
    public static let structSize:Int = 24

    let mixlen:off_t
    let copylen:off_t
    let seeklen:off_t
    
    init?(data:Data, number:Int) {
        let selfOffset = Int(BXDIFF_Control.structSize * number)
        
        mixlen = BXDIFF_Control.read_off_t(data: data, offset: 0 + selfOffset)
        copylen = BXDIFF_Control.read_off_t(data: data, offset: 8 + selfOffset)
        seeklen = BXDIFF_Control.read_off_t(data: data, offset: 16 + selfOffset)
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
        return "BXDIFF_Control {mixlen: \(mixlen), copylen: \(copylen), seeklen: \(seeklen)}"
    }
}
