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
    // MARK: - Model
    var stock: Stock? {
        didSet {
            if let stock = stock {
                stockRatesVC?.stock = stock
                priceChartVC?.setData(from: stock)
                articlesTVC?.setArticles(from: stock)
            }
        }
    }
	
	// MARK: - Properties
    @IBOutlet var stockRatesView: UIView!
    @IBOutlet var articlesView: UIView!
    @IBOutlet var lineChartView: UIView!

    @IBOutlet weak var pageControl: UIPageControl!
    
	@IBOutlet weak var scrollView: UIScrollView! {
		didSet {
			scrollView.isPagingEnabled = true
		}
	}

	private var articlesTVC: ArticlesTableViewController?
    private var priceChartVC: PriceChartViewController?
    private var stockRatesVC: StockRatesViewController?
	
    lazy private var scrollViewSubViews: [UIView] = [stockRatesView, lineChartView, articlesView]
	
	// MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(
            width: scrollView.bounds.width * CGFloat(scrollViewSubViews.count),
            height: scrollView.bounds.height
        )
        
        for i in 0..<scrollViewSubViews.count {
            scrollView.addSubview(scrollViewSubViews[i])
            scrollViewSubViews[i].frame.size.width = scrollView.bounds.width
            scrollViewSubViews[i].frame.size.height = scrollView.bounds.height
            scrollViewSubViews[i].frame.origin.x = CGFloat(i) * scrollView.bounds.width
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
        else if segue.identifier == "EmbedStockRates" {
            stockRatesVC = segue.destination as? StockRatesViewController
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
