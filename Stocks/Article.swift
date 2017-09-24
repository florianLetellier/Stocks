//
//  Article.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 07. 13..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

class Article {
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
	
	convenience init?(json: [String: Any]) {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		
		guard
			let source				= json["source"] as? String, !source.isEmpty,
			let pubDateString		= json["pub_date"] as? String,
			let pubDate 			= dateFormatter.date(from: pubDateString),
			let urlString			= json["web_url"] as? String,
			let url					= URL(string: urlString),
			let headlineContainer	= json["headline"] as? [String: Any],
			let headline			= headlineContainer["main"] as? String
		else {
			return nil
		}

		self.init(source: source, headline: headline, pubDate: pubDate, url: url)
	}
}
