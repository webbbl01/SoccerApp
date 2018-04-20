//
//  TeamCell.swift
//  Boxscores
//
//  Created by blaine on 4/19/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import UIKit

class TeamCell: UITableViewCell {

    @IBOutlet var teamId: UILabel!
    @IBOutlet var teamName: UILabel!
    @IBOutlet var wins: UILabel!
    @IBOutlet var losses: UILabel!
    @IBOutlet var ties: UILabel!
    @IBOutlet var winPercent: UILabel!
    @IBOutlet var goalsFor: UILabel!
    @IBOutlet var goalsAgainst: UILabel!
    @IBOutlet var goalDifferential: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(teamInfo: TeamInfo) {
        teamId.text =  teamInfo.teamId
        teamName.text = teamInfo.teamName
        wins.text = "\(Int(teamInfo.wins))"
        losses.text = "\(Int(teamInfo.losses))"
        ties.text = "\(Int(teamInfo.ties))"
        goalsFor.text = "\(Int(teamInfo.goalsFor))"
        goalsAgainst.text = "\(Int(teamInfo.goalsAgainst))"
        goalDifferential.text = "\(Int(teamInfo.goalDifferential))"
        
        let winPercentage = calculateWinPercentage(wins: teamInfo.wins, losses: teamInfo.losses, ties: teamInfo.ties)
        winPercent.text = "\(winPercentage)%"
        
    }
    
    private func calculateWinPercentage(wins: Double, losses: Double, ties: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 3
        let total = wins + losses + ties
        guard let winPercentage = numberFormatter.string(from: (wins/total) * 100 as NSNumber) else {
            return ""
        }
        return winPercentage
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
