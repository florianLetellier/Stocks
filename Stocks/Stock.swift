//
//  Stock.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 13..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

class Stock: Codable {
	// MARK: - Properties
	let symbol: String
	let name: String
	let stockExchange: String
	var rates: Rates?
    var historicalPrices = EntryHolder<DailyPrice>()
    var relatedArticles = EntryHolder<Article>()

	typealias JsonObject = [String: Any]
	
	// MARK: - Archiving Paths
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("stocks").appendingPathExtension("plist")
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case symbol
        case name
        case stockExchange
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try values.decode(String.self, forKey: .symbol)
        name = try values.decode(String.self, forKey: .name)
        stockExchange = try values.decode(String.self, forKey: .stockExchange)
    }

	// MARK: - Init
	init(symbol: String, name: String, stockExchange: String) {
		self.name = name
		self.stockExchange = stockExchange
		self.symbol = symbol
	}
	
	convenience init?(json: JsonObject) {
		guard
			let name = json["n"] as? String,
			let symbol = json["t"] as? String,
			let stockExchange = json["e"] as? String
		else {
			return nil
		}
		
		self.init(symbol: symbol, name: name, stockExchange: stockExchange)
	}
	
    // MARK: - Nested structs    
    struct Rates: Decodable {
		var lastUpdate: Date?
		var latestPrice: Double?
		var priceChange: Double?
		var priceChangePercentage: Double?
		var open: Double?
		var volume: Double?
		var peRatio: Double?
		var marketCapitalization: Double?
		var yearHigh: Double?
		var yearLow: Double?
		var avgTotalVolume: Double?
        var ytdChange: Double?
        
        enum CodingKeys: String, CodingKey {
            case lastUpdate = "latestUpdate"
            case latestPrice
            case priceChange = "change"
            case priceChangePercentage = "changePercent"
            case open
            case volume = "latestVolume"
            case peRatio
            case marketCapitalization = "marketCap"
            case yearHigh = "week52High"
            case yearLow = "week52Low"
            case avgTotalVolume
            case ytdChange
        }
	}
    
    struct DailyPrice: Decodable {
        var date: Date
        var open: Double
        var close: Double
        var high: Double
        var low: Double
    }
}
