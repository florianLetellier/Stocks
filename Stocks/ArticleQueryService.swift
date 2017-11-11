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
	
	func searchArticle(forSymbol symbol: String, handler: @escaping ([Article]) -> ())  {
		dataTask?.cancel()
		
		var articles = [Article]()

		let baseURL = "https://finance.google.com"
		var url = URLComponents(string: baseURL)
		url?.path = "/finance/company_news"
		url?.queryItems = [
			URLQueryItem(name: "q", value: symbol),
            URLQueryItem(name: "output", value: "json")
		]
        
        struct GoogleFinanceCompanyNewsResult: Decodable {
            let clusters: [Cluster]
            
            struct Cluster: Decodable {
                let a: [Article]?
            }
        }
		
		if let url = url?.url {
			dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
				DispatchQueue.main.async {
					if let error = error {
						print("Error: \(error.localizedDescription)")
					}
					else if let data = data {
                        do {
                            let result = try JSONDecoder().decode(GoogleFinanceCompanyNewsResult.self, from: data)
                            
                            for cluster in result.clusters {
                                if let newArticles = cluster.a {
                                    articles += newArticles
                                }
                            }
                        }
                        catch {
                            print(error.localizedDescription)
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
