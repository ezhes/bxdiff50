//
//  BXDIFF50_Patch.swift
//  BXDIFF50-Swift
//
//  Created by Allison Husain on 8/7/19.
//  Copyright © 2019 Allison Husain. All rights reserved.
//

import Foundation

/// A class which parses a BXDIFF50 style diff patch. Provides information on the patch as well as decompresses the various patch buffers
class Patch {
    /// The number of bytes the resulting file should be after patching
    public let patchedFileSize:uint64
    
    /// The number of compressed bytes used by the control section
    public let controlSize:uint64
    
    /// The number of compressed bytes used by the diff section
    public let diffSize:uint64

    /// The number of compressed bytes used by the extra section
    public let extraSize:uint64
    
    /// The SHA1 hash bytes of the desired binary *after* a successful patch
    public let resultSHA1:[uint8]
    
    /// The SHA1 hash bytes of the binary which this patch was composed for
    public let targetSHA1:[uint8]
    
    /// A decompressed section of data built from three byte chunks which describes how to patch the binary
    public let controlData:Data
    
    /// The raw data used for storing changes to the binary
    public let diffData:Data
    
    /// Raw bytes which are inserted at various points
    public let extraData:Data
    
    
    /// Parse and decompress the patch
    /// - Parameter data: The BXDIFF50 patch bytes
    init?(data:Data) {
        let uint64_size:uint64 = 8
        var position:uint64 = 0

        if data.count < 88 {
            print("[!!!] Invalid patch, too short")
            return nil
        }
        
        //Verify magic
        let magicBytes = data[0...7]
        position += 8
        if magicBytes != Data.init([0x42,0x58,0x44,0x49,0x46,0x46,0x35,0x30]) {//BXDIFF50
            print("[!!!] Non-BXDIFF50 input!")
            return nil
        }
        
        //skip unknown 8 byte
        position += uint64_size
        
        patchedFileSize = Utils.readUINT64(from: data, offset: position, bigEndian: false)
        position += uint64_size
        
        controlSize = Utils.readUINT64(from: data, offset: position, bigEndian: false)
        position += uint64_size
        
        extraSize = Utils.readUINT64(from: data, offset: position, bigEndian: false)
        position += uint64_size
        
        resultSHA1 = Utils.readUINT8Array(from: data, count: 20, offset: position)
        position += 20
        
        diffSize = Utils.readUINT64(from: data, offset: position, bigEndian: false)
        position += uint64_size
        
        targetSHA1 = Utils.readUINT8Array(from: data, count: 20, offset: position)
        position += 20
        
        //Validate the header size reports against the actuall file size
        //88 is the size of the header
        if controlSize + diffSize + extraSize + 88 != data.count {
            print("[!!!] Patch header sizes and actual size do not match. Cannot process.")
            return nil
        }
        
        let controlDataCompressed = Data.init(data[position..<(position + controlSize)])
        position += controlSize
        if !PBZX.verifyPBZXBuffer(buffer: controlDataCompressed) {
            print("[!!!] Bad control data in patch")
            return nil
        }
        guard let controlData = PBZX.extractPBZX(buffer: controlDataCompressed) else {
            print("[!!!] Unable to decompress control data")
            return nil
        }
        self.controlData = controlData

        
        let diffDataCompressed = Data.init(data[position..<(position + diffSize)])
        position += diffSize
        if !PBZX.verifyPBZXBuffer(buffer: diffDataCompressed) {
            print("[!!!] Bad control data in patch")
            return nil
        }
        guard let diffData = PBZX.extractPBZX(buffer: diffDataCompressed) else {
            print("[!!!] Unable to decompress diff data")
            return nil
        }
        self.diffData = diffData
        
        
        let extraDataCompressed = Data.init(data[position..<(position + extraSize)])
        position += extraSize
        if !PBZX.verifyPBZXBuffer(buffer: extraDataCompressed) {
            print("[!!!] Bad extra data in patch")
            return nil
        }
        guard let extraData = PBZX.extractPBZX(buffer: extraDataCompressed) else {
            print("[!!!] Unable to decompress extra data")
            return nil
        }
        self.extraData = extraData
    }
}

