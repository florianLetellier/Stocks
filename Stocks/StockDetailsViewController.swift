//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 30..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import UIKit

class StockDetailsViewController: UIViewController {
	
	// MARK: - Properties
	@IBOutlet weak var scrollView: UIScrollView! {
		didSet {
			scrollView.isPagingEnabled = true
		}
	}
	@IBOutlet var priceView: UIView!
	@IBOutlet var articlesView: UIView!
	
	@IBOutlet weak var lastRefreshFootnoteLabel: UILabel!
	@IBOutlet weak var pageControl: UIPageControl!
	
	// Stock price subviews outlets
	@IBOutlet weak var companyNameLabel: UILabel!
	@IBOutlet weak var openLabel: UILabel!
	@IBOutlet weak var highLabel: UILabel!
	@IBOutlet weak var lowLabel: UILabel!
	@IBOutlet weak var volLabel: UILabel!
	@IBOutlet weak var peLabel: UILabel!
	@IBOutlet weak var mktCapLabel: UILabel!
	@IBOutlet weak var yearHighLabel: UILabel!
	@IBOutlet weak var yearLowLabel: UILabel!
	@IBOutlet weak var avgVolLabel: UILabel!
	@IBOutlet weak var yieldLabel: UILabel!
	
	// Articles subview
	private var articlesTVC: ArticlesTableViewController?
	
	private var scrollViewSubViews: [UIView]?
	
	var stock: Stock? {
		didSet {
			updateUI()
			articlesTVC?.searchTerm = stock?.name
		}
	}

	// MARK: - Functions
	func updateUI() {
		// Set last refresh footnote
		if let lastRefresh = stock?.rates?.lastUpdate {
			let formater = DateFormatter()
			formater.dateStyle = .short
			formater.timeStyle = .short
			
			lastRefreshFootnoteLabel?.text = "Last updated: \(formater.string(from: lastRefresh))"
		}
		else {
			lastRefreshFootnoteLabel?.text = " "
		}
		
		// Stock details subview
		companyNameLabel?.text = stock?.name
		
		openLabel?.text = String(doubleToFormatedString: stock?.rates?.open) ?? "—"
		highLabel?.text = String(doubleToFormatedString: stock?.rates?.daysHigh) ?? "—"
		lowLabel?.text = String(doubleToFormatedString: stock?.rates?.daysLow) ?? "—"
		volLabel?.text = String(doubleToFormatedMillionString: stock?.rates?.volume) ?? "—"
		peLabel?.text = String(doubleToFormatedString: stock?.rates?.peRatio) ?? "—"
		mktCapLabel?.text = stock?.rates?.marketCapitalization ?? "—"
		yearHighLabel?.text = String(doubleToFormatedString: stock?.rates?.yearHigh) ?? "—"
		yearLowLabel?.text = String(doubleToFormatedString: stock?.rates?.yearLow) ?? "—"
		avgVolLabel?.text = String(doubleToFormatedMillionString: stock?.rates?.averageDailyVolume) ?? "—"
		yieldLabel?.text = String(doubleRepresentingPercentageToFormatedString: stock?.rates?.dividendYield) ?? "—"
	}
	
	// MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Setup scrollView
		scrollViewSubViews = [
			priceView,
			articlesView
		]
    }
	
	override func viewDidLayoutSubviews() {
		if let subViews = scrollViewSubViews {
			scrollView.contentSize = CGSize(
				width: scrollView.bounds.width * CGFloat(subViews.count),
				height: scrollView.bounds.height
			)
			
			for i in 0..<subViews.count {
				scrollView.addSubview(subViews[i])
				subViews[i].frame.size.width = scrollView.bounds.width
				subViews[i].frame.size.height = scrollView.bounds.height
				subViews[i].frame.origin.x = CGFloat(i) * scrollView.bounds.width
			}
		}
	}
	
	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EmbededArticles" {
			articlesTVC = segue.destination as? ArticlesTableViewController
		}
	}
}

extension StockDetailsViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ sender: UIScrollView) {
		if sender == self.scrollView {
			let pageWith = scrollView.bounds.width
			let pageFraction = scrollView.contentOffset.x/pageWith
			
			pageControl.currentPage = Int(round(pageFraction))
		}
	}
}
