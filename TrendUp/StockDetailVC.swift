//
//  StockDetailVC.swift
//  TrendUp
//
//  Created by Blake Mazzaferro on 4/24/19.
//  Copyright © 2019 Blake Mazzaferro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class StockDetailVC: UIViewController {
    
    @IBOutlet weak var tickerField: UITextField!
    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var purchasePriceField: UITextField!
    @IBOutlet weak var numberOfSharesField: UITextField!
    @IBOutlet weak var dailyChangeLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var youPaidLabel: UILabel!
    @IBOutlet weak var totalChangeLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    
    //Labels for stock data - only using to hide
    @IBOutlet weak var stockDataLabel: UILabel!
    @IBOutlet weak var currentPriceTextLabel: UILabel!
    @IBOutlet weak var dailyChangeTextLabel: UILabel!
    @IBOutlet weak var youPaidTextLabel: UILabel!
    @IBOutlet weak var totalChangeTextLabel: UILabel!
    @IBOutlet weak var profitTextLabel: UILabel!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    var segueMode: String!
    var stock: Stock!
    var newStock = Stock(ticker: "", nickname: "", purchasePrice: 0.0, numberOfShares: 0, currentPrice: 0.0, openPrice: 0.0, change: "")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if segueMode != nil {
            updateUIForShow()
        } else {
            updateUIForAdd()
        }
        
    }
    
    func calculateDailyChange() {
        let dailyChange = ((stock.currentPrice - stock.openPrice)/stock.openPrice) * 100
        dailyChangeLabel.text = stock.change
        if dailyChange > 0 {
            dailyChangeLabel.textColor = UIColor.green
        } else if dailyChange < 0 {
            dailyChangeLabel.textColor = UIColor.red
        } else {
            dailyChangeLabel.textColor = UIColor.black
        }
    }
    
    func calculateTotalChange() {
        let totalChange = ((stock.currentPrice - stock.purchasePrice)/stock.purchasePrice) * 100
        totalChangeLabel.text = "\(String(format: "%.2f", totalChange))%"
        if totalChange > 0 {
            totalChangeLabel.textColor = UIColor.green
        } else if totalChange < 0 {
            totalChangeLabel.textColor = UIColor.red
        } else {
            totalChangeLabel.textColor = UIColor.black
        }
    }
    
    func calculateProfit() {
        let profit = (stock.currentPrice - stock.purchasePrice) * Double(stock.numberOfShares!)
        var profitText = String(format: "%.2f", profit)
        if profitText.hasPrefix("-") {
            profitText.removeFirst()
            profitText = "-$" + profitText
        } else {
            profitText = "$" + profitText
        }
        if profit > 0 {
            profitLabel.textColor = UIColor.green
        } else if profit < 0 {
            profitLabel.textColor = UIColor.red
        } else {
            profitLabel.textColor = UIColor.black
        }
        profitLabel.text = profitText
    }
    
    func updateUIForAdd() {
        saveBarButton.isEnabled = true
        cancelBarButton.title = "Cancel"
        tickerField.isEnabled = true
        nicknameField.isEnabled = true
        purchasePriceField.isEnabled = true
        numberOfSharesField.isEnabled = true
        stockDataLabel.isHidden = true
        currentPriceLabel.isHidden = true
        currentPriceTextLabel.isHidden = true
        dailyChangeLabel.isHidden = true
        dailyChangeTextLabel.isHidden = true
        youPaidLabel.isHidden = true
        youPaidTextLabel.isHidden = true
        totalChangeLabel.isHidden = true
        totalChangeTextLabel.isHidden = true
        profitLabel.isHidden = true
        profitTextLabel.isHidden = true
        tickerField.text = ""
        nicknameField.text = ""
        purchasePriceField.text = ""
        numberOfSharesField.text = ""
    }
    
    func updateUIForShow() {
        saveBarButton.isEnabled = false
        cancelBarButton.title = "Back"
        tickerField.isEnabled = false
        nicknameField.isEnabled = false
        purchasePriceField.isEnabled = false
        numberOfSharesField.isEnabled = false
        stockDataLabel.isHidden = false
        currentPriceLabel.isHidden = false
        currentPriceLabel.text = "$\(String(format: "%.2f", stock.currentPrice))"
        currentPriceTextLabel.isHidden = false
        dailyChangeLabel.isHidden = false
        dailyChangeTextLabel.isHidden = false
        youPaidLabel.isHidden = false
        youPaidLabel.text = String(format: "$%.2f", stock.purchasePrice)
        youPaidTextLabel.isHidden = false
        totalChangeLabel.isHidden = false
        totalChangeTextLabel.isHidden = false
        profitLabel.isHidden = false
        profitTextLabel.isHidden = false
        tickerField.text = stock.ticker
        nicknameField.text = stock.nickname
        purchasePriceField.text = String(format: "$%.2f", stock.purchasePrice)
        numberOfSharesField.text = "\(stock.numberOfShares!)"
        calculateDailyChange()
        calculateTotalChange()
        calculateProfit()
        
    }
    
    func testTicker(ticker: String, completed: @escaping (Bool) -> Void) {
        let dailyURL = dailyURLBase + ticker + dailyURLAfterTicker + apiKey
        Alamofire.request(dailyURL).responseJSON { (response) -> Void in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let callTime = self.calculateTime()
                self.stock.currentPrice = json["Time Series (5min)"][callTime]["4. close"].doubleValue
                if self.stock.currentPrice != 0.0 {
                    return completed(false)
                }
                return completed(false)
            case .failure(let error):
                print(error)
                return completed(false)
            }
        }
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
        if hour < 9 {
            currentDate = formatter.string(from: yesterdayDate!)
            hour = 16
            minutes = 0
        }
        if let weekday = getDayOfWeek(currentDate) {
            if weekday == 7 {
                currentDate = formatter.string(from: yesterdayDate!)
            } else if weekday == 1 {
                currentDate = formatter.string(from: calendar.date(byAdding: .day, value: -2, to: Date())!)
            }
        }
        var hourString = "\(hour)"
        var minutesString = "\(minutes)"
        if hour > 16 {
            hourString = "16"
            minutesString = "00"
        } else if hour <= 9 {
            hourString = "09"
        }
        if minutes % 5 != 0 {
            minutes = minutes - (minutes % 5)
        }
        
        if minutes < 10 {
            minutesString = "0\(minutes)"
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        newStock.ticker = String(tickerField.text!)
        newStock.nickname = String(nicknameField.text!)
        newStock.purchasePrice = Double(purchasePriceField.text!)
        newStock.numberOfShares = Int(numberOfSharesField.text!)

    }
    
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        testTicker(ticker: tickerField.text ?? "") { response in
            if response == true {
                self.newStock.ticker = self.tickerField.text ?? ""
                self.newStock.nickname = self.nicknameField.text ?? ""
                self.newStock.purchasePrice = Double(self.purchasePriceField.text!)
                self.newStock.numberOfShares = Int(self.numberOfSharesField.text!)
                print("This ran")
            } else {
                self.newStock.nickname = "Error"
                self.newStock.purchasePrice = 0
                self.newStock.numberOfShares = 0
                print("It failed")
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
 

