//
//  ArticleQueryService.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 22..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

class ArticleQueryService {
	typealias JsonObject = [String: Any]
	
	var dataTask: URLSessionDataTask?
	
	func searchArticle(matching searchTerm: String, handler: @escaping ([Article]) -> ())  {
		dataTask?.cancel()
		
		var articles = [Article]()
		let nyTimesApiKey: String
		
		do {
			nyTimesApiKey = try valueForAPIKey("NYTIMES_API_KEY")
		}
		catch {
			print(error.localizedDescription)
			handler(articles)
			return
		}

		let baseURL = "https://api.nytimes.com"
		var url = URLComponents(string: baseURL)
		url?.path = "/svc/search/v2/articlesearch.json"
		url?.queryItems = [
			URLQueryItem(name: "api-key", value: nyTimesApiKey),
			URLQueryItem(name: "sort", value: "newest"),
			URLQueryItem(name: "q", value: searchTerm)
		]
		
		if let url = url?.url {
			dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
				DispatchQueue.main.async {
					if let error = error {
						print("Error: \(error.localizedDescription)")
					}
					else if let data = data {
						if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JsonObject {
							guard
								let containerJson = json?["response"] as? JsonObject,
								let contanierJsonResults = containerJson["docs"] as? [JsonObject]
							else {
								handler(articles)
								return
							}
							
							for result in contanierJsonResults {
								if let newArticle = Article(json: result) {
									articles.append(newArticle)
								}
							}
						}
					}
					handler(articles)
				}
			})
			
			dataTask?.resume()
		}
		else {
			handler(articles)
		}
	}
}
