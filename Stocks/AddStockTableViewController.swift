//
//  AddStockTableViewController.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 13..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import UIKit

class AddStockTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
	// MARK: - Properties
	var showCancel = true
	
	@IBOutlet weak var tableView: UITableView!
	
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	private var stocks = [Stock]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	private var stockQueryService = StockQueryService()
	
	var selectedStock: Stock?
	
	// MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if !showCancel {
			searchBar.showsCancelButton = false
		}

		// Show the keyboard
		searchBar.becomeFirstResponder()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "Stock"
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

		let stock = stocks[indexPath.row]
		
		cell.textLabel?.text = stock.symbol
		cell.detailTextLabel?.text = "\(stock.name) - \(stock.stockExchange)"
		
        return cell
    }

	// MARK: - Actions
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if !searchText.isEmpty {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			
			stockQueryService.suggestStocks(matching: searchText) { [weak self] newStocks in
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				self?.stocks = newStocks
			}
		}
		else {
			stocks.removeAll()
		}
	}
	
	// MARK: - Navigation
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		dismiss(animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let cell = sender as? UITableViewCell {

			guard let indexPath = tableView.indexPath(for: cell) else {
				fatalError("The selected cell is not being displayed by the table")
			}
			
			selectedStock = stocks[indexPath.row]
			
			// Hide the keyboard
			searchBar.resignFirstResponder()
		}
	}
}
