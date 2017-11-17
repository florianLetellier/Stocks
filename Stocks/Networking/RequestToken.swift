//
//  RequestToken.swift
//  Stocks
//
//  Created by Marcell Bostyai on 2017. 11. 15..
//  Copyright © 2017. Marcell Bostyai. All rights reserved.
//

import Foundation

class RequestToken {
    weak var task: URLSessionDataTask?
    
    init(task: URLSessionDataTask) {
        self.task = task
    }
    
    func cancel() {
        task?.cancel()
    }
}
