//
//  BXPatchAgent.swift
//  BXDIFF50-Swift
//
//  Created by Allison Husain on 8/7/19.
//  Copyright © 2019 Allison Husain. All rights reserved.
//

import Foundation
import CommonCrypto

/// An object which facilitates patching
class PatchSession {
    
    /// The source binary to be patched
    private let input:Data
    
    /// The binary data after being patched
    private var output:Data
    
    /// The patch used for patching
    private let patch:Patch
    
    // various positions used for tracking the read locaiton in the differnt source buffers
    private var diffSeekPosition:Int = 0
    private var extraSeekPosition:Int = 0
    private var inputSeekPosition:Int = 0
    
    
    /// Attempt to create a new patch session
    /// This method verifies the SHA1 of the input against the patch's input to ensure that patch is valid for the binary
    /// - Parameter input: The bytes to patch
    /// - Parameter patch: The patch to apply to the input
    init?(input:Data, patch:Patch) {
        if PatchSession.verifyHash(data: input, sha1Target: patch.targetSHA1) == false {
            print("[!!!] The input file does not match the provided patch")
        }else {
            print("[INFO] SHA1 from patch confirms that this input is valid")
        }
        self.patch = patch
        self.input = input
        
        output = Data.init()
    }
    
    /// Compute the SHA1 of the data, and return true if it matches the target
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
    
    /// Apply the set of operations described in a control struct. This advances the buffer positions in the session and adds bytes to the output
    func applyControlSection(control:Control) {
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
    
    /// Attempt to patch the binary
    public func applyAllPatches() -> Data? {
        if output.count != 0 {
            print("[!!!] Cannot reuse session, output buffer is dirty")
            return nil
        }
        
        let expectedControlSectionCount = patch.controlData.count / Control.controlSize
        
        for i in 0..<expectedControlSectionCount {
            guard let controlI = Control.init(data: patch.controlData, number: i) else {abort()}
            if i % 10 == 0 {
                print("\(i)/\(expectedControlSectionCount)")
            }
            print("[DEBUG] Applying: \(controlI)")
            applyControlSection(control: controlI)
        }
        
        if !PatchSession.verifyHash(data: output, sha1Target: patch.resultSHA1) {
            print("[!!!] Patch failed! SHA1 verification!")
            return nil
        }else {
            print("[INFO] SHA1 from patch confirms that we've patched OK")
            return output
        }
    }
}
