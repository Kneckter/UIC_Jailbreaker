//
//  Created by Kasmar 2023-06-17.
//
// Copyright (c) 2023, Kasmar
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. 

import Foundation
import XCTest

class UIC_JailbreakerTests: XCTestCase {

    internal var app: XCUIApplication { return XCUIApplication(bundleIdentifier: "science.xnu.undecimus") }
    internal var deviceConfig: DeviceConfigProtocol { return DeviceConfig.global }
    var systemAlertMonitorToken: NSObjectProtocol? = nil

    var lastTestIndex: Int {
        get {
            if UserDefaults.standard.object(forKey: "last_test_index") == nil {
                return 0
            }
            return UserDefaults.standard.integer(forKey: "last_test_index")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "last_test_index")
            UserDefaults.standard.synchronize()
        }
    }

    func checkJailbreakButton() -> Bool {
        Log.info("Checking for the jailbreak button")
        let screenshotComp = XCUIScreen.main.screenshot()
        if screenshotComp.rgbAtLocation(
                pos: deviceConfig.jailbreakButton,
                min: (red: 0.24, green: 0.50, blue: 0.98),
                max: (red: 0.28, green: 0.54, blue: 1.00)){
            return true
        } else {
            return false
        }
    }

    func checkCloseSupportButton() -> Bool {
        Log.info("Checking for the close support button")
        let screenshotComp = XCUIScreen.main.screenshot()
        if screenshotComp.rgbAtLocation(
                pos: deviceConfig.closeSupportButton,
                min: (red: 0.00, green: 0.00, blue: 0.00),
                max: (red: 0.10, green: 0.10, blue: 0.10)){
            return true
        } else {
            return false
        }
    }

    func checksshButton() -> Bool {
        Log.info("Checking for the SSH install button")
        let screenshotComp = XCUIScreen.main.screenshot()
        if screenshotComp.rgbAtLocation(
                pos: deviceConfig.sshButton,
                min: (red: 0.00, green: 0.45, blue: 0.98),
                max: (red: 0.02, green: 0.49, blue: 1.00)){
            return true
        } else {
            return false
        }
    }
    
    func checkDarkButton() -> Bool {
        Log.info("Checking for the Dark Mode button")
        let screenshotComp = XCUIScreen.main.screenshot()
        if screenshotComp.rgbAtLocation(
                pos: deviceConfig.darkButton,
                min: (red: 0.95, green: 0.95, blue: 0.95),
                max: (red: 1.00, green: 1.00, blue: 1.00)){
            return true
        } else {
            return false
        }
    }

    func part0Setup() {

        print("[STATUS] Starting")

        if let systemAlertMonitorToken = self.systemAlertMonitorToken {
            Log.info("Unregistered UI Interruption Monitor")
            removeUIInterruptionMonitor(systemAlertMonitorToken)
            self.systemAlertMonitorToken = nil
        }
        // Check if the device is in GAM/SAM
        if UIAccessibility.isGuidedAccessEnabled {
            lastTestIndex = -1
            return
        }

        app.terminate()

        // Wake up device if screen is off (recently rebooted), then press home to get to home screen.
        Log.info("Waking up the device")
        XCUIDevice.shared.press(.home)
        XCUIDevice.shared.press(.home)

        app.launch()
        while app.state != .runningForeground {
            sleep(1)
            app.activate()
            Log.info("Waiting for App to run in foreground. Currently \(app.state).")
        }
        DeviceConfig.setup(app: app)
        Log.info("Registered UI Interruption Monitor")
        systemAlertMonitorToken = addUIInterruptionMonitor(withDescription: "System Dialog") {
            (alert) -> Bool in
            let okButton = alert.buttons["OK"]
            if okButton.exists { okButton.tap() }
            
            let allowButton = alert.buttons["Allow"]
            if allowButton.exists { allowButton.tap() }
            
            let dismissButton = alert.buttons["Dismiss"]
            if dismissButton.exists { dismissButton.tap() }
            
            let trustButton = alert.buttons["Trust"]
            if trustButton.exists { trustButton.tap() }
            
            let notNowButton = alert.buttons["Not Now"]
            if notNowButton.exists { notNowButton.tap() }
            
            let alwaysButton = alert.buttons["Always"]
            if alwaysButton.exists { alwaysButton.tap() }
            
            let cancelButton = alert.buttons["Cancel"]
            if cancelButton.exists { cancelButton.tap() }
            
            let laterButton = alert.buttons["Later"]
            if laterButton.exists { laterButton.tap() }
            
            let remindmelaterButton = alert.buttons["Remind Me Later"]
            if remindmelaterButton.exists { remindmelaterButton.tap() }
            
            let closeButton = alert.buttons["Close"]
            if closeButton.exists { closeButton.tap() }
            
            let allowWhileUsingButton = alert.buttons["Allow While Using App"]
            if allowWhileUsingButton.exists { allowWhileUsingButton.tap() }
            
            return true
        }
        app.tap()
    }
    
    func part1RunJB() {
        var popupsDone = false
        var count = 0
        while !popupsDone {
            if app.state != .runningForeground {
                app.launch()
                sleep(10)
            }
            Log.info("Checking for system pop-ups")
            if let systemAlertMonitorToken = self.systemAlertMonitorToken {
                removeUIInterruptionMonitor(systemAlertMonitorToken)
                self.systemAlertMonitorToken = nil
            }
            systemAlertMonitorToken = addUIInterruptionMonitor(withDescription: "System Dialog") {
                (alert) -> Bool in
                let okButton = alert.buttons["OK"]
                if okButton.exists { okButton.tap() }

                let allowButton = alert.buttons["Allow"]
                if allowButton.exists { allowButton.tap() }

                let allowWhileUsingButton = alert.buttons["Allow While Using App"]
                if allowWhileUsingButton.exists { allowWhileUsingButton.tap() }

                return true
            }
            app.tap()
            count += 1
            
            if count >= 5 {
                popupsDone = true
            }
            sleep(1)
        }
        // Color check for jb button
        if checkJailbreakButton() {
            Log.info("Jailbreak button found. Confirmed unc0ver startup.")
            // Set the app options
            Log.info("Tapping Settings button.")
            deviceConfig.settingsButton.toXCUICoordinate(app: app).tap()
            sleep(2)
            if checkDarkButton() {
                Log.info("Dark Mode is disabled as intended.")
            }
            else {
                Log.info("Dark Mode is enabled. Tapping button to disable it.")
                deviceConfig.darkButton.toXCUICoordinate(app: app).tap()
                sleep(2)
            }
            if checksshButton() {
                Log.info("Install SSH is enabled as intended.")
            }
            else {
                Log.info("Install SSH is disabled. Tapping SSH button to enable it.")
                deviceConfig.sshButton.toXCUICoordinate(app: app).tap()
                sleep(2)
            }
            Log.info("Tapping the Done button.")
            deviceConfig.doneButton.toXCUICoordinate(app: app).tap()
            sleep(2)
            
            Log.info("Tapping Jailbreak button now.")
            deviceConfig.jailbreakButton.toXCUICoordinate(app: app).tap()
            // Sleep until the black ad is displayed. Then close it and tap to OK popup
            sleep(60)
            var jbDone = false
            count = 0
            while !jbDone {
                // Check for Substrate permissions to send reports
                if let systemAlertMonitorToken = self.systemAlertMonitorToken {
                    removeUIInterruptionMonitor(systemAlertMonitorToken)
                    self.systemAlertMonitorToken = nil
                }
                systemAlertMonitorToken = addUIInterruptionMonitor(withDescription: "System Dialog") {
                    (alert) -> Bool in

                    let dontAllow = alert.buttons["Don't Allow"]
                    if dontAllow.exists { dontAllow.tap() }

                    let neverAllow = alert.buttons["Never Allow"]
                    if neverAllow.exists { neverAllow.tap() }

                    return true
                }
                app.tap()
                // Check for X
                if checkCloseSupportButton() {
                    Log.info("Close Support button found. Tapping it.")
                    deviceConfig.closeSupportButton.toXCUICoordinate(app: app).tap()
                    jbDone = true
                    sleep(2)
                }
                else {
                    sleep(10)
                }
                count += 1
                if count >= 12 {
                    jbDone = true
                    lastTestIndex = -2
                }
            }
            //Close system prompt to reboot
            if let systemAlertMonitorToken = self.systemAlertMonitorToken {
                removeUIInterruptionMonitor(systemAlertMonitorToken)
                self.systemAlertMonitorToken = nil
            }
            systemAlertMonitorToken = addUIInterruptionMonitor(withDescription: "System Dialog") {
                (alert) -> Bool in
                let okButton = alert.buttons["OK"]
                if okButton.exists { okButton.tap() }
                return true
            }
            app.tap()
        }
        else {
            Log.error("Jailbreak button was not found. Exiting.")
        }
    }
    
    func runAll() {
        defer {
            if let systemAlertMonitorToken = self.systemAlertMonitorToken {
                Log.info("Unregistered UI Interruption Monitor")
                removeUIInterruptionMonitor(systemAlertMonitorToken)
            }
        }
        
        while true {
            switch lastTestIndex {
            case 0:
                lastTestIndex = 1
                part0Setup()
            case 1:
                lastTestIndex = 2
                part1RunJB()
            default:
                return
            }
        }
    }

    func test0() {
        lastTestIndex = 0
    }
    
    func test1() {
        runAll()
        if lastTestIndex == 2 {
            Log.info("Completed the JB process!")
            XCTAssert(true, "Completed the JB process!")
        }
        else if lastTestIndex == -1 {
            Log.error("Error: Cannot start the JB process while in GAM/SAM.")
            XCTFail("Error: Cannot start the JB process while in GAM/SAM.")
        }
        else if lastTestIndex == -2 {
            Log.error("Error: Timed out waiting for the JB process to complete.")
            XCTFail("Error: Timed out waiting for the JB process to complete.")
        }
        else {
            Log.error("Error: Unknown error.")
            XCTFail("Error: Unknown error.")
        }
    }
}

protocol DeviceConfigProtocol {

    /** Blue pixel in the jailbreak button. */
    var jailbreakButton: DeviceCoordinate { get }
    /** Black pixel in the X button. */
    var closeSupportButton: DeviceCoordinate { get }
    /** Center of the Settings button. */
    var settingsButton: DeviceCoordinate { get }
    /** Center of the white SSH button. */
    var sshButton: DeviceCoordinate { get }
    /** Center of the white Dark Mode button. */
    var darkButton: DeviceCoordinate { get }
    /** D of the Done button. */
    var doneButton: DeviceCoordinate { get }

}

class DeviceConfig {
    
    public static private(set) var global: DeviceConfigProtocol!
    
    public static func setup(app: XCUIApplication) {
        let tapMultiplier: Double
        if #available(iOS 13.0, *)
        {
            if app.frame.size.width == 414 { tapMultiplier = 1/3 }
            else { tapMultiplier = 0.5 }
        }
        else { tapMultiplier = 1.0 }
        
        let ratio = Int(app.frame.size.height / app.frame.size.width * 1000)
        
        if ratio >= 1770 && ratio <= 1780 { // iPhones
            switch app.frame.size.width {
            case 375: // iPhone Normal
                // iPhone 6, 6S, 7
                Log.info("Normal size phone")
                global = DeviceIPhoneNormal(width: Int(app.frame.size.width), height: Int(app.frame.size.height), multiplier: 1.0, tapMultiplier: tapMultiplier)
            case 414: // iPhone Large
                // iPhone 6+, 6S+, 7+, 8+
                Log.info("Large size phone")
                global = DeviceIPhonePlus(width: Int(app.frame.size.width), height: Int(app.frame.size.height), multiplier: 1.5, tapMultiplier: tapMultiplier)
            default: // other iPhones
                // iPhone 5S, SE
                Log.info("Other size phone")
                global = DeviceRatio1775(width: Int(app.frame.size.width), height: Int(app.frame.size.height), multiplier: 1.0, tapMultiplier: tapMultiplier)
            }
        } else if ratio >= 1330 && ratio <= 1340 { // iPad
            global = DeviceRatio1333(width: Int(app.frame.size.width), height: Int(app.frame.size.height), multiplier: 1.0, tapMultiplier: tapMultiplier)
        } else {
            Log.error("Unsuported Device")
            fatalError("Unsuported Device")
        }
    }
}

class DeviceRatio1775: DeviceConfigProtocol {
    // This is for iPhone SE
    private var scaler: DeviceCoordinateScaler
    var tapScaler: Double
    
    required init(width: Int, height: Int, multiplier: Double=1.0, tapMultiplier: Double=1.0) {
        self.scaler = DeviceCoordinateScaler(widthNow: width, heightNow: height, widthTarget: 320, heightTarget: 568, multiplier: multiplier, tapMultiplier: tapMultiplier)
        self.tapScaler = tapMultiplier
    }
    
    var jailbreakButton: DeviceCoordinate {
        return DeviceCoordinate(x: 300, y: 960, scaler: scaler)
    }
    var closeSupportButton: DeviceCoordinate {
        return DeviceCoordinate(x: 60, y: 150, scaler: scaler)
    }
    var settingsButton: DeviceCoordinate {
        return DeviceCoordinate(x: 80, y: 90, scaler: scaler)
    }
    var sshButton: DeviceCoordinate {
        return DeviceCoordinate(x: 530, y: 950, scaler: scaler)
    }
    var darkButton: DeviceCoordinate {
        return DeviceCoordinate(x: 530, y: 425, scaler: scaler)
    }
    var doneButton: DeviceCoordinate {
        return DeviceCoordinate(x: 512, y: 84, scaler: scaler)
    }

}

class DeviceIPhoneNormal: DeviceRatio1775 {

    override var jailbreakButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, tapScaler: tapScaler)
    }
    override var closeSupportButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, tapScaler: tapScaler)
    }
    override var settingsButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, tapScaler: tapScaler)
    }
    override var sshButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, tapScaler: tapScaler)
    }
    override var doneButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, tapScaler: tapScaler)
    }

}

class DeviceIPhonePlus: DeviceRatio1775 {

    override var jailbreakButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, tapScaler: tapScaler)
    }
    override var closeSupportButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, tapScaler: tapScaler)
    }
    override var settingsButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, tapScaler: tapScaler)
    }
    override var sshButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, tapScaler: tapScaler)
    }
    override var darkButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, tapScaler: tapScaler)
    }
    override var doneButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, tapScaler: tapScaler)
    }

}

class DeviceRatio1333: DeviceConfigProtocol {

    private var scaler: DeviceCoordinateScaler

    required init(width: Int, height: Int, multiplier: Double=1.0, tapMultiplier: Double=1.0) {
        self.scaler = DeviceCoordinateScaler(widthNow: width, heightNow: height, widthTarget: 768, heightTarget: 1024, multiplier: multiplier, tapMultiplier: tapMultiplier)
    }

    var jailbreakButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, scaler: scaler)
    }
    var closeSupportButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, scaler: scaler)
    }
    var settingsButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, scaler: scaler)
    }
    var sshButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, scaler: scaler)
    }
    var darkButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, scaler: scaler)
    }
    var doneButton: DeviceCoordinate {
        return DeviceCoordinate(x: 0, y: 0, scaler: scaler)
    }
}

class Log {
    
    private init() {}
    
    public static func error(_ message: String) {
        print("[ERROR] \(message)")
    }
    
    public static func info(_ message: String) {
        print("[INFO] \(message)")
    }
}

struct DeviceCoordinate {
    
    public var x: Int
    public var y: Int
    public var tapx: Int
    public var tapy: Int
    
    public init(x: Int, y: Int, tapScaler: Double) {
        self.x = x
        self.y = y
        self.tapx = lround(Double(x) * tapScaler)
        self.tapy = lround(Double(y) * tapScaler)
    }
    
    public init(x: Int, y: Int, scaler: DeviceCoordinateScaler) {
        self.x = scaler.scaleX(x: x)
        self.y = scaler.scaleY(y: y)
        self.tapx = scaler.tapScaleX(x: x)
        self.tapy = scaler.tapScaleY(y: y)
    }
    
    public func toXCUICoordinate(app: XCUIApplication) -> XCUICoordinate {
        return app.coordinate(withNormalizedOffset: CGVector.zero).withOffset(CGVector(dx: tapx, dy: tapy))
    }
    
    public func toXY() -> (x: Int, y: Int) {
        return (x, y)
    }
    
}

struct DeviceCoordinateScaler {
    
    public var widthNow: Int
    public var heightNow: Int
    public var widthTarget: Int
    public var heightTarget: Int
    public var multiplier: Double
    public var tapMultiplier: Double
    
    public func scaleX(x: Int) -> Int {
        return lround(Double(x) * Double(widthNow) / Double(widthTarget) * multiplier)
    }
    
    public func scaleY(y: Int) -> Int {
        return lround(Double(y) * Double(heightNow) / Double(heightTarget) * multiplier)
    }
    
    public func tapScaleX(x: Int) -> Int {
        return lround(Double(x) * Double(widthNow) / Double(widthTarget) * multiplier * tapMultiplier )
    }
    
    public func tapScaleY(y: Int) -> Int {
        return lround(Double(y) * Double(heightNow) / Double(heightTarget) * multiplier * tapMultiplier )
    }

}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = cgImage!.dataProvider!.data!
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        if cgImage!.bitsPerComponent == 16 {
            let pixelInfo: Int = ((Int(cgImage!.width) * Int(pos.y)) + Int(pos.x)) * 8

            var rValue: UInt32 = 0
            var gValue: UInt32 = 0
            var bValue: UInt32 = 0
            var aValue: UInt32 = 0

            NSData(bytes: [data[pixelInfo], data[pixelInfo+1]], length: 2).getBytes(&rValue, length: 2)
            NSData(bytes: [data[pixelInfo+2], data[pixelInfo+3]], length: 2).getBytes(&gValue, length: 2)
            NSData(bytes: [data[pixelInfo+4], data[pixelInfo+5]], length: 2).getBytes(&bValue, length: 2)
            NSData(bytes: [data[pixelInfo+6], data[pixelInfo+7]], length: 2).getBytes(&aValue, length: 2)
            
            let r = CGFloat(rValue) / CGFloat(65535.0)
            let g = CGFloat(gValue) / CGFloat(65535.0)
            let b = CGFloat(bValue) / CGFloat(65535.0)
            let a = CGFloat(aValue) / CGFloat(65535.0)
            
            return UIColor(red: r, green: g, blue: b, alpha: a)
        } else {
            let pixelInfo: Int = ((Int(cgImage!.width) * Int(pos.y)) + Int(pos.x)) * 4
            
            let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
            
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
        
    }
    
    func getPixelColor(pos: DeviceCoordinate) -> UIColor {
        return self.getPixelColor(pos: CGPoint(x: pos.x, y: pos.y))
    }
}

extension XCUIScreenshot {

    func rgbAtLocation(pos: (x: Int, y: Int)) -> (red: CGFloat, green: CGFloat, blue: CGFloat){
        let color = self.image.getPixelColor(pos: CGPoint(x: pos.x, y: pos.y))
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue)
    }

    func rgbAtLocation(pos: (x: Int, y: Int), min: (red: CGFloat, green: CGFloat, blue: CGFloat), max: (red: CGFloat, green: CGFloat, blue: CGFloat)) -> Bool {

        let color = self.rgbAtLocation(pos: pos)
        print(color)
        return  color.red >= min.red && color.red <= max.red &&
                color.green >= min.green && color.green <= max.green &&
                color.blue >= min.blue && color.blue <= max.blue
    }

    func rgbAtLocation(pos: DeviceCoordinate, min: (red: CGFloat, green: CGFloat, blue: CGFloat), max: (red: CGFloat, green: CGFloat, blue: CGFloat)) -> Bool {
        return self.rgbAtLocation(pos: pos.toXY(), min: min, max: max)
    }
}
