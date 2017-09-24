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
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		
		if let value = doubleRepresentingPercentageToFormatedString, let string = formatter.string(from: NSNumber(value: value*100)) {
			self.init(string+"%")
		}
		else {
			return nil
		}
	}

	init?(doubleToFormatedMillionString: Double?) {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		
		if let value = doubleToFormatedMillionString, let string = formatter.string(from: NSNumber(value: value/1000000)) {
			self.init(string+"M")
		}
		else {
			return nil
		}
	}
}
