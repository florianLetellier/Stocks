//
//  Functions.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 30..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

extension String {
	init?(doubleToFormatedString: Double?) {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		
		if let value = doubleToFormatedString, let string = formatter.string(from: NSNumber(value: value)) {
			self.init(string)
		}
		else {
			return nil
		}
	}

	init?(doubleRepresentingPercentageToFormatedString: Double?) {
		let formatter = NumberFormatter()
		formatter.numberStyle = .percent
		formatter.maximumFractionDigits = 2
		
		if let value = doubleRepresentingPercentageToFormatedString, let string = formatter.string(from: NSNumber(value: value)) {
			self.init(string)
		}
		else {
			return nil
		}
	}

    init?(doubleToAbbreviatedString input: Double?, maximumDigits: Int) {
        guard let input = input else {
            return nil
        }
        
        let numberScaleSymbols = ["", "K", "M", "B", "T"]
        let numberScale = Swift.min((String(Int(input)).count - 1) / 3, numberScaleSymbols.count - 1)
        
        let outputNumberInNewScale = input / pow(1000, Double(numberScale))
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maximumDigits - String(Int(outputNumberInNewScale)).count
        
        self.init(
            (formatter.string(from: NSNumber(value: outputNumberInNewScale)) ?? String(outputNumberInNewScale))
            + numberScaleSymbols[numberScale]
        )
    }
}
