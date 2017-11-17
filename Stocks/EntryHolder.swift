//
//  EntryHolder.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 11. 16..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

struct EntryHolder<Entry> {
    var entries = [Entry]() {
        didSet {
            lastSet = Date()
        }
    }
    
    private(set) var lastSet: Date?
}
