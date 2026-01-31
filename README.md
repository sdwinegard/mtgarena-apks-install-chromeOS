# mtgarena-apks-install-chromeOS
How to manually install MTG Arena on an unsupported Android or ChromeOS device without developer mode enabled

# Split-APK (APKS) Installation Process

**Download latest APKs**  
[https://rwilco12.com/downloads.php?dir=Files/Apps/Magic%20The%20Gathering%20Arena](https://rwilco12.com/downloads.php?dir=Files/Apps/Magic%20The%20Gathering%20Arena)  

Let’s assume the latest APKs is named Magic_com,wizards,mtga_2026,55,20,5532.apks an you downloaded it to the Downloads folder on your device

Right click on this files and rename it by changing the extension of the file from .apks to .zip 

Right click on the zip file and extract all

All of the files within will be extracted into:

`Downloads/Magic_com,wizards,mtga_2026,55,20,5532`

Open a Linux shell:
`$ adb devices`

Enter the ADB shell:
`$ adb shell`

From the ADB shell, change into the extracted download folder above to calculate the APK files sizes:
`$ cd /sdcard/Downloads/Magic_com,wizards,mtga_2026,55,20,5532`
`$ ls -l *.apk`

`-rwxrwx--- 1 u0_a60 external_storage 36529517 2026-01-30 11:48 base.apk`
`-rwxrwx--- 1 u0_a60 external_storage 40105015 2026-01-30 11:48 split_UnityDataAssetPack.apk`
`-rwxrwx--- 1 u0_a60 external_storage 52245769 2026-01-30 11:48 split_config.arm64_v8a.apk`

The total size you want to calculate is the sum of the fourth column (36529517 + 40105015 + 52245769), which is 128880301 bytes. 

Tell the package manager to create a new installation session using the calculated file size:

`$ pm install-create -S 128880301`
`Success: created install session [1778358657]` 

Note the new installation session ID is 1778358657. 

Stage all three APK files:

`$ cat base.apk | pm install-write -S 36529517 1778358657 0`
`Success: streamed 36529517 bytes`

`$ cat split_UnityDataAssetPack.apk | pm install-write -S 40105015 1778358657 1`
`Success: streamed 40105015 bytes`

`$ cat split_config.arm64_v8a.apk | pm install-write -S 52245769 1778358657 2`
`Success: streamed 52245769 bytes`

Commit the staged files for installation:

`$ pm install-commit 1778358657`
`Success`

Launch Arena on your Chromebook. It will Download new files, updates, etc. and will likely ask you to login again. 

You can delete the Zip file and the extracted files from your Download folder.
