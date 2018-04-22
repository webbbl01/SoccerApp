//
//  SoccerAppFlow.swift
//  SoccerAppUITests
//
//  Created by blaine on 4/22/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import Foundation
import XCTest

enum Filter: String {
    case wins = "Most Wins"
    case goals = "Most Goals"
    case goalDifferential = "Largest Goal Differential"
    case standingsVsTeam = "League Standings Vs Selected Opponent"
    case frequentOpponent = "Most Frequent Matchup Vs Opponent"
}

class SoccerAppFlow: XCUIApplication {
    func selectFilter(_ filter: Filter) {
        let filterButton = self.navigationBars["Standings"].buttons["Filter"]
        let filterTable = self.tables["Filter"]
        filterButton.tap()
        filterTable.staticTexts[filter.rawValue].tap()
    }
    
    func selectOpponentByFilter(_ filter: Filter, teamAtRow: Int) -> String {
        selectFilter(filter)
        let opponentsTable = self.tables.matching(identifier: "Opponents").firstMatch
        let selectedOpponent = opponentsTable.cells.element(boundBy: teamAtRow)
        let opponentName = selectedOpponent.descendants(matching: .any).matching(identifier: "TeamName").firstMatch.label
        selectedOpponent.tap()
        return opponentName
    }
}
