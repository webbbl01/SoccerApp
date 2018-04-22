//
//  MockBoxscores.swift
//  SoccerAppUnitTests
//
//  Created by blaine on 4/21/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import Foundation
@testable import SoccerApp

class BoxscoresData  {
    private var gameId: Int = 0
    enum WinningTeam {
        case home,away,tie
    }
    
    func generateBoxscoreByResult(_ winFor: WinningTeam) -> BoxScore {
        gameId += 1
        switch winFor {
        case .home:
            return BoxScore.init(gameId: "\(gameId)", awayTeamId: "1", awayTeamName: "Team1", awayScore: 2, homeTeamId: "2", homeTeamName: "Team2", homeScore: 3)
        case .away:
            return BoxScore.init(gameId: "\(gameId)", awayTeamId: "3", awayTeamName: "Team3", awayScore: 3, homeTeamId: "4", homeTeamName: "Team4", homeScore: 2)
        case .tie:
            return BoxScore.init(gameId: "\(gameId)", awayTeamId: "5", awayTeamName: "Team5", awayScore: 2, homeTeamId: "6", homeTeamName: "Team6", homeScore: 2)
        }
    }
    
    func generateBoxscoreByTeamIds(homeTeamId: String, awayTeamId: String, winFor: WinningTeam) -> BoxScore {
        gameId += 1
        switch winFor {
        case .home:
            return BoxScore.init(gameId: "\(gameId)", awayTeamId: awayTeamId, awayTeamName: "Team\(awayTeamId)", awayScore: 1, homeTeamId: homeTeamId, homeTeamName: "Team\(homeTeamId)", homeScore: 2)
        case .away:
            return BoxScore.init(gameId: "\(gameId)", awayTeamId: awayTeamId, awayTeamName: "Team\(awayTeamId)", awayScore: 2, homeTeamId: homeTeamId, homeTeamName: "Team\(homeTeamId)", homeScore: 1)
        case .tie:
            return BoxScore.init(gameId: "\(gameId)", awayTeamId: awayTeamId, awayTeamName: "Team\(awayTeamId)", awayScore: 2, homeTeamId: homeTeamId, homeTeamName: "Team\(homeTeamId)", homeScore: 2)
        }
    }
}
