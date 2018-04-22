//
//  Standings.swift
//  SoccerStandingsApp
//
//  Created by blaine on 4/19/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import Foundation

class TeamInfo {
    private var _teamId: String
    private var _teamName: String
    private var _wins: Double
    private var _losses: Double
    private var _ties: Double
    private var _goalsFor: Int
    private var _goalsAgainst: Int
    private var _goalDifferential: Int
    
    var teamId: String {
        return _teamId
    }
    
    var teamName: String {
        return _teamName
    }
    
    var wins: Double {
        return _wins
    }
    
    var losses: Double {
        return _losses
    }
    
    var ties: Double {
        return _ties
    }
    
    var goalsFor: Int {
        return _goalsFor
    }
    
    var goalsAgainst: Int {
        return _goalsAgainst
    }
    
    var goalDifferential: Int {
        return _goalDifferential
    }
    
    init(teamId: String, teamName: String) {
        _teamId = teamId
        _teamName = teamName
        _wins = 0
        _losses = 0
        _ties = 0
        _goalsFor = 0
        _goalsAgainst = 0
        _goalDifferential = 0
    }
    
    init(teamId: String, teamName: String, wins: Double, losses: Double, ties: Double, goalsFor: Int, goalsAgainst: Int, goalDifferential: Int) {
        _teamId = teamId
        _teamName = teamName
        _wins = wins
        _losses = losses
        _ties = ties
        _goalsFor = goalsFor
        _goalsAgainst = goalsAgainst
        _goalDifferential = goalDifferential
    }
    
    func addWin() {
        _wins += 1
    }
    
    func addLoss() {
        _losses += 1
    }
    
    func addTie() {
        _ties += 1
    }
    
    func addGoalsFor(_ goalsFor: Int) {
        _goalsFor += goalsFor
    }
    
    func addGoalsAgainst(_ goalsAgainst: Int) {
        _goalsAgainst += goalsAgainst
        updateGoalDifferential()
    }
    
    private func updateGoalDifferential() {
        _goalDifferential = _goalsFor - _goalsAgainst
    }
}
