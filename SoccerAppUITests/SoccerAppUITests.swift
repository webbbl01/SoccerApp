//
//  SoccerAppUITests.swift
//  SoccerAppUITests
//
//  Created by blaine on 4/21/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import XCTest
@testable import SoccerApp

class SoccerAppUITests: XCTestCase {
    var app: SoccerAppFlow!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = SoccerAppFlow()
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMostGoalsFilter() {
        app.selectFilter(.goalDifferential)
        let mostGoalsSectionHeader = app.otherElements[Filter.goalDifferential.rawValue]
        XCTAssert(mostGoalsSectionHeader.exists, "Most Goals section header did not display as expected")
    }
    
    func testMostWinsFilter() {
        app.selectFilter(.wins)
        let mostWinsSectionHeader = app.otherElements[Filter.wins.rawValue]
        XCTAssert(mostWinsSectionHeader.exists, "Most Wins section header did not display as expected")
    }
    
    func testLargestGDFilter() {
        app.selectFilter(.goalDifferential)
        let largestGDSectionHeader = app.otherElements[Filter.goalDifferential.rawValue]
        XCTAssert(largestGDSectionHeader.exists, "Largest GD section header did not display as expected")
    }
    
    func testLoadingOpponents() {
        app.selectFilter(.standingsVsTeam)
        let selectOpponentsTable = app.tables.matching(identifier: "Opponents").firstMatch
        XCTAssert(selectOpponentsTable.exists, "The Select Opponents view did not load.")
        XCTAssertTrue(selectOpponentsTable.cells.count > 0, "The Select Opponents table did not load any data.")
    }
    
    func testSelectStandingsVsTeamOpponentFilter() {
        let selectedOpponent = app.selectOpponentByFilter(.standingsVsTeam, teamAtRow: 1)
        let selectedOpponentHeaderText = "League Standings vs \(selectedOpponent) - by wins"
        let standingsVsTeamHeader = app.otherElements[selectedOpponentHeaderText]
        XCTAssert(standingsVsTeamHeader.exists, "The Standings Vs Opponent view did not load as expected.")
    }
    
    func testMostFrequentMatchupFilter() {
        let selectedOpponent = app.selectOpponentByFilter(.frequentOpponent, teamAtRow: 5)
        let selectedOpponentHeaderText = "Most Frequent Matchup with \(selectedOpponent)"
        let frequentMatchupHeader = app.otherElements[selectedOpponentHeaderText]
        XCTAssert(frequentMatchupHeader.exists, "The Frequent Opponent view did not load as expected.")
    }
    
}
