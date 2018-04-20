//
//  Standings.swift
//  SoccerStandingsApp
//
//  Created by blaine on 4/19/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import Foundation

class StandingsOrganizer {
    private var standingsData: [TeamInfo]!
    
    init() {
        standingsData = []
    }
    
    func displayStatsByFilter(boxscores: [BoxScore], filter: Filter, completion: @escaping([TeamInfo]) -> Void) {
        for score in boxscores {
            if let winner = evaluateWinner(boxScore: score) {
                addTeamStatsByResult(boxScore: score, winnerId: winner)
            } else {
                addTeamStatsByResult(boxScore: score, winnerId: nil)
            }
        }
        let filteredData = sortTeamsBy(filter: filter, teamData: standingsData)
        completion(filteredData)
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
            displayStatsByFilter(boxscores: filteredScores, filter: .wins, completion: { (standingsVsOpponent) in
                updatedStandings = standingsVsOpponent.filter({ $0.teamId != opponentId })
            })
            return updatedStandings
        } else if filter == .frequentOpponent {
            let homeIds = filteredScores.map({ $0.homeTeamId })
            let awayIds = filteredScores.map({ $0.awayTeamId })
            var totals: [String: Int] = [:]
            homeIds.forEach({ totals[$0] = (totals[$0] ?? 0) + 1 })
            awayIds.forEach({ totals[$0] = (totals[$0] ?? 0) + 1 })
            totals.removeValue(forKey: opponentId)
            var mostMatchedTeam: String?
            if let (teamId, _) = totals.max(by: { $0.1 < $1.1 }) {
                mostMatchedTeam = teamId
            }
            if let team = mostMatchedTeam {
                let relatedBoxScores = boxScore.filter({($0.awayTeamId == opponentId || $0.awayTeamId == team) && ($0.homeTeamId == opponentId || $0.homeTeamId == team) })
                displayStatsByFilter(boxscores: relatedBoxScores, filter: .wins, completion: { (frequentOpponent) in
                    updatedStandings = frequentOpponent.filter({ $0.teamId != opponentId })
                })
                return updatedStandings
            } else {
                return []
            }
        } else {
            return []
        }
    }
    
    private func evaluateWinner(boxScore: BoxScore) -> String? {
        if boxScore.homeScore < boxScore.awayScore {
            return boxScore.awayTeamId
        } else if boxScore.homeScore == boxScore.awayScore {
            return nil
        } else {
            return boxScore.homeTeamId
        }
    }
    
    private func addTeamStatsByResult(boxScore: BoxScore, winnerId: String?) {
        let homeTeam: TeamInfo = {
            if let existingHomeTeam = getExistingTeamEntry(teamId: boxScore.homeTeamId) {
                return existingHomeTeam
            } else {
                let newHomeTeam = createTeam(teamId: boxScore.homeTeamId, teamName: boxScore.homeTeamName)
                standingsData.append(newHomeTeam)
                return newHomeTeam
            }
        }()
        let awayTeam: TeamInfo = {
            if let existingAwayTeam = getExistingTeamEntry(teamId: boxScore.awayTeamId) {
                return existingAwayTeam
            } else {
                let newAwayTeam = createTeam(teamId: boxScore.awayTeamId, teamName: boxScore.awayTeamName)
                standingsData.append(newAwayTeam)
                return newAwayTeam
            }
        }()
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
    
    private func getExistingTeamEntry(teamId: String) -> TeamInfo? {
        if let team = standingsData.filter({ $0.teamId == teamId }).first {
            return team
        } else {
            return nil
        }
    }
    
    private func createTeam(teamId: String, teamName: String) -> TeamInfo {
        let newTeam = TeamInfo.init(teamId: teamId, teamName: teamName)
        return newTeam
    }
    
}
