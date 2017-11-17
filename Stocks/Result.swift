//
//  Result.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 11. 15..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

enum Result<T> {
    case Success(T)
    case Failure(Error)
}
