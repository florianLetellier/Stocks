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
    var historicalPrices: [dailyPrice]?
	
	private var ratesDataTask: URLSessionDataTask?
    private var historicalRatesDataTask: URLSessionDataTask?
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
			let name = json["name"] as? String,
			let symbol = json["symbol"] as? String,
			let stockExchange = json["exchDisp"] as? String
		else {
			return nil
		}
		
		self.init(symbol: symbol, name: name, stockExchange: stockExchange)
	}
	
	// MARK: - Rates
    class Rates: Decodable {
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
    
    // MARK: - historicalRates
    class dailyPrice: Decodable {
        var date: Date
        var open: Double
        var close: Double
        var high: Double
        var low: Double
    }
	
	// MARK: - Instance methods
	func refreshPrices(completionHandler: @escaping () -> ()) {
		ratesDataTask?.cancel()
		
        let stockURL: URL! = {
            var url = URL(string: "https://api.iextrading.com/")
            
            url?.appendPathComponent("1.0")
            url?.appendPathComponent("stock")
            url?.appendPathComponent(self.symbol)
            url?.appendPathComponent("quote")
            
            return url
        }()

        ratesDataTask = URLSession.shared.dataTask(with: stockURL) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                else if let data = data {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    
                    do {
                        self?.rates = try decoder.decode(Stock.Rates.self, from: data)
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }
                completionHandler()
            }
        }
        
        ratesDataTask?.resume()
	}
    
    func refreshhistoricalRates(completionHandler: @escaping () -> ()) {
        historicalRatesDataTask?.cancel()
        
        let stockURL: URL! = {
            var url = URL(string: "https://api.iextrading.com/")
            
            url?.appendPathComponent("1.0")
            url?.appendPathComponent("stock")
            url?.appendPathComponent(self.symbol)
            url?.appendPathComponent("chart")
            url?.appendPathComponent("1m")
            
            return url
        }()
        
        historicalRatesDataTask = URLSession.shared.dataTask(with: stockURL) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                else if let data = data {
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    do {
                        self?.historicalPrices = try decoder.decode([Stock.dailyPrice].self, from: data)
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }
                completionHandler()
            }
        }
        
        historicalRatesDataTask?.resume()
    }

}
