//
//  AddStockTableViewController.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 13..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import UIKit

class AddStockTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    // MARK: - Model
    private var stocks = [Stock]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Instance properties
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    var showCancel = true
    private var stockQueryService = StockQueryService()
    private var requestToken: RequestToken?
    private(set) var selectedStock: Stock?
    
    // MARK: - Instance methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            stocks = []
            return
        }
        
        requestToken?.cancel()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        requestToken = stockQueryService.getStocks(matching: searchText) { [weak self] result in
            switch result {
            case Result.Success(let newStocks):
                self?.stocks = newStocks
            case Result.Failure(let error):
                self?.stocks = []
                print(error.localizedDescription)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: Notification.Name.UIKeyboardWillShow,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: Notification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            
            self.view.frame = CGRect(
                x: self.view.frame.origin.x,
                y: self.view.frame.origin.y,
                width: self.view.frame.width,
                height: window.origin.y + window.height - keyboardSize.height
            )
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil.")
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(
                x: self.view.frame.origin.x,
                y: self.view.frame.origin.y,
                width: self.view.frame.width,
                height: viewHeight + keyboardSize.height
            )
        } else {
            debugPrint("We're about to hide the keyboard and the keyboard size is nil.")
        }
    }
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !showCancel {
            searchBar.showsCancelButton = false
        }
        
        registerKeyboardNotifications()
        searchBar.becomeFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
            searchBar.resignFirstResponder()
        }
    }
}
