//
//  DiningViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

class DiningViewController: GenericTableViewController {
    
    fileprivate var viewModel = DiningViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        
        self.title = "Dining"
        self.screenName = "Dining"
        
        viewModel.registerHeadersAndCells(for: tableView)
        
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDiningHours()
    }
}

//Mark: Networking to retrieve today's times
extension DiningViewController {
    fileprivate func fetchDiningHours() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DiningAPI.instance.fetchDiningHours { (success) in
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

// MARK: - DiningViewModelDelegate
extension DiningViewController: DiningViewModelDelegate {
    func handleSelection(for venue: DiningVenue) {
        let ddc = DiningDetailViewController()
        ddc.venue = venue
        navigationController?.pushViewController(ddc, animated: true)
        DatabaseManager.shared.trackEvent(vcName: "Dining", event: ddc.venue.name)
    }
}

