//
//  OpponentsTableViewController.swift
//  SoccerStandingsApp
//
//  Created by blaine on 4/20/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import UIKit

class OpponentsTableViewController: UITableViewController {
    var teams: [TeamInfo]!
    var filter: Filter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortTeamsAlphabetically()
    }
    
    private func sortTeamsAlphabetically() {
        teams.sort(by: { $0.teamName < $1.teamName })
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if teams.count > 0 {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OPPONENTS_CELL, for: indexPath)
        cell.textLabel?.text = teams[indexPath.row].teamName
        return cell
    }
    
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOpponent = ["Opponent": teams[indexPath.row], "Filter": filter] as [String : Any]
        NotificationCenter.default.post(name: .selectedOpponent, object: nil, userInfo: selectedOpponent)
        self.navigationController?.popToRootViewController(animated: true)
    }
}
