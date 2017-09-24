//
//  StockQueryService.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 22..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

class StockQueryService {
	private var dataTask: URLSessionDataTask?
	
	typealias JsonObject = [String: Any]
	
	func suggestStocks(matching searchTerm: String, handler: @escaping ([Stock]) -> ())  {
		var stocks = [Stock]()
		
		dataTask?.cancel()
		
		let baseURL = "https://s.yimg.com"
		var url = URLComponents(string: baseURL)
		url?.path = "/aq/autoc"
		url?.queryItems = [
			URLQueryItem(name: "query", value: searchTerm),
			URLQueryItem(name: "region", value: "US"),
			URLQueryItem(name: "lang", value: "en-US")
		]
		
		if let url = url?.url {
			dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
				DispatchQueue.main.async {
					if let error = error {
						print("Error: \(error.localizedDescription)")
					}
					else if let data = data {
						if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JsonObject {
							guard
								let containerJson = json?["ResultSet"] as? JsonObject,
								let contanierJsonResults = containerJson["Result"] as? [JsonObject]
							else {
								handler(stocks)
								return
							}
							
							for result in contanierJsonResults {
								if let newStock = Stock(json: result) {
									stocks.append(newStock)
								}
							}
							
						}
					}
					handler(stocks)
				}
			}
			dataTask?.resume()
		}
		else {
			handler(stocks)
		}
	}
}
