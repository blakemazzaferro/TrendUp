//
//  StockDetail.swift
//  TrendUp
//
//  Created by Blake Mazzaferro on 4/24/19.
//  Copyright © 2019 Blake Mazzaferro. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class StockDetail {
    
    var stockArray = [Stock]()
    var hold = 0
    
    func openTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        let calendar = Calendar.current
        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: Date())
        var hour = calendar.component(.hour, from: date)
        var minutes = calendar.component(.minute, from: date)
        var currentDate = ""
        formatter.dateFormat = "yyyy-MM-dd"
        currentDate = formatter.string(from: date)
        if let weekday = getDayOfWeek(currentDate) {
            if weekday == 7 {
                currentDate = formatter.string(from: yesterdayDate!)
                hour = 9
                minutes = 35
            } else if weekday == 1 {
                currentDate = formatter.string(from: calendar.date(byAdding: .day, value: -2, to: Date())!)
                hour = 9
                minutes = 35
            } else if weekday == 2 && hour < 9 {
                currentDate = formatter.string(from: calendar.date(byAdding: .day, value: -3, to: Date())!)
                hour = 9
                minutes = 35
            }
        }
        let callString = "\(currentDate) 09:35:00"
        return callString
    }
    
    func calculateTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        let calendar = Calendar.current
        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: Date())
        var hour = calendar.component(.hour, from: date)
        var minutes = calendar.component(.minute, from: date)
        var currentDate = ""
        formatter.dateFormat = "yyyy-MM-dd"
        currentDate = formatter.string(from: date)
        if let weekday = getDayOfWeek(currentDate) {
            if weekday == 7 {
                currentDate = formatter.string(from: yesterdayDate!)
                hour = 16
                minutes = 0
            } else if weekday == 1 {
                currentDate = formatter.string(from: calendar.date(byAdding: .day, value: -2, to: Date())!)
                hour = 16
                minutes = 0
            } else if weekday == 2 && hour < 9 {
                currentDate = formatter.string(from: calendar.date(byAdding: .day, value: -3, to: Date())!)
                hour = 16
                minutes = 0
            }
        }
        var hourString = "\(hour)"
        var minutesString = "\(minutes)"
        if hour >= 16 {
            hourString = "16"
            minutesString = "00"
        } else if hour <= 9 {
            hourString = "09"
        }
        
        if minutes % 5 != 0 {
            minutes = minutes - (minutes % 5)
        }
        
//        if minutes < 10 {
//            minutesString = "0\(minutes)"
//        }
        let callString = "\(currentDate) \(hourString):\(minutesString):00"
        return callString
    }
    
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    
    
    func getStockData(stock: Stock) {
            let ticker = stock.ticker
            let dailyURL = dailyURLBase + ticker! + dailyURLAfterTicker + apiKey
            Alamofire.request(dailyURL).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let callTime = self.calculateTime()
                    print(callTime)
                    let openTime = self.openTime()
                    print(self.openTime)
                    let closePrice = json["Time Series (5min)"][callTime]["4. close"].doubleValue
                    let openPrice = json["Time Series (5min)"][openTime]["1. open"].doubleValue
                    stock.currentPrice = Double(closePrice)
                    stock.openPrice = Double(openPrice)
                    let dailyChange = ((stock.currentPrice - stock.openPrice)/stock.openPrice) * 100
                    stock.change = "\(String(format: "%.2f", dailyChange))%"
                case .failure(let error):
                    print(error)
                }
            }
        hold += 1
    }
    
    func getDataForArray(completed: @escaping () -> ()) {
        for stock in stockArray {
            getStockData(stock: stock)
        }
        if hold == stockArray.count-1 {
            completed()
            hold = 0
        }
    }
    
    func testTicker(ticker: String, result: @escaping (Bool) -> Void) {
        let dailyURL = dailyURLBase + ticker + dailyURLAfterTicker + apiKey
        Alamofire.request(dailyURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let callTime = self.calculateTime()
                let closePrice = json["Time Series (5min)"][callTime]["4. close"].doubleValue
                if closePrice == 0.0 {
                    result(false)
                } else {
                result(true)
                }
            case .failure(let error):
                print(error)
                result(false)
            }
        }
    }

}
