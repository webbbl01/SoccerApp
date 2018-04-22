//
//  StatisticsChecker.swift
//  SoccerAppUnitTests
//
//  Created by blaine on 4/21/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import Foundation
@testable import SoccerApp

class StatisticsChecker {
    
    enum MatchResult {
        case win,loss,tie
    }
    
    enum TeamLocation {
        case home,away
    }
    
    func isTeamStatsIncremented(originalStandings: [TeamInfo], newStandings: [TeamInfo], boxscore: BoxScore, winningTeamId: String?) -> Bool {
        let originalHomeTeamStats = checkForTeam(standings: originalStandings, teamId: boxscore.homeTeamId)
        let originalAwayTeamStats = checkForTeam(standings: originalStandings, teamId: boxscore.awayTeamId)
        let updatedHomeTeamStats = checkForTeam(standings: newStandings, teamId: boxscore.homeTeamId)
        let updatedAwayTeamStats = checkForTeam(standings: newStandings, teamId: boxscore.awayTeamId)
        if let winningTeamId = winningTeamId {
            if winningTeamId == originalHomeTeamStats.teamId {
                let didIncrementWin = incrementByResult(.win, originalStats: originalHomeTeamStats, updatedStats: updatedHomeTeamStats, boxscore: boxscore)
                let didIncrementLoss = incrementByResult(.loss, originalStats: originalAwayTeamStats, updatedStats: updatedAwayTeamStats, boxscore: boxscore)
                return didIncrementWin && didIncrementLoss
            } else {
                let didIncrementWin = incrementByResult(.win, originalStats: originalAwayTeamStats, updatedStats: updatedAwayTeamStats, boxscore: boxscore)
                let didIncrementLoss = incrementByResult(.loss, originalStats: originalHomeTeamStats, updatedStats: updatedHomeTeamStats, boxscore: boxscore)
                return didIncrementWin && didIncrementLoss
            }
        } else {
            //tie
            let didIncrementHomeTie = incrementByResult(.tie, originalStats: originalHomeTeamStats, updatedStats: updatedHomeTeamStats, boxscore: boxscore)
            let didIncrementAwayTie = incrementByResult(.tie, originalStats: originalAwayTeamStats, updatedStats: updatedAwayTeamStats, boxscore: boxscore)
            return didIncrementHomeTie && didIncrementAwayTie
        }
    }
    
    private func checkForTeam(standings: [TeamInfo], teamId: String) -> TeamInfo {
        if let team = standings.filter({ $0.teamId == teamId }).first {
            return team
        } else {
            let randomNumber = arc4random_uniform(100)
            return TeamInfo.init(teamId: teamId, teamName: "dummyTest\(randomNumber)")
        }
    }
    
    private func incrementByResult(_ result: MatchResult, originalStats: TeamInfo, updatedStats: TeamInfo, boxscore: BoxScore) -> Bool {
        switch result {
        case .win:
            return isIncrementedByWin(originalStats: originalStats, updatedStats: updatedStats, boxscore: boxscore)
        case .loss:
            return isIncrementedByLoss(originalStats: originalStats, updatedStats: updatedStats, boxscore: boxscore)
        case .tie:
            return isIncrementedByTie(originalStats: originalStats, updatedStats: updatedStats, boxscore: boxscore)
        }
    }
    
    private func isIncrementedByWin(originalStats: TeamInfo, updatedStats: TeamInfo, boxscore: BoxScore) -> Bool {
        let teamLocation = getTeamLocation(teamId: updatedStats.teamId, boxscore: boxscore)
        if originalStats.wins + 1 == updatedStats.wins && originalStats.losses == updatedStats.losses && originalStats.ties == updatedStats.ties {
            switch teamLocation {
            case .home:
                return checkHomeGoalStats(originalStats: originalStats, updatedStats: updatedStats, boxscore: boxscore)
            case .away:
                return checkAwayGoalStats(originalStats: originalStats, updatedStats: updatedStats, boxscore: boxscore)
            }
        } else {
            return false
        }
    }
    
    private func getTeamLocation(teamId: String, boxscore: BoxScore) -> TeamLocation {
        if boxscore.awayTeamId == teamId {
            return .away
        } else {
            return .home
        }
    }
    
    private func checkHomeGoalStats(originalStats: TeamInfo, updatedStats: TeamInfo, boxscore: BoxScore) -> Bool {
        if originalStats.goalsFor + boxscore.homeScore == updatedStats.goalsFor && originalStats.goalsAgainst + boxscore.awayScore == updatedStats.goalsAgainst && originalStats.goalDifferential + (boxscore.homeScore - boxscore.awayScore) == updatedStats.goalDifferential {
            return true
        } else {
            return false
        }
    }
    
    private func checkAwayGoalStats(originalStats: TeamInfo, updatedStats: TeamInfo, boxscore: BoxScore) -> Bool {
        if originalStats.goalsFor + boxscore.awayScore == updatedStats.goalsFor && originalStats.goalsAgainst + boxscore.homeScore == updatedStats.goalsAgainst && originalStats.goalDifferential + (boxscore.awayScore - boxscore.homeScore) == updatedStats.goalDifferential {
            return true
        } else {
            return false
        }
    }
    
    private func isIncrementedByLoss(originalStats: TeamInfo, updatedStats: TeamInfo, boxscore: BoxScore) -> Bool {
        let teamLocation = getTeamLocation(teamId: updatedStats.teamId, boxscore: boxscore)
        if originalStats.losses + 1 == updatedStats.losses && originalStats.wins == updatedStats.wins && originalStats.ties == updatedStats.ties {
            switch teamLocation {
            case .home:
                return checkHomeGoalStats(originalStats: originalStats, updatedStats: updatedStats, boxscore: boxscore)
            case .away:
                return checkAwayGoalStats(originalStats: originalStats, updatedStats: updatedStats, boxscore: boxscore)
            }
        } else {
            return false
        }
    }
    
    private func isIncrementedByTie(originalStats: TeamInfo, updatedStats: TeamInfo, boxscore: BoxScore) -> Bool {
        let teamLocation = getTeamLocation(teamId: updatedStats.teamId, boxscore: boxscore)
        if originalStats.wins  == updatedStats.wins && originalStats.losses == updatedStats.losses && originalStats.ties + 1 == updatedStats.ties {
            switch teamLocation {
            case .home:
                return checkHomeGoalStats(originalStats: originalStats, updatedStats: updatedStats, boxscore: boxscore)
            case .away:
                return checkAwayGoalStats(originalStats: originalStats, updatedStats: updatedStats, boxscore: boxscore)
            }
        } else {
            return false
        }
    }
}
