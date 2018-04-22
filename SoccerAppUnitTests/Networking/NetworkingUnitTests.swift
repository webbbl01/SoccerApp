//
//  NetworkingUnitTests.swift
//  SoccerAppUnitTests
//
//  Created by blaine on 4/21/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import XCTest
@testable import SoccerApp

class NetworkingUnitTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSuccessfulNetworkingLoadData() {
        var boxscoreData: [BoxScore]? = nil
        let exp = expectation(description: "Waiting for sessionData to be loaded.")
        
        Networking.shared.getTeamsFrom(url: restAPI) { (boxscores, error) in
            XCTAssertNil(error, "Error returned when loading the data while attempting to populate the standings view.")
            XCTAssertNotNil(boxscores, "No data was received from the server to populate the standings view.")
            boxscoreData = boxscores
            exp.fulfill()
        }
        let result = XCTWaiter().wait(for: [exp], timeout: 5.0)
        if result == XCTWaiter.Result.completed {
            XCTAssertNotNil(boxscoreData)
        } else {
            XCTFail("The call to the URL timed out or ran into errors.")
        }
    }
    
    func testBadURLNetworkingLoadData() {
        var sessionError: Error? = nil
        let exp = expectation(description: "Waiting for sessionData to be loaded.")
        let badUrl: String = ""
        
        Networking.shared.getTeamsFrom(url: badUrl) { (boxscores, error) in
            XCTAssertNotNil(error, "No error returned when testing a bad url.")
            XCTAssertNil(boxscores, "Data returned, but should not have with a bad url.")
            sessionError = error
            exp.fulfill()
        }
        
        let result = XCTWaiter().wait(for: [exp], timeout: 5.0)
        if result == XCTWaiter.Result.completed {
            XCTAssertNotNil(sessionError)
        } else {
            XCTFail("The call to the URL timed out or ran into errors.")
        }
    }
}
