//
//  Article.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 13..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

class Article: Decodable {
    // MARK: - Properties
    let source: String
    let headline: String
    let pubDate: Date
    let url: URL
    
    // MARK: - Init
    init(source: String, headline: String, pubDate: Date, url: URL) {
        self.source = source
        self.headline = headline
        self.pubDate = pubDate
        self.url = url
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case source = "s"
        case headline = "t"
        case pubDate = "tt"
        case url = "u"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        source = try values.decode(String.self, forKey: .source)
        url = try values.decode(URL.self, forKey: .url)
        
        let headlineHtmlString = try values.decode(String.self, forKey: .headline)
        headline = headlineHtmlString.html2String
        
        let pubDateString = try values.decode(String.self, forKey: .pubDate)
        
        guard let pubDateInt = Double(pubDateString) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: values.codingPath,
                debugDescription: "Invalid publication date.")
            )
        }
        
        pubDate = Date(timeIntervalSince1970: pubDateInt)
    }
}
