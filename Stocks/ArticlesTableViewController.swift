//
//  ArticlesTableViewController.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 30..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import UIKit

class ArticlesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	// MARK: - Properties
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	@IBOutlet weak var notFoundView: UIView!
	
	@IBOutlet weak var tableView: UITableView!

	private var articleQueryService = ArticleQueryService()
	
	private var articles = [Article]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	var searchTerm: String? {
		didSet {
			if let searchTerm = searchTerm, !searchTerm.isEmpty {
                spinner?.startAnimating()
                notFoundView?.isHidden = true

                articleQueryService.searchArticle(forSymbol: searchTerm) { [weak self] newArticles in
                    self?.spinner?.stopAnimating()
                    
                    if newArticles.isEmpty {
                        self?.notFoundView?.isHidden = false
                    }
                    
                    self?.articles = newArticles.sorted(by: {$0.pubDate > $1.pubDate})
                }
            }
			else {
				articles.removeAll()
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
