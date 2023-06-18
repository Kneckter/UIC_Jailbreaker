# UIC_Jailbreaker
An Xcode UI Test that can be used with unc0ver to jailbreak an iPhone without human intervention. 

# Setup
git clone
pod install
    `sudo gem install cocoapods` if needed
setup your team for the app and testapp

# Usage
xcodebuild build-for-testing -workspace ~/UIC_Jailbreaker/UIC_Jailbreaker.xcworkspace -scheme UIC_Jailbreaker -destination generic/platform=iOS -derivedDataPath ./DerivedData/Template

xcodebuild test-without-building -workspace ~/UIC_Jailbreaker/UIC_Jailbreaker.xcworkspace -scheme UIC_Jailbreaker -destination id=$UUID -destination-timeout 200 -derivedDataPath ./DerivedData/$UUID name=$D


# Troubleshooting
If you see `errSecInternalComponent` in the build error, you need to unlock the keychain

Don't have Xcode IDE open after the JB process is going through its steps because it will cause issues like not being able to use SSH after the JB process is complete.

# Misc
**Update Unc0ver?**
Feel free to try different versions of unc0ver with different iOS versions. Below are my results with one test device. You can use this command to swap through versions quickly and then run the test build. `ios-deploy --id <ID> --uninstall --bundle_id science.xnu.undecimus -b resigned-unc0ver_Release_8.0.1.ipa`
```
8.0.2 failed to find offsets multiple times on iPhone SE iOS 14.3
8.0.1 failed to find offsets multiple times on iPhone SE iOS 14.3
8.0.0 failed to find offsets multiple times on iPhone SE iOS 14.3
7.0.2 failed to find offsets multiple times on iPhone SE iOS 14.3
7.0.1 failed to find offsets multiple times on iPhone SE iOS 14.3
7.0.0 failed to find offsets multiple times on iPhone SE iOS 14.3
6.2.0 failed to find offsets multiple times on iPhone SE iOS 14.3
6.1.2 worked multiple times on iPhone SE iOS 14.3
```
