//
//  StocksViewController.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 16..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import UIKit

class StocksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	// MARK: - Properites
	fileprivate var stocks: [Stock] = []
	private var stockDetailVC: StockDetailsViewController?
	fileprivate var stateOfCells = YourStocksTableViewCell.State.priceChangePercentage {
		didSet {
			for cell in tableView.visibleCells {
				if let cell = cell as? YourStocksTableViewCell {
					cell.state = stateOfCells
				}
			}
		}
	}

	@IBOutlet weak var tableView: UITableView!
	
	// MARK: - Instance Methods
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: true)
	}
	
	private func selectFirstRowIfNeeded() {
		if tableView.indexPathForSelectedRow == nil && !stocks.isEmpty {
			let rowToSelect = IndexPath(row: 0, section: 0)
			
			tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.none)
			tableView.delegate?.tableView?(tableView, didSelectRowAt: rowToSelect)
		}
	}
	
	private func saveStocks() {
        let propertyListEncoder = PropertyListEncoder()
        let encodedStocks = try? propertyListEncoder.encode(stocks)
        
        try? encodedStocks?.write(to: Stock.archiveURL, options: .noFileProtection)
	}
	
	private func loadStocks() -> [Stock]? {
        let propertyListDecoder = PropertyListDecoder()
        
        if let retrievedStocksData = try? Data(contentsOf: Stock.archiveURL),
            let decodedStocks = try? propertyListDecoder.decode([Stock].self, from: retrievedStocksData)
        {
            return decodedStocks
        }
        else {
            return nil
        }
	}
	
	private func refreshStocks(handler: (()->())? = nil) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		let dispatchGroup = DispatchGroup()
		
		for stock in stocks {
			dispatchGroup.enter()
			stock.refreshPrices() {
				dispatchGroup.leave()
			}
		}
		
		dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			handler?()
			
			if let visibleCells = self?.tableView.visibleCells {
				for cell in visibleCells {
					(cell as? YourStocksTableViewCell)?.updateUI()
				}
			}
			
			self?.stockDetailVC?.updateUI()
		}
	}
	
	private func performAddStockSegueIfNeeded() {
		if stocks.count < 1 {
			performSegue(withIdentifier: "AddStock", sender: nil)
		}
	}
	
	// MARK: - VC life cycle
	override func viewDidLoad() {
        super.viewDidLoad()
		
		// Load saved stocks
		if let savedStocks = loadStocks() {
			stocks = savedStocks
		}
		
		// Setup refresh control
		tableView.refreshControl = UIRefreshControl()
		tableView.refreshControl?.addTarget(
			self,
			action: #selector(StocksViewController.refreshControlRefresh(refreshControl:)),
			for: UIControlEvents.valueChanged
		)
		
		navigationItem.leftBarButtonItem = editButtonItem
		performAddStockSegueIfNeeded()
		selectFirstRowIfNeeded()
		refreshStocks()
    }
	
	// MARK: - TableViewDataSource and TableViewDelegate
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stocks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "yourStocksTableViewCell"
		
		guard
			let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? YourStocksTableViewCell
		else {
			fatalError("The dequeued cell is not an instance of StockTableViewCell.")
		}
		
		cell.stock = stocks[indexPath.row]
		cell.delegate = self
		return cell
    }

    func tableView(
		_ tableView: UITableView,
		commit editingStyle: UITableViewCellEditingStyle,
		forRowAt indexPath: IndexPath
	) {
		
        if editingStyle == .delete {
            // Delete the row from the data source
			stocks.remove(at: indexPath.row)
			saveStocks()
			
			// Update UI
            tableView.deleteRows(at: [indexPath], with: .fade)
			performAddStockSegueIfNeeded()
			selectFirstRowIfNeeded()
		}
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// If not already selected, update shown details for the selected cell
		if stockDetailVC?.stock?.symbol != stocks[indexPath.row].symbol {
			stockDetailVC?.stock = stocks[indexPath.row]
		}
	}

	// MARK: - Actions
	@objc func refreshControlRefresh(refreshControl: UIRefreshControl) {
		refreshStocks { 
			refreshControl.endRefreshing()
		}
	}
	
	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EmbedStockDetail" {
			stockDetailVC = segue.destination as? StockDetailsViewController
		}
		else if segue.identifier == "AddStock" && sender == nil {
			(segue.destination as? AddStockTableViewController)?.showCancel = false
		}
	}
	
	@IBAction func unwindToStocks(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.source as? AddStockTableViewController, let newStock = sourceViewController.selectedStock {
			// Add the selected stock if not in the array already
			if !(stocks.contains { $0.symbol == newStock.symbol }) {
				let newIndexPath = IndexPath(row: stocks.count, section: 0)
				
				stocks.append(newStock)
				saveStocks()
				
				tableView.insertRows(at: [newIndexPath], with: .automatic)
				
				if let cell = tableView.cellForRow(at: newIndexPath) as? YourStocksTableViewCell {
					cell.state = stateOfCells
				}
				
				selectFirstRowIfNeeded()
				refreshStocks()
			}
		}
	}
}

extension StocksViewController: YourStocksTableViewCellDelegate {
	func didTapChangeState() {
		stateOfCells.nextState()
	}
}
