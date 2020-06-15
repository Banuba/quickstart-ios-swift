//
//  quickstart_ios_swiftUITests.swift
//  quickstart-ios-swiftUITests
//
//  Created by Andrey Krivoshey on 4/8/20.
//  Copyright © 2020 Ivan Gulidov. All rights reserved.
//

import XCTest

class quickstart_ios_swiftUITests: UITestBase {

    func testEffect() {
        app/*@START_MENU_TOKEN@*/.staticTexts[" Camera "]/*[[".buttons[\" Camera \"].staticTexts[\" Camera \"]",".staticTexts[\" Camera \"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        tapCoordinate(at: 100, and: 100)
        // Wait till animation in effect to load
        sleep(2)
        takeScreenshot(name: "Effect 1")
        tapCoordinate(at: 100, and: 100)
        sleep(2)
        takeScreenshot(name: "Effect 2")
        tapCoordinate(at: 100, and: 100)
        sleep(2)
        takeScreenshot(name: "Effect 3")
    }
    
    func testPhotos() {
        app.buttons["Photos"].tap()
        
//        sleep(2)
        XCTAssertTrue(app.otherElements.tables.cells["UItest"].waitForExistence(timeout: 5))
        app.otherElements.tables.cells["UItest"].tap()
        
        let photoCells = app.collectionViews.cells
        photoCells.allElementsBoundByIndex.first!.firstMatch.waitForExistence(timeout: 5)
        photoCells.allElementsBoundByIndex.first!.firstMatch.tap()
        // app.buttons["Cancel"].tap() // If we want to skip image selection
        // ToDo: Change sleep() to wait for processing to finish
        sleep(2)
        takeScreenshot(name: "Processed photo")
        app.navigationBars["Photos"].buttons["Stop"].tap()
    }
    
    func testVideos() {
        app.buttons["Video"].tap()
        app.buttons["Cancel"].tap()
        app.buttons["Open video"].tap()
        
        XCTAssertTrue(app.otherElements.tables.cells["UItest"].waitForExistence(timeout: 5))
        app.otherElements.tables.cells["UItest"].tap()
        
        let videoCells = app.collectionViews.cells
        videoCells.allElementsBoundByIndex.first!.firstMatch.waitForExistence(timeout: 5)
        videoCells.allElementsBoundByIndex.first!.firstMatch.tap()
        
        app.buttons["Choose"].waitForExistence(timeout: 5)
        app.buttons["Choose"].tap()
        
        // ToDo: Change sleep() to wait for processing to finish
        sleep(25)
        takeScreenshot(name: "Processed video")
        app.navigationBars["Video"].buttons["Stop"].tap()
    }

}
