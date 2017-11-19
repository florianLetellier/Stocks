//
//  ArticleQueryService.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 22..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

class ArticleQueryService {
    func searchForArticles(
        withSymbol symbol: String,
        completionHandler: @escaping (Result<[Article]>) -> Void
        ) -> RequestToken? {
        
        let searchArticlesUrl: URL = {
            let baseURL = "https://finance.google.com"
            
            var url = URLComponents(string: baseURL)!
            url.path = "/finance/company_news"
            url.queryItems = [
                URLQueryItem(name: "q", value: symbol),
                URLQueryItem(name: "output", value: "json")
            ]
            
            return url.url!
        }()
        
        let task = URLSession.shared.dataTask(with: searchArticlesUrl) { (data, _, error) in
            DispatchQueue.main.async {
                switch (data, error) {
                case (let data?, _):
                    do {
                        struct GoogleFinanceCompanyNewsResult: Decodable {
                            let clusters: [Cluster]
                            
                            struct Cluster: Decodable {
                                let a: [Article]?
                            }
                        }
                        
                        let result = try JSONDecoder().decode(GoogleFinanceCompanyNewsResult.self, from: data)
                        
                        var articles = [Article]()
                        
                        for cluster in result.clusters {
                            if let newArticles = cluster.a {
                                articles += newArticles
                            }
                        }
                        
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
}
