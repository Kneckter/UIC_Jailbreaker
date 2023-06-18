# UIC_Jailbreaker
An Xcode UI Test that can be used with unc0ver to jailbreak an iPhone without human intervention. 

# Setup
1. Start by cloning this repo to a Mac: `git clone git@github.com:Kneckter/UIC_Jailbreaker.git`
2. Change into the folder and install the pods: `cd UIC_Jailbreaker && pod install`
  - You may need to `sudo gem install cocoapods` if it is not installed
3. Launch the workspace `UIC_Jailbreaker.xcworkspace` by double clicking on it.
4. In Xcode, click on the project file in the left view to edit its properties.
5. In the tab bar, click on `Signing & Capabilities` and select your team from the drop down.
6. Switch from `UIC_Jailbreaker` (first button on the tab bar) to `UIC_JailbreakerUITests` and also pick your team there.
7. Select `Product` from the menu and click on the `Build` option. It should successfully build.
8. Select `Product` from the menu, hover over `Build For`, and click on the `Testing` option. It should successfully build.
9. If both built successfully, close Xcode and we will run the app from the command line. Otherwise, troubleshoot the errors.

# Usage
Once the repo is setup, you can build and run this from any folder by using commands or scripts. For this setup, we will build the project once and create copies of it for each iDevice we run it against. The following command will create a `DerivedData` folder in the working directory that houses the built files.
```
xcodebuild build-for-testing -workspace ~/UIC_Jailbreaker/UIC_Jailbreaker.xcworkspace -scheme UIC_Jailbreaker -destination generic/platform=iOS -derivedDataPath ./DerivedData/Template
```
After that completes, copy it and run the tests that will execute unc0ver to jailbreak the device.
```
UUID=uuid_string
D=device_name_string
cp -r ./DerivedData/Template ./DerivedData/$UUID
xcodebuild test-without-building -workspace ~/UIC_Jailbreaker/UIC_Jailbreaker.xcworkspace -scheme UIC_Jailbreaker -destination id=$UUID -destination-timeout 200 -derivedDataPath ./DerivedData/$UUID name=$D
```
The test app should exit with a pass but there can be fails-positives or fails-negatives in rare occasions. 

# Troubleshooting
If you see `errSecInternalComponent` in the build error, you need to unlock the keychain with `security unlock-keychain login.keychain` and enter your password or `security unlock-keychain -p <Password> login.keychain` to automate it in a script before executing the xcodebuild.

Don't have Xcode IDE open after the JB process is initiated. It will cause issues like not being able to use SSH after the JB process is complete.

# Misc.
**Update Unc0ver?**
Feel free to try different versions of unc0ver with different iOS versions. Below are my results with one test device. You can use this command to swap through versions quickly and then run the test build: `ios-deploy --id <ID> --uninstall --bundle_id science.xnu.undecimus -b resigned-unc0ver_Release_8.0.1.ipa`. Let me know if you know of another app-based jailbreak.
```
8.0.2 failed to find offsets multiple times on iPhone SE (Gen1) iOS 14.3
8.0.1 failed to find offsets multiple times on iPhone SE (Gen1) iOS 14.3
8.0.0 failed to find offsets multiple times on iPhone SE (Gen1) iOS 14.3
7.0.2 failed to find offsets multiple times on iPhone SE (Gen1) iOS 14.3
7.0.1 failed to find offsets multiple times on iPhone SE (Gen1) iOS 14.3
7.0.0 failed to find offsets multiple times on iPhone SE (Gen1) iOS 14.3
6.2.0 failed to find offsets multiple times on iPhone SE (Gen1) iOS 14.3
6.1.2 worked multiple times on iPhone SE (Gen1) iOS 14.3
```
