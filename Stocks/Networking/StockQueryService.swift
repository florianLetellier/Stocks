//
//  StockQueryService.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 22..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

class StockQueryService {
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
    
    func getDailyPricesCoin(
        forSymbol symbol: String,
        completionHandler: @escaping (Result<Stock.ArrayPriceCoin>) -> Void
        ) -> RequestToken {
        
        let stockURL: URL! = {
            let url = URL(string: "https://min-api.cryptocompare.com/data/histominute?fsym=\(symbol)&tsym=USD&limit=60&aggregate=3&e=CCCAGG")
        
            
            
            return url
        }()
        print("url : \(stockURL!)")
        let task = URLSession.shared.dataTask(with: stockURL!) { (data, _, error) in
            DispatchQueue.main.async {
                switch (data, error) {
                case (let data?, _):
                    do {
                        let decoder = JSONDecoder()
                      
                        decoder.dateDecodingStrategy = .secondsSince1970
                        
                        let articles = try decoder.decode(Stock.ArrayPriceCoin.self, from: data)
                        dump(articles)
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
            url?.appendPathComponent("1d")
            
            print("url : \(url)")
            return url
        }()
        
        let task = URLSession.shared.dataTask(with: stockURL) { (data, _, error) in
            DispatchQueue.main.async {
                switch (data, error) {
                case (let data?, _):
                    do {
                        let decoder = JSONDecoder()
                        let dateFormatter = DateFormatter()
                        
                        dateFormatter.dateFormat = "yyyyMMdd"
                        decoder.dateDecodingStrategy = .formatted(dateFormatter)
                        dump("data : \(data.description)")
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
    
    func getStocks(
        matching searchTerm: String,
        completionHandler: @escaping (Result<[Stock]>) -> Void
        ) -> RequestToken {
        
        let stockSuggestionUrl: URL = {
            let baseURL = "https://finance.google.com"
            
            var url = URLComponents(string: baseURL)!
            url.path = "/finance/match"
            url.queryItems = [
                URLQueryItem(name: "matchtype", value: "matchall"),
                URLQueryItem(name: "q", value: searchTerm)
            ]
            
            return url.url!
        }()
        
        let task = URLSession.shared.dataTask(with: stockSuggestionUrl) { (data, _, error) in
            DispatchQueue.main.async {
                switch (data, error) {
                case (let data?, _):
                    
                    struct StockSuggestionResponse: Decodable {
                        let matches: [Stock]
                    }
                    
                    do {
                        let response = try JSONDecoder().decode(StockSuggestionResponse.self, from: data)
                        completionHandler(Result.Success(response.matches))
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
