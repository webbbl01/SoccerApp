//
//  Constants.swift
//  Standings
//
//  Created by blaine on 4/19/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import Foundation


let restAPI = "http://l.yimg.com/cv/ae/default/171221/soccer_game_results.json"

//Reuse Identifiers
let TEAM_CELL = "teamCell"
let OPPONENTS_CELL = "opponentsCell"

//Segues
let FILTER = "filterSegue"
let OPPONENTS = "opponentsSegue"

//Enums
enum Filter: String {
    case wins, goals, goalDifferential, standingsVsTeam, frequentOpponent
}

