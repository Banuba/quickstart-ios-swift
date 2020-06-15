//
//  quickstart_ios_swiftUITestsBase.swift
//  quickstart-ios-swiftUITests
//
//  Created by Andrey Krivoshey on 4/8/20.
//  Copyright © 2020 Ivan Gulidov. All rights reserved.
//

import Foundation
import XCTest

class UITestBase: XCTestCase {
    var app: XCUIApplication!
        
    let defaultLaunchArgs: [[String]] = {
        let launchArgs: [[String]] = [["-StartFromCleanState", "YES"]]
        return launchArgs
    }()
    
    func launchApp(with launchArgs: [[String]] = []) {
        (defaultLaunchArgs + launchArgs).forEach { app.launchArguments += $0 }
        app.launch()
    }

    override func setUp() {
        app = XCUIApplication()
        super.setUp()
        continueAfterFailure = false
        launchApp(with: defaultLaunchArgs)
    }

    override func tearDown() {
        app.terminate()
        super.tearDown()
    }
    
    func takeScreenshot(name: String) {
      let fullScreenshot = XCUIScreen.main.screenshot()

      let screenshot = XCTAttachment(uniformTypeIdentifier: "public.png", name: "Screenshot-\(name)-\(UIDevice.current.name).png", payload: fullScreenshot.pngRepresentation, userInfo: nil)
      screenshot.lifetime = .keepAlways
      add(screenshot)
    }
    
    func tapCoordinate(at xCoordinate: Double, and yCoordinate: Double) {
        let normalized = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let coordinate = normalized.withOffset(CGVector(dx: xCoordinate, dy: yCoordinate))
        coordinate.tap()
    }
}
