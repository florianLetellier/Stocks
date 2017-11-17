//
//  StockQueryService.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 22..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

class StockQueryService {
	typealias JsonObject = [String: Any]
    
    func getRates(
        forSymbol symbol: String,
        completionHandler: @escaping (Result<Stock.Rates>) -> Void
        ) -> RequestToken {
        
        let stockURL: URL! = {
            var url = URL(string: "https://api.iextrading.com/")
            
            url?.appendPathComponent("1.0")
            url?.appendPathComponent("stock")
            url?.appendPathComponent(symbol)
            url?.appendPathComponent("quote")
            
            return url
        }()
        
        let task = URLSession.shared.dataTask(with: stockURL) { (data, _, error) in
            DispatchQueue.main.async {
                switch (data, error) {
                case (let data?, _):
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .millisecondsSince1970
                        
                        let rates = try decoder.decode(Stock.Rates.self, from: data)
                        
                        completionHandler(Result.Success(rates))
                    }
                    catch {
                        completionHandler(.Failure(error))
                    }
                case (_, let error?):
                    completionHandler(.Failure(error))
                case (nil, nil):
                    fatalError("Neither data or error received.")
                }
            }
        }
        
        task.resume()
        return RequestToken(task: task)
    }

    func getDailyPrices(
        forSymbol symbol: String,
        completionHandler: @escaping (Result<[Stock.DailyPrice]>) -> Void
    ) -> RequestToken {
        
        let stockURL: URL! = {
            var url = URL(string: "https://api.iextrading.com/")
            
            url?.appendPathComponent("1.0")
            url?.appendPathComponent("stock")
            url?.appendPathComponent(symbol)
            url?.appendPathComponent("chart")
            url?.appendPathComponent("1m")
            
            return url
        }()
        
        let task = URLSession.shared.dataTask(with: stockURL) { (data, _, error) in
            DispatchQueue.main.async {
                switch (data, error) {
                case (let data?, _):
                    do {
                        let decoder = JSONDecoder()
                        let dateFormatter = DateFormatter()
                        
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        decoder.dateDecodingStrategy = .formatted(dateFormatter)
                        
                        let articles = try decoder.decode([Stock.DailyPrice].self, from: data)
                        
                        completionHandler(Result.Success(articles))
                    }
                    catch {
                        completionHandler(.Failure(error))
                    }
                case (_, let error?):
                    completionHandler(.Failure(error))
                case (nil, nil):
                    fatalError("Neither data or error received.")
                }
            }
        }
        
        task.resume()
        return RequestToken(task: task)
    }
	
	func suggestStocks(matching searchTerm: String, handler: @escaping ([Stock]) -> ())  {
		var stocks = [Stock]()
		
		let baseURL = "https://finance.google.com"
		var url = URLComponents(string: baseURL)
		url?.path = "/finance/match"
		url?.queryItems = [
			URLQueryItem(name: "matchtype", value: "matchall"),
            URLQueryItem(name: "q", value: searchTerm)
		]
		
		if let url = url?.url {
			let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
				DispatchQueue.main.async {
					if let error = error {
						print("Error: \(error.localizedDescription)")
					}
					else if let data = data {
						if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JsonObject {
							guard let containerJson = json?["matches"] as? [JsonObject] else {
								handler(stocks)
								return
							}
							
							for result in containerJson {
								if let newStock = Stock(json: result) {
									stocks.append(newStock)
								}
							}
							
						}
					}
					handler(stocks)
				}
			}
            
			dataTask.resume()
		}
		else {
			handler(stocks)
		}
	}
}
