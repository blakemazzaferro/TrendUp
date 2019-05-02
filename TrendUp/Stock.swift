//
//  Stock.swift
//  TrendUp
//
//  Created by Blake Mazzaferro on 4/24/19.
//  Copyright © 2019 Blake Mazzaferro. All rights reserved.
//

import Foundation
 

class Stock {

    var ticker: String!
    var nickname: String!
    var purchasePrice: Double!
    var numberOfShares: Int!
    var currentPrice: Double!
    var openPrice: Double!
    var change: String!

    
    init(ticker: String, nickname: String, purchasePrice: Double, numberOfShares: Int, currentPrice: Double, openPrice: Double, change: String) {
        self.ticker = ticker
        self.nickname = nickname
        self.purchasePrice = purchasePrice
        self.numberOfShares = numberOfShares
        self.currentPrice = currentPrice
        self.openPrice = openPrice
        self.change = change
    }

}

