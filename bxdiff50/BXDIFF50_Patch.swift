//
//  BXDIFF50_Patch.swift
//  BXDIFF50-Swift
//
//  Created by Salman Husain on 8/7/19.
//  Copyright © 2019 Salman Husain. All rights reserved.
//

import Foundation
import Compression

class BXDIFF50_Patch {
    public let patchedFileSize:uint64
    public let controlSize:uint64
    public let extraSize:uint64
    public let resultSHA1:[uint8]
    public let diffSize:uint64
    public let targetSHA1:[uint8]
    
    public let controlData:Data
    public let diffData:Data
    public let extraData:Data
    
    private let data:Data
    
    init?(data:Data) {
        self.data = data
        
        let uint64_size:uint64 = 8
        var position:uint64 = 0
        //skip magic
        position += 8
        //skip unknown
        position += uint64_size
        
        patchedFileSize = BXDIFF50_Patch.readUINT64(from: data, offset: position, bigEndian: false)
        position += uint64_size
        
        controlSize = BXDIFF50_Patch.readUINT64(from: data, offset: position, bigEndian: false)
        position += uint64_size
        
        extraSize = BXDIFF50_Patch.readUINT64(from: data, offset: position, bigEndian: false)
        position += uint64_size
        
        resultSHA1 = BXDIFF50_Patch.readUINT8Array(from: data, count: 20, offset: position)
        position += 20
        
        diffSize = BXDIFF50_Patch.readUINT64(from: data, offset: position, bigEndian: false)
        position += uint64_size
        
        targetSHA1 = BXDIFF50_Patch.readUINT8Array(from: data, count: 20, offset: position)
        position += 20
        
        //Validate the header size reports against the actuall file size
        //88 is the size of the header
        if controlSize + diffSize + extraSize + 88 != data.count {
            print("[!!!] Patch header sizes and actual size do not match. Cannot process.")
            return nil
        }
        
        let controlDataCompressed = Data.init(data[position..<(position + controlSize)])
        position += controlSize
        if !BXDIFF50_Patch.verifyPBZXBuffer(buffer: controlDataCompressed) {
            print("[!!!] Bad control data in patch")
            return nil
        }
        guard let controlData = BXDIFF50_Patch.extractPBZX(buffer: controlDataCompressed) else {
            print("[!!!] Unable to decompress control data")
            return nil
        }
        self.controlData = controlData

        
        let diffDataCompressed = Data.init(data[position..<(position + diffSize)])
        position += diffSize
        if !BXDIFF50_Patch.verifyPBZXBuffer(buffer: diffDataCompressed) {
            print("[!!!] Bad control data in patch")
            return nil
        }
        guard let diffData = BXDIFF50_Patch.extractPBZX(buffer: diffDataCompressed) else {
            print("[!!!] Unable to decompress diff data")
            return nil
        }
        self.diffData = diffData
        
        
        let extraDataCompressed = Data.init(data[position..<(position + extraSize)])
        position += extraSize
        if !BXDIFF50_Patch.verifyPBZXBuffer(buffer: extraDataCompressed) {
            print("[!!!] Bad extra data in patch")
            return nil
        }
        guard let extraData = BXDIFF50_Patch.extractPBZX(buffer: extraDataCompressed) else {
            print("[!!!] Unable to decompress extra data")
            return nil
        }
        self.extraData = extraData
    }
    
    fileprivate static func readUINT64(from data:Data,offset:uint64,bigEndian:Bool) -> uint64 {
        let n = bigEndian ? Data.init(data[offset..<offset+8].reversed()) : data[offset..<offset+8]
        return n.withUnsafeBytes { (buffer) -> uint64 in
            return buffer.bindMemory(to: uint64.self).baseAddress!.pointee
        }
    }
    
    private static func readUINT8Array(from data:Data,count:Int,offset:uint64) -> [uint8] {
        var results = [uint8].init(repeating: 0x0, count: count)
        for i in 0..<count {
            results[i] = data[Int(offset) + i]
        }
        
        return results
    }
    
    private static func verifyPBZXBuffer(buffer:Data) -> Bool {
        if buffer.count < 34 {
            return false
        }
        
        return buffer[0..<4] == Data.init([0x70,0x62,0x7a,0x78])
    }
    
    private static func extractPBZX(buffer:Data) -> Data? {
        var outputBuffer:Data? = nil
        if buffer[0..<4] != Data.init([0x70,0x62,0x7a,0x78]) {
            print("[!!!] Cannot extract buffer because it is not a pbzx buffer")
            return nil
        }
        
        var searchRange = Range.init(NSRange.init(location: 0, length: buffer.count))
        
        while true {
            guard let xzStartMagicRange = buffer.range(of: Data.init([0xfd,0x37,0x7a,0x58,0x5a]), options: [], in: searchRange) else {
                print("[DEBUG] No more sections to decode.")
                break
            }
            searchRange = (xzStartMagicRange.upperBound)..<buffer.count

            guard let xzEndrange = buffer.range(of: Data.init([0x59,0x5a]), options: [], in: searchRange) else {
                print("[DEBUG] Could not find xz end command")
                break
            }
            searchRange = (xzEndrange.upperBound)..<buffer.count

            
            let offset = uint64(xzStartMagicRange.lowerBound)
            
            let decompressSize = readUINT64(from: buffer, offset: offset - 8, bigEndian: true)
            
            print("[DEBUG] Found section @\(offset) with \(decompressSize) decompressed bytes")
            
            let _7zXZData = Data.init(buffer[offset..<(offset + decompressSize)])
            
            if _7zXZData.count < 4 {
                return nil
            }
            if _7zXZData[0..<5] != Data.init([0xfd,0x37,0x7a,0x58,0x5a]) {
                print("[!!!] PBZX buffer did not contain xz archive, failing because we're not sure how to handle this yet")
                continue
            }
            
            if _7zXZData[(_7zXZData.count - 2)..<_7zXZData.count] != Data.init([0x59,0x5a]) {
                print("[!!!] XZ buffer did not end with magic bytes")
                continue
            }
            
            //DECOMPRESS
            var streamPointer = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
            defer {
              streamPointer.deallocate()
            }
            
            var stream = streamPointer.pointee
            var status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_LZMA)
            guard status != COMPRESSION_STATUS_ERROR else {
                print("[!!!] Unable to initilize the decompression runtime")
                abort()
            }
            defer {
                compression_stream_destroy(&stream)
            }
            
            let dstSize = 1024*1024
            let dstPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: dstSize)
            defer {
                dstPointer.deallocate()
            }
            
            let optionalDecompressedData = _7zXZData.withUnsafeBytes { (srcPointer:UnsafePointer<UInt8>) -> Data? in
                var output = Data()
                
                stream.src_ptr = srcPointer
                stream.src_size = _7zXZData.count
                stream.dst_ptr = dstPointer
                stream.dst_size = dstSize
                
                while status == COMPRESSION_STATUS_OK {
                    // process the stream
                    status = compression_stream_process(&stream, 0x00)
                    
                    // collect bytes from the stream and reset
                    switch status {
                    case COMPRESSION_STATUS_OK:
                        output.append(dstPointer, count: dstSize)
                        stream.dst_ptr = dstPointer
                        stream.dst_size = dstSize
                    case COMPRESSION_STATUS_ERROR:
                        return nil
                    case COMPRESSION_STATUS_END:
                        output.append(dstPointer, count: stream.dst_ptr - dstPointer)
                    default:
                        fatalError()
                    }
                }
                return output
            }
            
            
            guard let decompressedData = optionalDecompressedData else {
                print("[!!!] Unable to decompress")
                continue
            }
            
            if outputBuffer == nil {
                outputBuffer = decompressedData
            }else {
                outputBuffer?.append(decompressedData)
            }
        }
        
        return outputBuffer
    }
}

