//
//  Standings.swift
//  SoccerStandingsApp
//
//  Created by blaine on 4/19/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import Foundation

class StandingsOrganizer {
    internal var standingsData: [TeamInfo]!
    
    init() {
        standingsData = []
    }
    
    func displayStatsByFilter(boxscores: [BoxScore], filter: Filter) -> [TeamInfo] {
        for score in boxscores {
            if let winner = evaluateWinner(boxScore: score) {
                addTeamStatsByResult(boxScore: score, winnerId: winner)
            } else {
                addTeamStatsByResult(boxScore: score, winnerId: nil)
            }
        }
        let filteredData = sortTeamsBy(filter: filter, teamData: standingsData)
        return filteredData
    }
    
    func sortTeamsBy(filter: Filter, teamData: [TeamInfo]) -> [TeamInfo] {
        switch filter {
        case .wins:
            return teamData.sorted(by: { $0.wins == $1.wins ? $0.losses < $1.losses : $0.wins > $1.wins })
        case .goals:
            return teamData.sorted(by: { $0.goalsFor > $1.goalsFor })
        case .goalDifferential:
            return teamData.sorted(by: { $0.goalDifferential == $1.goalDifferential ? $0.wins > $1.wins : $0.goalDifferential > $1.goalDifferential })
        default:
            return []
        }
    }
    
    func filterByOpponent(filter: Filter, opponentId: String, boxScore: [BoxScore]) -> [TeamInfo] {
        standingsData = []
        let filteredScores = boxScore.filter({ $0.awayTeamId == opponentId || $0.homeTeamId == opponentId })
        var updatedStandings: [TeamInfo] = []
        if filter == .standingsVsTeam {
            updatedStandings = displayStatsByFilter(boxscores: filteredScores, filter: .wins)
            return updatedStandings.filter({ $0.teamId != opponentId })
        } else if filter == .frequentOpponent {
            let opposingTeamIds = retrieveTeamIdsFromBoxscores(filteredScores, opponentId: opponentId)
            let mostMatchedTeamBoxscores = retrieveMostMatchedTeamBoxscores(filteredScores, opponentId: opponentId, opposingTeamIds: opposingTeamIds)
            updatedStandings = displayStatsByFilter(boxscores: mostMatchedTeamBoxscores, filter: .wins)
            return updatedStandings.filter({ $0.teamId != opponentId })
        } else {
            return []
        }
    }
    
    internal func retrieveTeamIdsFromBoxscores(_ boxscores: [BoxScore], opponentId: String) -> [String] {
        var teamIds: [String] = []
        for score in boxscores {
            if score.homeTeamId != opponentId {
                teamIds.append(score.homeTeamId)
            } else if score.awayTeamId != opponentId {
                teamIds.append(score.awayTeamId)
            }
        }
        return teamIds
    }
    
    internal func retrieveMostMatchedTeamBoxscores(_ boxscores: [BoxScore], opponentId: String, opposingTeamIds: [String]) -> [BoxScore] {
        var totals: [String: Int] = [:]
        opposingTeamIds.forEach({ totals[$0] = (totals[$0] ?? 0) + 1 })
        if let (teamId, _) = totals.max(by: { $0.1 < $1.1 }) {
            let mostMatchedTeamBoxscores = boxscores.filter({($0.awayTeamId == opponentId || $0.awayTeamId == teamId) && ($0.homeTeamId == opponentId || $0.homeTeamId == teamId) })
            return mostMatchedTeamBoxscores
        } else {
            return []
        }
    }
    
    internal func evaluateWinner(boxScore: BoxScore) -> String? {
        if boxScore.homeScore > boxScore.awayScore {
            return boxScore.homeTeamId
        } else if boxScore.homeScore < boxScore.awayScore {
            return boxScore.awayTeamId
        } else {
            //tie
            return nil
        }
    }
    
    internal func addTeamStatsByResult(boxScore: BoxScore, winnerId: String?) {
        let homeTeam: TeamInfo = getTeamEntry(teamId: boxScore.homeTeamId, teamName: boxScore.homeTeamName)
        let awayTeam: TeamInfo = getTeamEntry(teamId: boxScore.awayTeamId, teamName: boxScore.awayTeamName)
        if let winnerId = winnerId {
            if winnerId == homeTeam.teamId {
                homeTeam.addWin()
                awayTeam.addLoss()
            } else {
                awayTeam.addWin()
                homeTeam.addLoss()
            }
        } else {
            homeTeam.addTie()
            awayTeam.addTie()
        }
        homeTeam.addGoalsFor(boxScore.homeScore)
        homeTeam.addGoalsAgainst(boxScore.awayScore)
        awayTeam.addGoalsFor(boxScore.awayScore)
        awayTeam.addGoalsAgainst(boxScore.homeScore)
    }
    
    internal func getTeamEntry(teamId: String, teamName: String) -> TeamInfo {
        if let team = standingsData.first(where: { $0.teamId == teamId }) {
            return team
        } else {
            return createTeam(teamId: teamId, teamName: teamName)
        }
    }
    
    internal func createTeam(teamId: String, teamName: String) -> TeamInfo {
        let newTeam = TeamInfo.init(teamId: teamId, teamName: teamName)
        standingsData.append(newTeam)
        return newTeam
    }
}
