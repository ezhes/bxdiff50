//
//  main.swift
//  BXDIFF50-Swift
//
//  Created by Salman Husain on 8/6/19.
//  Copyright © 2019 Salman Husain. All rights reserved.
//

import Foundation

func load(path:String) -> Data? {
    guard let fileURL = URL.init(string: "file://" + path) else {return nil}
    return try? Data.init(contentsOf: fileURL)
}

func write(data:Data, path:String) -> Bool {
    guard let fileURL = URL.init(string: "file://" + path) else {return false}
    do {
        try data.write(to: fileURL)
        return true
    }catch {
        return false
    }
}

func validateMagic(of data:Data) -> Bool {
    if data.count < 8 {
        print("[!!!] Too short of a file")
        return false
    }
    let magicBytes = data[0...7]
    if magicBytes != Data.init([0x42,0x58,0x44,0x49,0x46,0x46,0x35,0x30]) {//BXDIFF50
        print("[!!!] Non-BXDIFF50 input!")
        return false
    }
    
    return true
}

if CommandLine.arguments.count != 4 {
    print("""
usage:

bxdiff50 <patch> <input_file> <output_file>
""")
    exit(1)
}

let patchPath = CommandLine.arguments[1]
let inputFilePath = CommandLine.arguments[2]
let outputFilePath = CommandLine.arguments[3]

print("[INFO] Beginning to patch binary...")
guard let patchData = load(path: patchPath) else {
    print("[!!!] Unable to load patch")
    abort()
}

if !validateMagic(of: patchData) {
    print("[!!!] Basic integrity check failed for patch. Abort.")
    abort()
}

guard let patch = BXDIFF50_Patch.init(data: patchData) else {
    print("[!!!] Failed to parse patch. Abort.")
    abort()
}

guard let patchTargetData = load(path: inputFilePath) else {
    print("[!!!] Unable to load patch target")
    abort()
}

guard let patcher = BXPatchAgent.init(input: patchTargetData, patch: patch) else {
    print("[!!!] Unable to create patcher")
    abort()
}
patcher.applyAllPatches()

if !write(data: patcher.output, path: outputFilePath) {
    print("[!!!] Unable to write out patched binary")
    abort()
}

print("[INFO] Patch complete!")
