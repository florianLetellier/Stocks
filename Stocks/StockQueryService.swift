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
		
		let baseURL = "https://finance.google.com"
		var url = URLComponents(string: baseURL)
		url?.path = "/finance/match"
		url?.queryItems = [
			URLQueryItem(name: "matchtype", value: "matchall"),
            URLQueryItem(name: "q", value: searchTerm)
		]
		
		if let url = url?.url {
			dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
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
			dataTask?.resume()
		}
		else {
			handler(stocks)
		}
	}
}
