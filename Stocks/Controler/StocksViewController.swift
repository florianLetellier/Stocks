//
//  StocksViewController.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 16..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import UIKit

class StocksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Model
    private var stocks: [Stock] = []
    
    // MARK: - Instance properties
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(
                self,
                action: #selector(StocksViewController.refreshControlRefresh(refreshControl:)),
                for: UIControlEvents.valueChanged
            )
        }
    }
    
    private var stockDetailsVC: StockDetailsViewController?
    
    private let stockQueryService = StockQueryService()
    
    private var stateOfCells = YourStocksTableViewCell.State.priceChangePercentage {
        didSet {
            updateCellsFromModel()
        }
    }
    
    // MARK: - Instance methods
    private func saveStocks() {
        let propertyListEncoder = PropertyListEncoder()
        let encodedStocks = try? propertyListEncoder.encode(stocks)
        
        try? encodedStocks?.write(to: Stock.archiveURL, options: .noFileProtection)
    }
    
    private func loadStocks() -> [Stock]? {
        guard let retrievedStocksData = try? Data(contentsOf: Stock.archiveURL) else {
            return nil
        }
        
        return try? PropertyListDecoder().decode([Stock].self, from: retrievedStocksData)
    }
    
    private func refreshStocks(handler: (()->())? = nil) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let dispatchGroup = DispatchGroup()
        
        for stock in stocks {
            dispatchGroup.enter()
            
            _ = stockQueryService.getRates(forSymbol: stock.symbol) { result in
                switch result {
                case Result.Success(let newRates):
                    stock.rates = newRates
                case Result.Failure(let error):
                    print(error.localizedDescription)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            handler?()
            
            self?.updateCellsFromModel()
            
            if let indexPath = self?.tableView.indexPathForSelectedRow {
                self?.stockDetailsVC?.stock = self?.stocks[indexPath.row]
            }
        }
    }
    
    @objc func refreshControlRefresh(refreshControl: UIRefreshControl) {
        refreshStocks {
            refreshControl.endRefreshing()
        }
    }
    
    private func performAddStockSegueIfNeeded() {
        if stocks.count < 1 {
            performSegue(withIdentifier: "AddStock", sender: nil)
        }
    }
    
    private func selectFirstRowIfNeeded() {
        if tableView.indexPathForSelectedRow == nil && !stocks.isEmpty {
            let rowToSelect = IndexPath(row: 0, section: 0)
            
            tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.none)
            tableView.delegate?.tableView?(tableView, didSelectRowAt: rowToSelect)
        }
    }
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load saved stocks
        if let savedStocks = loadStocks() {
            stocks = savedStocks
        }
        
        navigationItem.leftBarButtonItem = editButtonItem
        performAddStockSegueIfNeeded()
        selectFirstRowIfNeeded()
        refreshStocks()
    }
    
    // MARK: - TableViewDataSource and TableViewDelegate
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "yourStocksTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier, for: indexPath) as? YourStocksTableViewCell
        else {
            fatalError("The dequeued cell is not an instance of StockTableViewCell.")
        }

        cell.configureForStock(stocks[indexPath.row], withState: stateOfCells)
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
        if stockDetailsVC?.stock?.symbol != stocks[indexPath.row].symbol {
            stockDetailsVC?.stock = stocks[indexPath.row]
        }
    }
    
    private func updateCellsFromModel() {
        for cell in tableView.visibleCells {
            if let stockCell = cell as? YourStocksTableViewCell, let indexPath = tableView.indexPath(for: cell) {
                stockCell.configureForStock(stocks[indexPath.row], withState: stateOfCells)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedStockDetail" {
            stockDetailsVC = segue.destination as? StockDetailsViewController
        }
        else if segue.identifier == "AddStock" && sender == nil {
            (segue.destination as? AddStockTableViewController)?.showCancel = false
        }
    }
    
    @IBAction func unwindToStocks(sender: UIStoryboardSegue) {
        guard
            let sourceViewController = sender.source as? AddStockTableViewController,
            let newStock = sourceViewController.selectedStock
        else {
            return
        }

        // Add the selected stock if not in the array already
        if !(stocks.contains { $0.symbol == newStock.symbol }) {
            let newIndexPath = IndexPath(row: stocks.count, section: 0)
            
            stocks.append(newStock)
            saveStocks()
            
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
            if let cell = tableView.cellForRow(at: newIndexPath) as? YourStocksTableViewCell {
                cell.configureForStock(stocks[newIndexPath.row], withState: stateOfCells)
            }
            
            selectFirstRowIfNeeded()
            refreshStocks()
        }
    }
}

extension StocksViewController: YourStocksTableViewCellDelegate {
    func didTapChangeState() {
        stateOfCells.nextState()
    }
}
