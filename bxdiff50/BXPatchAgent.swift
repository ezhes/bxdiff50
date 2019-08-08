//
//  BXPatchAgent.swift
//  BXDIFF50-Swift
//
//  Created by Salman Husain on 8/7/19.
//  Copyright © 2019 Salman Husain. All rights reserved.
//

import Foundation
import CommonCrypto

class BXPatchAgent {
    let input:Data
    var output:Data
    let patch:BXDIFF50_Patch
    
    private var diffSeekPosition:Int = 0
    private var extraSeekPosition:Int = 0
    private var inputSeekPosition:Int = 0
    
    init?(input:Data, patch:BXDIFF50_Patch) {
        if BXPatchAgent.verifyHash(data: input, sha1Target: patch.targetSHA1) == false {
            print("[!!!] The input file does not match the provided patch")
        }else {
            print("[INFO] SHA1 from patch confirms that this input is valid")
        }
        self.patch = patch
        self.input = input
        
        output = Data.init()
    }
    
    private static func verifyHash(data:Data,sha1Target:[UInt8]) -> Bool {
        if sha1Target.count != Int(CC_SHA1_DIGEST_LENGTH) {
            return false
        }
        
        var digest = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        defer {
            digest.deallocate()
        }
        
        return data.withUnsafeBytes { (dPointer:UnsafePointer<UInt8>) -> Bool in
            CC_SHA1(dPointer, UInt32(data.count), digest)
            for i in 0..<Int(CC_SHA1_DIGEST_LENGTH) {
                if sha1Target[i] != digest[i] {
                    return false
                }
            }
            return true
        }
        
    }
    
    func applyControlSection(control:BXDIFF_Control) {
        if control.mixlen != 0 {
            for _ in 0..<control.mixlen {
                let diffByte = patch.diffData[diffSeekPosition]
                let inputByte = input[inputSeekPosition]
                output.append(diffByte &+ inputByte)
                
                diffSeekPosition += 1
                inputSeekPosition += 1
            }
        }

        if control.copylen != 0 {
            let extraPayload = patch.extraData[extraSeekPosition..<(extraSeekPosition + Int(control.copylen))]
            output.append(extraPayload)
            extraSeekPosition += extraPayload.count
        }

        if control.seeklen != 0 {
            inputSeekPosition += Int(control.seeklen)
        }
    }
    
    func applyAllPatches() {
        let expectedControlSectionCount = patch.controlData.count / BXDIFF_Control.structSize

        for i in 0..<expectedControlSectionCount {
            guard let controlI = BXDIFF_Control.init(data: patch.controlData, number: i) else {abort()}
            if i % 10 == 0 {
                print("\(i)/\(expectedControlSectionCount)")
            }
            //print("[DEBUG] Applying: \(controlI)")
            applyControlSection(control: controlI)
        }
        
        if !BXPatchAgent.verifyHash(data: output, sha1Target: patch.resultSHA1) {
            print("[!!!] Patch failed! SHA1 verification!")
        }else {
            print("[INFO] SHA1 from patch confirms that we've patched OK")
        }
    }
        
}
