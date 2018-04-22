//
//  FilterTableViewController.swift
//  SoccerStandingsApp
//
//  Created by blaine on 4/19/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import UIKit

protocol FilterTableViewControllerDelegate: class {
    func filterSet(_ type: Filter)
}

class FilterTableViewController: UITableViewController {
    @IBOutlet var standingsVsOpponent: UITextField!
    @IBOutlet var mostFrequentOpponent: UITextField!
    var currentFilter: Filter!
    var teams: [TeamInfo]!
    weak var delegate: FilterTableViewControllerDelegate?
    private var teamNames: [String]! = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSelectedFilter(currentFilter)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    private func setSelectedFilter(_ filter: Filter) {
        var indexPath: IndexPath? = nil
        switch filter {
        case .wins:
            indexPath = IndexPath(row: 0, section: 0)
        case .goals:
            indexPath = IndexPath(row: 1, section: 0)
        case .goalDifferential:
            indexPath = IndexPath(row: 2, section: 0)
        case .standingsVsTeam,.frequentOpponent:
            indexPath = nil
        }
        setCheckmark(indexPath: indexPath)
    }
    
    private func setCheckmark(indexPath: IndexPath?) {
        guard let index = indexPath else { return }
        guard let cell = tableView.cellForRow(at: index) else { return }
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        cell.accessoryType = .checkmark
        deselectRemainingCells(selectedIndex: index)
    }
    
    private func setupData() {
        tableView.accessibilityIdentifier = "Filter"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == OPPONENTS {
            guard let destinationVC = segue.destination as? OpponentsTableViewController else { return }
            destinationVC.teams = teams
            destinationVC.filter = currentFilter
        }
    }
    
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        switch indexPath.section {
        case 0:
            toggleCells(cell, indexPath: indexPath)
            switch indexPath.row {
            case 0:
                delegate?.filterSet(.wins)
            case 1:
                delegate?.filterSet(.goals)
            case 2:
                delegate?.filterSet(.goalDifferential)
            default:
                return
            }
            navigationController?.popViewController(animated: true)
        case 1:
            switch indexPath.row {
            case 0:
                currentFilter = .standingsVsTeam
            case 1:
                currentFilter = .frequentOpponent
            default:
                return
            }
            performSegue(withIdentifier: OPPONENTS, sender: self)
        default:
            return
        }
    }
    
    
    private func toggleCells(_ cell: UITableViewCell, indexPath: IndexPath) {
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
        }
        deselectRemainingCells(selectedIndex: indexPath)
    }
    
    private func deselectRemainingCells(selectedIndex: IndexPath) {
        let rows = tableView.numberOfRows(inSection: selectedIndex.section)
        for row in 0...rows - 1 where row != selectedIndex.row {
            let indexToDeslect = IndexPath(row: row, section: selectedIndex.section)
            let cell = tableView.cellForRow(at: indexToDeslect)
            tableView.deselectRow(at: indexToDeslect, animated: true)
            cell?.accessoryType = .none
        }
    }
}
