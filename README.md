## BXDIFF50 Patcher

BXDIFF50 is a propritary Apple binary format used for patching system components during an OTA upgrade.

### Usage

`./bxdiff50 <patch> <input_file> <output_file>`

### Compiling

Building on macOS is very simple as this project uses exclusively standard library resources. Simply open the Xcode probject and build. 

If you're using Swift on Linux, your runtime must have the `CommonCrypto` and `Compression` modules availble in some functional form. This is an unsupported configuration so really you're on your own.

### Patching example output

Below is the output of patching the `shargind` binary from iOS build 16F5156a (12.3 beta) on the iPhone X to build 16G5027i (12.4 beta) using the [c1cc5c87b52523ccc1d226306ec39ed389bde607.zip](https://ipsw.me/api/ios/v4/ota/download/iPhone10,6/16G5027i?prerequisite=16F5156a) OTA. To verify your build, these binaries have been included in the repo as well under /sharingd_test

```
allison@Allisons-MacBook-Pro sharingd_test % ./bxdiff50 patch ef28d87c911f1ab1b1bc68b436346a7eb91d8d6e_sharingd_source output_test
[INFO] Beginning to patch binary...
[DEBUG] Found section @28 with 408 decompressed bytes
[DEBUG] No more sections to decode.
[DEBUG] Found section @28 with 32456 decompressed bytes
[DEBUG] Found section @32500 with 15520 decompressed bytes
[DEBUG] Found section @48036 with 8276 decompressed bytes
[DEBUG] Found section @56328 with 11144 decompressed bytes
[DEBUG] Found section @67488 with 220 decompressed bytes
[DEBUG] No more sections to decode.
[DEBUG] Found section @28 with 40788 decompressed bytes
[DEBUG] No more sections to decode.
[INFO] SHA1 from patch confirms that this input is valid
0/73
[DEBUG] Applying: BXDIFF50_Control {mixlen: 10926, copylen: 0, seeklen: 80}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 89998, copylen: 0, seeklen: 32}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 144, copylen: 0, seeklen: 20}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 22, copylen: 0, seeklen: 32}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 30, copylen: 0, seeklen: -52}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 27, copylen: 0, seeklen: 396}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 12, copylen: 0, seeklen: -656}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 0, copylen: 0, seeklen: 228}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 252653, copylen: 0, seeklen: 72}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 170, copylen: 0, seeklen: -36}
10/73
[DEBUG] Applying: BXDIFF50_Control {mixlen: 0, copylen: 0, seeklen: -36}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 125634, copylen: 0, seeklen: 64}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 171, copylen: 0, seeklen: -16}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 21, copylen: 0, seeklen: 20}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 22, copylen: 0, seeklen: 212}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 43, copylen: 0, seeklen: -156}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 9, copylen: 0, seeklen: -92}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 58, copylen: 0, seeklen: -96}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 36, copylen: 24, seeklen: 208}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 6, copylen: 0, seeklen: -120}
20/73
[DEBUG] Applying: BXDIFF50_Control {mixlen: 381642, copylen: 0, seeklen: 32}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 192, copylen: 0, seeklen: 20}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 22, copylen: 0, seeklen: -52}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 11496, copylen: 0, seeklen: 368}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 62, copylen: 2, seeklen: 182}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 14, copylen: 0, seeklen: -596}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 287388, copylen: 0, seeklen: 24}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 152, copylen: 4, seeklen: 12}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 18, copylen: 0, seeklen: -32}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 141718, copylen: 0, seeklen: 64}
30/73
[DEBUG] Applying: BXDIFF50_Control {mixlen: 374, copylen: 0, seeklen: -32}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 0, copylen: 0, seeklen: -32}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 674, copylen: 0, seeklen: 64}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 310, copylen: 0, seeklen: -32}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 0, copylen: 0, seeklen: -32}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 1270310, copylen: 0, seeklen: -96}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 13398, copylen: 0, seeklen: 96}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 55458, copylen: 6, seeklen: 4}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 328, copylen: 6, seeklen: 4}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 43202, copylen: 6, seeklen: 4}
40/73
[DEBUG] Applying: BXDIFF50_Control {mixlen: 8176, copylen: 6, seeklen: 4}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 3902, copylen: 6, seeklen: 4}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 11578, copylen: 6, seeklen: 4}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 13051, copylen: 6, seeklen: 4}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 54724, copylen: 0, seeklen: -2}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 1342, copylen: 6, seeklen: 4}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 43, copylen: 0, seeklen: 407786}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 12, copylen: 0, seeklen: -407800}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 3011, copylen: 6, seeklen: 4}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 43, copylen: 0, seeklen: 2}
50/73
[DEBUG] Applying: BXDIFF50_Control {mixlen: 5439, copylen: 6, seeklen: 4}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 30, copylen: 0, seeklen: 2}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 11420, copylen: 6, seeklen: 4}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 35, copylen: 0, seeklen: 2}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 332320, copylen: 5, seeklen: -537}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 1, copylen: 0, seeklen: 540}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 138, copylen: 5, seeklen: -679}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 1, copylen: 0, seeklen: 682}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 280, copylen: 5, seeklen: 1698017}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 1, copylen: 0, seeklen: -1698013}
60/73
[DEBUG] Applying: BXDIFF50_Control {mixlen: 364, copylen: 0, seeklen: 1}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 24526, copylen: 0, seeklen: 1940}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 0, copylen: 0, seeklen: -1936}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 45307, copylen: 0, seeklen: -480}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 274, copylen: 0, seeklen: 80}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 40, copylen: 0, seeklen: 80}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 0, copylen: 0, seeklen: 320}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 512038, copylen: 0, seeklen: -8}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 46910, copylen: 0, seeklen: 8}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 101094, copylen: 0, seeklen: 14}
70/73
[DEBUG] Applying: BXDIFF50_Control {mixlen: 49, copylen: 0, seeklen: 18}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 10, copylen: 0, seeklen: -32}
[DEBUG] Applying: BXDIFF50_Control {mixlen: 918469, copylen: 52121, seeklen: 34432}
[INFO] SHA1 from patch confirms that we've patched OK
[INFO] Patch complete!

```

and when comparing the SHA1 of the synthetic `output_test` to `7664ff8e1b0f6254b57bb78103158d825654b322_sharingd_target` (shargind extracted from a full upgrade/non-patch install of 16G5027i) we find that they are equal, indictating that the patch verification scheme is correct and the patch was completetly successful:

```
allison@Allisons-MacBook-Pro sharingd_test % shasum output_test 7664ff8e1b0f6254b57bb78103158d825654b322_sharingd_target
39f32b1d9dd5f9f270c492120b15107c8d0398ae  output_test
39f32b1d9dd5f9f270c492120b15107c8d0398ae  7664ff8e1b0f6254b57bb78103158d825654b322_sharingd_target
```