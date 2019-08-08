//
//  main.swift
//  BXDIFF50-Swift
//
//  Created by Salman Husain on 8/6/19.
//  Copyright © 2019 Salman Husain. All rights reserved.
//

import Foundation


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
guard let patchData = Utils.load(path: patchPath) else {
    print("[!!!] Unable to load patch")
    abort()
}

guard let patch = Patch.init(data: patchData) else {
    print("[!!!] Failed to parse patch. Abort.")
    abort()
}

guard let patchTargetData = Utils.load(path: inputFilePath) else {
    print("[!!!] Unable to load patch target")
    abort()
}

guard let patcher = PatchSession.init(input: patchTargetData, patch: patch) else {
    print("[!!!] Unable to create patcher")
    abort()
}
guard let output = patcher.applyAllPatches() else {
    print("[!!!] Patch failure")
    abort()
}

if !Utils.write(data: output, path: outputFilePath) {
    print("[!!!] Unable to write out patched binary")
    abort()
}

print("[INFO] Patch complete!")
