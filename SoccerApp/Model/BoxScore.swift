//
//  Boxscore.swift
//  Boxscores
//
//  Created by blaine on 4/19/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import Foundation

struct BoxScore: Decodable {
    let gameId: String
    let awayTeamId: String
    let awayTeamName: String
    let awayScore: Int
    let homeTeamId: String
    let homeTeamName: String
    let homeScore: Int
}

