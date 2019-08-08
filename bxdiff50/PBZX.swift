//
//  PBZX.swift
//  bxdiff50
//
//  Created by Salman Husain on 8/8/19.
//  Copyright © 2019 Salman Husain. All rights reserved.
//

import Foundation
import Compression

/// PBZX decomperssion utilities
class PBZX {
    /// Verify that a buffer is a PBZX buffer using magic bytes
    public static func verifyPBZXBuffer(buffer:Data) -> Bool {
        if buffer.count < 34 {
            return false
        }
        
        return buffer[0..<4] == Data.init([0x70,0x62,0x7a,0x78])
    }
    
    /// Attempt to extract all XZ archives contained within a PBZX buffer.
    /// If there are multiple XZ archives, their contents will be appended
    public static func extractPBZX(buffer:Data) -> Data? {
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
            
            let decompressSize = Utils.readUINT64(from: buffer, offset: offset - 8, bigEndian: true)
            
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
