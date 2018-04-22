//
//  ViewController.swift
//  Boxscores
//
//  Created by blaine on 4/19/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import UIKit

class StandingsViewController: UITableViewController {
    @IBOutlet var filterButton: UIBarButtonItem!
    var scores: [BoxScore]!
    var teams: [TeamInfo]!
    var teamsByOpponentFilter: [TeamInfo]?
    let standingsOrganizer = StandingsOrganizer()
    var filter: Filter!
    var opponentName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(selectedOpponentFilter), name: .selectedOpponent, object: nil)
        filterButton.isEnabled = false
        setupData()
    }
    
    @objc private func selectedOpponentFilter(_ notification: NSNotification) {
        if let opponentDict = notification.userInfo as NSDictionary? {
            if let opponent = opponentDict["Opponent"] as? TeamInfo, let selectedFilter = opponentDict["Filter"] as? Filter {
                opponentName = opponent.teamName
                teamsByOpponentFilter = standingsOrganizer.filterByOpponent(filter: selectedFilter, opponentId: opponent.teamId, boxScore: scores)
                filter = selectedFilter
                tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == FILTER {
            guard let destinationVc = segue.destination as? FilterTableViewController else { return }
            destinationVc.delegate = self
            destinationVc.currentFilter = filter
            destinationVc.teams = teams
        }
    }

    private func setupData() {
        teams = []
        filter = .wins
        navigationController?.navigationItem.accessibilityLabel = "Standings Header"
        tableView.accessibilityIdentifier = "Standings Table"
        loadScores()
    }

    private func loadScores() {
        DispatchQueue.global(qos: .userInteractive).async {
            Networking.shared.getTeamsFrom(url: restAPI, completion: { (scoreData, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let scoreData = scoreData else { return }
                self.scores = scoreData
                self.teams = self.standingsOrganizer.displayStatsByFilter(boxscores: scoreData, filter: self.filter)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.filterButton.isEnabled = true
                }
            })
        }
    }
    
    @IBAction func filterTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: FILTER, sender: self)
    }
    
    //MARK: - UITableViewDatasource
    override func numberOfSections(in tableView: UITableView) -> Int {
        if teamsByOpponentFilter != nil {
            return 1
        } else if teams.count > 0 {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let opponentFilter = teamsByOpponentFilter {
            return opponentFilter.count
        } else {
            return teams.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TEAM_CELL) as? TeamCell else {
            return UITableViewCell()
        }
        if let opponentFilter = teamsByOpponentFilter {
            cell.configureCell(teamInfo: opponentFilter[indexPath.row])
        } else {
            cell.configureCell(teamInfo: teams[indexPath.row])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch filter {
        case .wins:
            return "Most Wins"
        case .goals:
            return "Most Goals"
        case .goalDifferential:
            return "Largest Goal Differential"
        case .standingsVsTeam:
            guard let opponent = opponentName else { return "" }
            return "League Standings vs \(opponent) - by wins"
        case .frequentOpponent:
            guard let opponent = opponentName else { return "" }
            return "Most Frequent Matchup with \(opponent)"
        default:
            return ""
        }
    }
}

extension StandingsViewController: FilterTableViewControllerDelegate {
    func filterSet(_ type: Filter) {
        filter = type
        teamsByOpponentFilter = nil
        teams = standingsOrganizer.sortTeamsBy(filter: filter, teamData: teams)
        tableView.reloadData()
    }
}
