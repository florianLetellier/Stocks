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
        static let dateLabelCount = 4
        static let priceLabelCount = 2
    }
    
    enum Stock {
        static let historicalPricesValidFor: TimeInterval = 60
        static let articlesValidFor: TimeInterval = 60
    }
}
