//
//  YourStocksTableViewCell.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 16..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import UIKit

protocol YourStocksTableViewCellDelegate {
	mutating func didTapChangeState()
}

class YourStocksTableViewCell: UITableViewCell {
	// MARK: - Properties
	@IBOutlet weak var symbolLabel: UILabel!
	@IBOutlet weak var quoteLabel: UILabel!
	@IBOutlet weak var changeButton: UIButton!
	
	var delegate: YourStocksTableViewCellDelegate?
	
	var stock: Stock? {
		didSet {
			updateUI()
		}
	}
	
	var state = State.priceChangePercentage {
		didSet {
			updateUI()
		}
	}
	
	enum State: Int {
		case priceChangePercentage
		case priceChange
		case marketCapitalization
		
		mutating func nextState() {
			switch self {
			case .priceChangePercentage:
				self = .priceChange
			case .priceChange:
				self = .marketCapitalization
			case .marketCapitalization:
				self = .priceChangePercentage
			}
		}
	}
	
	// MARK: - Functions
	@IBAction func changeStateTapped(_ sender: UIButton) {
		delegate?.didTapChangeState()
	}

	func updateUI() {
		// Symbol
		symbolLabel.text = stock?.symbol
		
		// Latest Price
		if let latestPrice = stock?.rates?.latestPrice {
			quoteLabel.text = String(latestPrice)
		}
		else {
			quoteLabel.text = nil
		}
		
		// Button
		let redColor = UIColor(red: 0.95, green: 0.23, blue: 0.22, alpha: 1)
		let greenColor = UIColor(red: 0.31, green: 0.81, blue: 0.39, alpha: 1)

		changeButton.backgroundColor = UIColor.clear
		
		if let priceChange = stock?.rates?.priceChange {
			if priceChange >= 0  {
				changeButton.setBackgroundImage(UIImage(color: greenColor), for: .normal)
			} else {
				changeButton.setBackgroundImage(UIImage(color: redColor), for: .normal)
			}
		}
		else {
			changeButton.setBackgroundImage(UIImage(color: UIColor.gray), for: .normal)
		}
		
		// Set button text for state
		switch state {
		case .marketCapitalization:
			changeButton.setTitle(
                String(doubleToAbbreviatedString: stock?.rates?.marketCapitalization, maximumDigits: 4) ?? "—", for: .normal
            )
		case .priceChange:
			changeButton.setTitle(String(doubleToFormatedString: stock?.rates?.priceChange) ?? "—", for: .normal)
		case .priceChangePercentage:
			changeButton.setTitle(
				String(doubleRepresentingPercentageToFormatedString: stock?.rates?.priceChangePercentage) ?? "—",
				for: .normal
			)
		}
	}
}
