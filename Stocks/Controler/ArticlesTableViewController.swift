//
//  ArticlesTableViewController.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 30..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import UIKit

class ArticlesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Model
    var articles = [Article]() {
        didSet {
            articles.sort(by: { $0.pubDate > $1.pubDate })
            tableView.reloadData()
            notFoundView?.isHidden = !articles.isEmpty
        }
    }
    
	// MARK: - Instance properties
	@IBOutlet private weak var spinner: UIActivityIndicatorView!
	@IBOutlet private weak var notFoundView: UIView!
	@IBOutlet private weak var tableView: UITableView!

	private let articleQueryService = ArticleQueryService()
    private var requestToken: RequestToken?
    
    // MARK: - Instance methods
    func setArticles(from stock: Stock) {        
        if let lastSet = stock.relatedArticles.lastSet?.timeIntervalSinceNow, lastSet > (-Constants.Stock.articlesValidFor) {
            articles = stock.relatedArticles.entries
        }
        else {
            requestToken?.cancel()
            spinner?.startAnimating()

            requestToken = articleQueryService.searchForArticles(withSymbol: stock.symbol) { [weak self] result in
                switch result {
                case Result.Success(let newArticles):
                    stock.relatedArticles.entries = newArticles
                    self?.articles = newArticles
                case Result.Failure(let error):
                    self?.articles = []
                    print(error.localizedDescription)
                }
                
                self?.spinner?.stopAnimating()
            }
        }
    }

    // MARK: - UITableViewDataSource and UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "Article"
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		let article = articles[indexPath.row]
		
		cell.textLabel?.text = article.headline
		
		let formater = DateFormatter()
		formater.dateStyle = .short
		formater.timeStyle = .short
		
		cell.detailTextLabel?.text = "\(article.source) - \(formater.string(from: article.pubDate))"
		
		return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		UIApplication.shared.open(articles[indexPath.row].url)
	}
}
