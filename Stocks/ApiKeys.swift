//
//  ApiKeys.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 09. 23..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

enum APIKeyError: String, LocalizedError {
	case ApiKeysPlistNotFound = "ApiKey.plist file not found."
	case KeyNotFound = "Key not found"
	case PlistTypeMismatch = "Dictionary value type mismatch, should be String"
	
	var errorDescription: String? {
		return self.rawValue
	}
}

func valueForAPIKey(_ keyname: String) throws -> String {
	if let url = Bundle.main.url(forResource: "ApiKeys", withExtension: "plist") {
		do {
			let data = try Data(contentsOf:url)
			
			guard
				let swiftDictionary = try PropertyListSerialization.propertyList(
					from: data,
					options: [],
					format: nil
				)  as? [String:String]
			else {
				throw APIKeyError.PlistTypeMismatch
			}

			if let key = swiftDictionary[keyname] {
				return key
			}
			else {
				throw APIKeyError.KeyNotFound
			}
		} catch {
			throw error
		}
	}
	else {
		throw APIKeyError.ApiKeysPlistNotFound
	}
}
