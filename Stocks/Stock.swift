//
//  Stock.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 13..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

class Stock: NSObject, NSCoding {
	// MARK: - Properties
	let symbol: String
	let name: String
	let stockExchange: String
	var rates: Rates?
	
	private var dataTask: URLSessionDataTask?
	typealias JsonObject = [String: Any]
	
	// MARK: - Archiving Paths
	static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
	static let ArchiveURL = DocumentsDirectory.appendingPathComponent("stocks")
	
	// MARK: - Init
	init(symbol: String, name: String, stockExchange: String) {
		self.name = name
		self.stockExchange = stockExchange
		self.symbol = symbol
	}
	
	convenience init?(json: JsonObject) {
		guard
			let name = json["name"] as? String,
			let symbol = json["symbol"] as? String,
			let stockExchange = json["exchDisp"] as? String
		else {
			return nil
		}
		
		self.init(symbol: symbol, name: name, stockExchange: stockExchange)
	}
	
	// MARK: - NSCoding
	func encode(with aCoder: NSCoder) {
		aCoder.encode(symbol, forKey: "symbol")
		aCoder.encode(name, forKey: "name")
		aCoder.encode(stockExchange, forKey: "stockExchange")
	}
	
	required convenience init?(coder aDecoder: NSCoder) {
		guard
			let symbol = aDecoder.decodeObject(forKey: "symbol") as? String,
			let name = aDecoder.decodeObject(forKey: "name") as? String,
			let stockExchange = aDecoder.decodeObject(forKey: "stockExchange") as? String
		else {
			return nil
		}
		
		self.init(symbol: symbol, name: name, stockExchange: stockExchange)
	}
	
	// MARK: - Rates
	class Rates {
		var lastUpdate: Date?
		var latestPrice: Double?
		var priceChange: Double?
		var priceChangePercentage: Double?
		var open: Double?
		var daysHigh: Double?
		var daysLow: Double?
		var volume: Double?
		var peRatio: Double?
		var marketCapitalization: String?
		var yearHigh: Double?
		var yearLow: Double?
		var averageDailyVolume: Double?
		var dividendYield: Double?
		
		init?(json: JsonObject) {
			guard
				let contatinerJSON = json["query"] as? JsonObject,
				let contatinerJSONresults = contatinerJSON["results"] as? JsonObject,
				let contatinerJSONquote = contatinerJSONresults["quote"] as? JsonObject
				else {
					return nil
			}
			
			let latestPrice				= contatinerJSONquote["LastTradePriceOnly"] as? String ?? ""
			let priceChange				= contatinerJSONquote["Change"] as? String ?? ""
			let priceChangePercentage	= contatinerJSONquote["PercentChange"] as? String ?? ""
			let open					= contatinerJSONquote["Open"] as? String ?? ""
			let daysHigh				= contatinerJSONquote["DaysHigh"] as? String ?? ""
			let daysLow					= contatinerJSONquote["DaysLow"] as? String ?? ""
			let volume					= contatinerJSONquote["Volume"] as? String ?? ""
			let peRatio					= contatinerJSONquote["PERatio"] as? String ?? ""
			let marketCapitalization	= contatinerJSONquote["MarketCapitalization"] as? String
			let yearHigh				= contatinerJSONquote["YearHigh"] as? String ?? ""
			let yearLow					= contatinerJSONquote["YearLow"] as? String ?? ""
			let averageDailyVolume		= contatinerJSONquote["AverageDailyVolume"] as? String ?? ""
			let dividendYield			= contatinerJSONquote["DividendYield"] as? String ?? ""
			
			// YAHOO API returns percentage values as formated strings e.g., +30.1%
			func convertPercentageStringToDoblue(_ value: String) -> Double? {
				let withoutPlusSign = value.replacingOccurrences(of: "+", with: "")
				let withoutPlusOrPercentageSign = withoutPlusSign.replacingOccurrences(of: "%", with: "")
				
				if let convertedValue = Double(withoutPlusOrPercentageSign) {
					return convertedValue/100
				}
				else {
					return nil
				}
			}
			
			self.priceChangePercentage = convertPercentageStringToDoblue(priceChangePercentage)
			self.dividendYield = convertPercentageStringToDoblue(dividendYield)
			self.latestPrice = Double(latestPrice)
			self.priceChange = Double(priceChange)
			self.open = Double(open)
			self.daysHigh = Double(daysHigh)
			self.daysLow = Double(daysLow)
			self.volume = Double(volume)
			self.peRatio = Double(peRatio)
			self.marketCapitalization = marketCapitalization
			self.yearHigh = Double(yearHigh)
			self.yearLow = Double(yearLow)
			self.averageDailyVolume = Double(averageDailyVolume)
			self.lastUpdate = Date()
		}
	}
	
	// MARK: - Instance methods
	func refreshPrices(completionHandler: @escaping () -> ()) {
		dataTask?.cancel()
		
		// Building URL for JSON query
		let baseURL = "https://query.yahooapis.com"
		
		var stockURL = URLComponents(string: baseURL)
		stockURL?.path = "/v1/public/yql"
		stockURL?.queryItems = [
			URLQueryItem(name: "q", value: "select * from yahoo.finance.quotes where symbol=\"\(self.symbol)\""),
			URLQueryItem(name: "format", value: "json"),
			URLQueryItem(name: "env", value: "store://datatables.org/alltableswithkeys")
		]
		
		// Fetch JSON from URL
		if let url = stockURL?.url {
			let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData)
			
			dataTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
				DispatchQueue.main.async {
					if let error = error {
						print("Error: \(error.localizedDescription)")
					}
					else if let data = data {
						if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JsonObject, json != nil {
							self?.rates = Rates(json: json!)
						}
					}
					completionHandler()
				}
			}
			
			dataTask?.resume()
		}
		else {
			completionHandler()
		}
	}
}
