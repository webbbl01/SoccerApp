//
//  SoccerAppUnitTests.swift
//  SoccerAppUnitTests
//
//  Created by blaine on 4/21/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import XCTest
@testable import SoccerApp

class StandingsOrganizerUnitTests: XCTestCase {
    let organizer = StandingsOrganizer()
    let boxscoresData = BoxscoresData()
    let statsChecker = StatisticsChecker()
    var homeWinnerBoxScore, awayWinnerBoxScore, tieBoxScore: BoxScore!
    var basicScores: [BoxScore]!
    
    override func setUp() {
        super.setUp()
        homeWinnerBoxScore = boxscoresData.generateBoxscoreByResult(.home)
        awayWinnerBoxScore = boxscoresData.generateBoxscoreByResult(.away)
        tieBoxScore = boxscoresData.generateBoxscoreByResult(.tie)
        basicScores = [homeWinnerBoxScore,awayWinnerBoxScore,tieBoxScore]
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testHomeTeamWinnerEvaluation() {
        if let homeTeam = organizer.evaluateWinner(boxScore: homeWinnerBoxScore) {
            XCTAssert(homeTeam == homeWinnerBoxScore.homeTeamId, "Incorrect winner displayed")
        } else {
            XCTFail("Result returned is a tie.")
        }
    }
    
    func testAwayTeamWinnerEvaluation() {
        if let awayTeam = organizer.evaluateWinner(boxScore: awayWinnerBoxScore) {
            XCTAssert(awayTeam == awayWinnerBoxScore.awayTeamId, "Incorrect winner displayed")
        } else {
            XCTFail("Result returned is a tie.")
        }
    }
    
    func testTieEvaluation() {
        if let _ = organizer.evaluateWinner(boxScore: tieBoxScore) {
            XCTFail("Result returned is a winner.")
        } else {
            XCTAssert(true)
        }
    }
    
    func testGetExistingTeamEntry() {
        let team = TeamInfo.init(teamId: "1", teamName: "Team1")
        organizer.standingsData.append(team)
        let existingTeam = organizer.getTeamEntry(teamId: "1", teamName: "Team1")
        XCTAssertTrue(existingTeam.teamId == "1", "Existing team retrieved does not match.")
    }
    
    func testGetNewTeamEntry() {
        let newTeam = organizer.getTeamEntry(teamId: "7", teamName: "Team7")
        let standingsWithNewTeam = organizer.standingsData.filter({ $0.teamId == newTeam.teamId })
        XCTAssertTrue(standingsWithNewTeam.count == 1, "Newly requested team does not exist.")
    }
    
    func testAddHomeWinResultStats() {
        if let originalStandings = organizer.standingsData {
            organizer.addTeamStatsByResult(boxScore: homeWinnerBoxScore, winnerId: homeWinnerBoxScore.homeTeamId)
            let result = statsChecker.isTeamStatsIncremented(originalStandings: originalStandings, newStandings: organizer.standingsData, boxscore: homeWinnerBoxScore, winningTeamId: homeWinnerBoxScore.homeTeamId)
            XCTAssertTrue(result, "Teams statistics were not incremented correctly for a home win")
        }
    }
    
    func testAddAwayWinResultStats() {
        organizer.standingsData = []
        if let originalStandings = organizer.standingsData {
            organizer.addTeamStatsByResult(boxScore: awayWinnerBoxScore, winnerId: awayWinnerBoxScore.awayTeamId)
            let result = statsChecker.isTeamStatsIncremented(originalStandings: originalStandings, newStandings: organizer.standingsData, boxscore: awayWinnerBoxScore, winningTeamId: awayWinnerBoxScore.awayTeamId)
            XCTAssertTrue(result, "Teams statistics were not incremented correctly for a home win")
        }
    }
    
    func testAddTieResultStats() {
        if let originalStandings = organizer.standingsData {
            organizer.addTeamStatsByResult(boxScore: tieBoxScore, winnerId: nil)
            let result = statsChecker.isTeamStatsIncremented(originalStandings: originalStandings, newStandings: organizer.standingsData, boxscore: tieBoxScore, winningTeamId: nil)
            XCTAssertTrue(result, "Team statistics were not incremented correctly for a home win")
        }
    }
    
    func testSortTeamStandingsByWins() {
        basicScores.append(boxscoresData.generateBoxscoreByResult(.home))
        let sortedByWins = organizer.displayStatsByFilter(boxscores: basicScores, filter: .wins)
        var previousWinTotal: Double = 1000
        var previousLossTotal: Double = -1000
        for team in sortedByWins {
            if team.wins < previousWinTotal {
                previousWinTotal = team.wins
                previousLossTotal = team.losses
            } else if team.wins == previousWinTotal && team.losses >= previousLossTotal {
                previousLossTotal = team.losses
            } else {
                XCTFail("Teams are not sorted correctly for order by wins.")
            }
        }
        XCTAssert(true)
    }
    
    func testSortTeamsByGoals() {
        let sortedByGoals = organizer.displayStatsByFilter(boxscores: basicScores, filter: .goals)
        var previousGoalTotal: Int = 1000
        for team in sortedByGoals {
            if team.goalsFor <= previousGoalTotal {
                previousGoalTotal = team.goalsFor
            } else {
                XCTFail("Teams are not sorted correctly for order by goals.")
            }
        }
        XCTAssert(true)
    }
    
    func testSortTeamsByGD() {
        let sortedByGD = organizer.displayStatsByFilter(boxscores: basicScores, filter: .goalDifferential)
        var previousGDTotal: Int = 1000
        var previousWinTotal: Double = 1000
        for team in sortedByGD {
            if team.goalDifferential < previousGDTotal {
                previousGDTotal = team.goalDifferential
            } else if team.goalDifferential == previousGDTotal && team.wins <= previousWinTotal {
                previousWinTotal = team.wins
            } else {
                XCTFail("Teams are not sorted correctly for order by Goal Differential")
            }
        }
        XCTAssert(true)
    }
    
    func testFilterByOpponentStandingsVsTeam() {
        populateRelevantScores()
        let expectedResults = populateSortedVsExpectation()
        let standingsSortedVsOpp = organizer.filterByOpponent(filter: .standingsVsTeam, opponentId: "1", boxScore: basicScores)
        
        for (i,team) in standingsSortedVsOpp.enumerated() {
            XCTAssertEqual(team.teamId, expectedResults[i].teamId, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.teamName, expectedResults[i].teamName, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.wins, expectedResults[i].wins, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.losses, expectedResults[i].losses, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.ties, expectedResults[i].ties, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.goalsFor, expectedResults[i].goalsFor, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.goalsAgainst, expectedResults[i].goalsAgainst, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.goalDifferential, expectedResults[i].goalDifferential, "Filter by Opponents - Standings vs Team, did not return the expected data.")
        }
    }
    
    func testFilterByMostFrequentOpponent() {
        populateRelevantScores()
        let expectedResults = populateMostFrequentExpectation()
        let mostFrequentOpponent = organizer.filterByOpponent(filter: .frequentOpponent, opponentId: "1", boxScore: basicScores)
        for (i,team) in mostFrequentOpponent.enumerated() {
            XCTAssertEqual(team.teamId, expectedResults[i].teamId, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.teamName, expectedResults[i].teamName, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.wins, expectedResults[i].wins, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.losses, expectedResults[i].losses, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.ties, expectedResults[i].ties, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.goalsFor, expectedResults[i].goalsFor, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.goalsAgainst, expectedResults[i].goalsAgainst, "Filter by Opponents - Standings vs Team, did not return the expected data.")
            XCTAssertEqual(team.goalDifferential, expectedResults[i].goalDifferential, "Filter by Opponents - Standings vs Team, did not return the expected data.")
        }
    }
    
    private func populateRelevantScores() {
        let team1Winner = boxscoresData.generateBoxscoreByTeamIds(homeTeamId: "1", awayTeamId: "5", winFor: .home)
        let team1Loser = boxscoresData.generateBoxscoreByTeamIds(homeTeamId: "1", awayTeamId: "4", winFor: .away)
        let team1Winner2 = boxscoresData.generateBoxscoreByTeamIds(homeTeamId: "1", awayTeamId: "2", winFor: .home)
        basicScores.append(team1Winner)
        basicScores.append(team1Loser)
        basicScores.append(team1Winner2)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    private func populateSortedVsExpectation() -> [TeamInfo] {
        let team4 = TeamInfo.init(teamId: "4", teamName: "Team4", wins: 1, losses: 0, ties: 0, goalsFor: 2, goalsAgainst: 1, goalDifferential: 1)
        let team2 = TeamInfo.init(teamId: "2", teamName: "Team2", wins: 1, losses: 1, ties: 0, goalsFor: 4, goalsAgainst: 4, goalDifferential: 0)
        let team5 = TeamInfo.init(teamId: "5", teamName: "Team5", wins: 0, losses: 1, ties: 0, goalsFor: 1, goalsAgainst: 2, goalDifferential: -1)
        
        return [team4,team2,team5]
    }
    
    private func populateMostFrequentExpectation() -> [TeamInfo] {
        let team2 = TeamInfo.init(teamId: "2", teamName: "Team2", wins: 1, losses: 1, ties: 0, goalsFor: 4, goalsAgainst: 4, goalDifferential: 0)
        return [team2]
    }
}
