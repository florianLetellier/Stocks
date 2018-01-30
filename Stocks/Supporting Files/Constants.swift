//
//  Constants.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 11. 16..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

enum Constants {
    enum Chart {
        static let dateLabelCount = 7
        static let priceLabelCount = 3
    }
    
    enum Stock {
        static let historicalPricesValidFor: TimeInterval = 1
        static let articlesValidFor: TimeInterval = 60
    }
}
