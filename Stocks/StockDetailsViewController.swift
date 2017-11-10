//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 30..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import UIKit
import Charts

class StockDetailsViewController: UIViewController {
	
	// MARK: - Properties
	@IBOutlet weak var scrollView: UIScrollView! {
		didSet {
			scrollView.isPagingEnabled = true
		}
	}
	@IBOutlet var priceView: UIView!
	@IBOutlet var articlesView: UIView!
    @IBOutlet var lineChartView: UIView!
    
	
	@IBOutlet weak var lastRefreshFootnoteLabel: UILabel!
	@IBOutlet weak var pageControl: UIPageControl!
	
	// Stock price subviews outlets
	@IBOutlet weak var companyNameLabel: UILabel!
	@IBOutlet weak var openLabel: UILabel!
	@IBOutlet weak var volLabel: UILabel!
	@IBOutlet weak var peLabel: UILabel!
	@IBOutlet weak var mktCapLabel: UILabel!
	@IBOutlet weak var yearHighLabel: UILabel!
	@IBOutlet weak var yearLowLabel: UILabel!
	@IBOutlet weak var avgVolLabel: UILabel!
	@IBOutlet weak var ytdChange: UILabel!
	
	// Articles subview
	private var articlesTVC: ArticlesTableViewController?
    private var priceChartVC: PriceChartViewController?
	
	private var scrollViewSubViews: [UIView]?
	
	var stock: Stock? {
		didSet {
			updateUI()
            
            if let stock = stock {
                articlesTVC?.searchTerm = stock.name
                priceChartVC?.setData(stock.historicalPrices)
            }
		}
	}

	// MARK: - Functions
	func updateUI() {
		// Set last refresh footnote
		if let lastRefresh = stock?.rates?.lastUpdate {
			let formater = DateFormatter()
			formater.dateStyle = .short
			formater.timeStyle = .short
			
            lastRefreshFootnoteLabel?.text = String.localizedStringWithFormat(
                NSLocalizedString("Last updated: %@", comment: ""),
                formater.string(from: lastRefresh)
            )
		}
		else {
			lastRefreshFootnoteLabel?.text = " "
		}
		
		// Stock details subview
		companyNameLabel?.text = stock?.name
		
		openLabel?.text = String(doubleToFormatedString: stock?.rates?.open) ?? "—"
        
		volLabel?.text = String(doubleToAbbreviatedString: stock?.rates?.volume, maximumDigits: 4) ?? "—"
		peLabel?.text = String(doubleToFormatedString: stock?.rates?.peRatio) ?? "—"
		mktCapLabel?.text = String(doubleToAbbreviatedString: stock?.rates?.marketCapitalization, maximumDigits: 4) ?? "—"
		yearHighLabel?.text = String(doubleToFormatedString: stock?.rates?.yearHigh) ?? "—"
		yearLowLabel?.text = String(doubleToFormatedString: stock?.rates?.yearLow) ?? "—"
		avgVolLabel?.text = String(doubleToAbbreviatedString: stock?.rates?.avgTotalVolume, maximumDigits: 4) ?? "—"
		ytdChange?.text = String(doubleRepresentingPercentageToFormatedString: stock?.rates?.ytdChange) ?? "—"
	}
	
	// MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Setup scrollView
		scrollViewSubViews = [
			priceView,
            lineChartView,
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
		if segue.identifier == "EmbedArticles" {
			articlesTVC = segue.destination as? ArticlesTableViewController
		}
        else if segue.identifier == "EmbedPriceChart" {
            priceChartVC = segue.destination as? PriceChartViewController
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
