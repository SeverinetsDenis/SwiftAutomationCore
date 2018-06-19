//
//  Constants.swift
//
//  Copyright © 2017 Oxagile. All rights reserved.
//

import Foundation
import UIKit
import XCTest

class Constants {
    
    public static let CountryCode = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String ?? "US"
    public static let LanguageCode = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as? String ?? "en"
    static var currentDevice: String {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "iPhone"
        case .pad:
            return "iPad"
        case .tv:
            return "Apple_TV"
        case .carPlay:
            return "Car_Play"
        default:
            return "Unknown_Device"
        }
    }
}

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

/* Helper for iOS */
struct DeviceHelper {
    /**
     Scroll by screen untill end of screen
     */
    @discardableResult
    static func scrollUpUntilEndOfScreen(timeout: TimeInterval = 30) -> Bool {
        let start = Date()
        var previousImage = Data()
        var currentImage = Container.app.screenshot().pngRepresentation
        while !(currentImage == previousImage) {
            previousImage = currentImage
            scrollUpByScreen()
            if Date() > (start + timeout) {
                print ("Didn't get end of screen within \(timeout) second")
                break
            }
            sleep(1)
            currentImage = Container.app.screenshot().pngRepresentation
        }
        return currentImage == previousImage
    }
    
    /**
     Scroll by screen up in percentage
     */
    static func scrollUpByScreen(percentageOfScreen : Int = 40) {
        let startPoint = XCUIApplication().coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: Double(percentageOfScreen) / 100))
        let finishPoint = XCUIApplication().coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0))
        startPoint.press(forDuration:0, thenDragTo: finishPoint)
    }
    
    /*
     Take a screenshot of an app's first window
    */
    static func takeScreenshot() -> XCUIScreenshot {
        return Container.app.windows.firstMatch.screenshot()
    }
    /*
    Bring app to background
     */
    static func bringAppToBackground() {
        sleep(1)
        Container.device.press(.home)
    }
    
    /*
     Bring app to foreground
     */
    static func bringAppToForeground() {
        sleep(1)
        Container.app.activate()    
    }
}

extension Set {
    public func randomObject() -> Element? {
        let n = Int(arc4random_uniform(UInt32(self.count)))
        let index = self.index(self.startIndex, offsetBy: n)
        return self.count > 0 ? self[index] : nil
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, bundle: Bundle.init(for: Constants.self), comment: "")
    }
}

extension XCUIElement {
    
    private func waitByCondition (condition: () -> Bool, timeout: TimeInterval) -> Bool {
        let start = Date()
        while (Date() < start + timeout) {
            if (condition()){
                return true
            } else {
                sleep(1)
            }
        }
        return false
    }
    
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    public func clearAndTypeText(_ text: String) -> Void {
        self.waitUntilEnabled(timeout: WaitFor.animation)
        self.tap()
        let stringValue = self.value as? String ?? ""
        let deleteString = Array<Character>(stringValue).map { _ in XCUIKeyboardKey.delete.rawValue }.joined(separator: "")
        self.typeText(deleteString)
        self.typeText(text)
        self.typeText(XCUIKeyboardKey.return.rawValue)
    }
    
    /*
     Waiting for element appears
     - Parameter timeout: time in seconds
     */
    @discardableResult
    public func waitUntilAppears(timeout: TimeInterval = 10) -> Bool {
        return waitByCondition(condition: {self.exists && self.isHittable}, timeout: timeout)
        //let predicate = NSPredicate(format: "isHittable == true")
        //let expect = XCTestCase().expectation(for: predicate, evaluatedWith: self)        
        //let expect = XCTKVOExpectation(keyPath: "isHittable", object: self, expectedValue: true)
    }
    
    public func waitUntilSelected(timeout: TimeInterval = 10) -> Bool {
        return waitByCondition(condition: {self.isSelected}, timeout: timeout)
    }
    
    @discardableResult
    public func waitUntilEnabled(timeout: TimeInterval = 5) -> Bool {
        return waitByCondition(condition: {self.isEnabled}, timeout: timeout)
    }
    
    public func waitUntilExists(timeout: TimeInterval = 10) -> Bool {
        return waitByCondition(condition: {self.exists}, timeout: timeout)
    }
        
    /**
     Waiting for label of element changed value
     Use this to make sure a video is downloaded
     - Parameter timeout: time in seconds
     */
    @discardableResult
    func waitUntilLabelIsChangedTo(expectedLabel: String, timeout: TimeInterval = 60) -> Bool {
        return waitByCondition(condition: {self.exists && self.label == expectedLabel}, timeout: timeout)
    }
    
    /**
     Waiting for element disppears
     - Parameter timeout: time in seconds
     */
    @discardableResult
    public func waitUntilDisappears(timeout: TimeInterval = 5) -> Bool {
        return waitByCondition(condition: {self.exists == false}, timeout: timeout)
    }
    
    /**
     Scroll untill the element is visible
     */
    @discardableResult
    func scrollToElement(timeout: TimeInterval = 30) -> XCUIElement {
        let start = Date()
        while !self.visible() {
            let startPoint = XCUIApplication().coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            let finishPoint = XCUIApplication().coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0))
            startPoint.press(forDuration:0, thenDragTo: finishPoint)
            if Date() > (start + timeout) {
                print("Impossible to find element within \(timeout) second")
                break
            }
        }
        return self
    }
    
    /**
     Check that element within a screen window
     */
    public func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
    
    /**
     Tap on the element using coordinates instead of standard tap() func
     */
    public func forceTap() {
        self.coordinate(withNormalizedOffset: CGVector(dx:0.0, dy:0.0)).tap()
    }
    
    /**
     Usefull for elements that not support isSelected property.
     Required to add accessibilityValue = "selected" for such elements.
     */
    public var isElementSelected: Bool {
        return "selected" == String(describing: self.value ?? "")
    }
    
    /**
     Checking whether a video inside element is running
     */
    func isVideoRunningInside() -> Bool {
        sleep(3)
        var result = false
        XCTContext.runActivity(named: "Checking video is running inside the element") { (activity) in
            var screenshots = [self.screenshot()]
            sleep(1)
            screenshots.append(self.screenshot())
            sleep(1)
            screenshots.append(self.screenshot())
            result = screenshots[0].pngRepresentation != screenshots[1].pngRepresentation &&
                screenshots[1].pngRepresentation != screenshots[2].pngRepresentation
        }
        return result
    }
   
}
