//
//  StockRatesViewController.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 11. 12..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import UIKit

class StockRatesViewController: UIViewController {
    // MARK: - Model
    var stock: Stock? { didSet { updateViewFromModel() } }
    
    // MARK: - Instance properties
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var openLabel: UILabel!
    @IBOutlet private weak var volLabel: UILabel!
    @IBOutlet private weak var peLabel: UILabel!
    @IBOutlet private weak var mktCapLabel: UILabel!
    @IBOutlet private weak var yearHighLabel: UILabel!
    @IBOutlet private weak var yearLowLabel: UILabel!
    @IBOutlet private weak var avgVolLabel: UILabel!
    @IBOutlet private weak var ytdChange: UILabel!
    
    // MARK: - Instance methods
    private func updateViewFromModel() {
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
}
