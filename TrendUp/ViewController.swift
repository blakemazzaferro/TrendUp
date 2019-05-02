//
//  ViewController.swift
//  TrendUp
//
//  Created by Blake Mazzaferro on 4/24/19.
//  Copyright © 2019 Blake Mazzaferro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import GoogleSignIn
 
class ViewController: UIViewController {
    
    @IBOutlet weak var dailyPercentageLabel: UILabel!
    @IBOutlet weak var allTimePercentageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    var authUI: FUIAuth!
    var stockDetail = StockDetail()
    var defaultsData = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadDefaultsData()
        
        authUI = FUIAuth.defaultAuthUI()
        authUI.delegate = self
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        stockDetail.getDataForArray() {
            self.updateButtonPressed(self)
        }
        
        managePortfolioAdding()
        showAlert(title: "API Restrictions", message: "API does not let you update your stocks more than once every minute.")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
        tableView.isHidden = false
    }
    
    
    func signIn() {
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        if authUI.auth?.currentUser == nil {
            self.authUI.providers = providers
            present(authUI.authViewController(), animated: true, completion: nil)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func saveDefaultsData() {
        var tickerArray = [String]()
        var nicknameArray = [String]()
        var numberOfSharesArray = [String]()
        var purchasePriceArray = [String]()
        for stock in stockDetail.stockArray {
            tickerArray.append(stock.ticker)
            nicknameArray.append(stock.nickname)
            numberOfSharesArray.append("\(stock.numberOfShares ?? 0)")
            purchasePriceArray.append("\(stock.purchasePrice ?? 0)")
        }
        defaultsData.set(tickerArray, forKey: "tickerArray")
        defaultsData.set(nicknameArray, forKey: "nicknameArray")
        defaultsData.set(numberOfSharesArray, forKey: "numberOfSharesArray")
        defaultsData.set(purchasePriceArray, forKey: "purchasePriceArray")
    }
    
    func loadDefaultsData() {
        let tickerArray = defaultsData.stringArray(forKey: "tickerArray") ?? [String]()
        let nicknameArray = defaultsData.stringArray(forKey: "nicknameArray") ?? [String]()
        let numberOfSharesArray = defaultsData.stringArray(forKey: "numberOfSharesArray") ?? [String]()
        let purchasePriceArray = defaultsData.stringArray(forKey: "purchasePriceArray") ?? [String]()
        if tickerArray.count > 0 {
            for i in 0...tickerArray.count-1 {
                let ppString = purchasePriceArray[i]
                let purchasePrice = Double(ppString)!
                let nosString = numberOfSharesArray[i]
                let nos = Int(nosString)!
                stockDetail.stockArray.append(Stock(ticker: tickerArray[i], nickname: nicknameArray[i], purchasePrice: purchasePrice, numberOfShares: nos, currentPrice: 0.0, openPrice: 0.0, change: ""))
            }
        }
        
        self.tableView.reloadData()
        
    }
    
    func managePortfolioAdding() {
        if stockDetail.stockArray.count >= 5 {
            addBarButton.isEnabled = false
            showAlert(title: "Stock Limit Reached", message: "Maximum 5 stocks allowed in portfolio. Please delete a stock before adding another")
        } else {
            addBarButton.isEnabled = true
        }
    }
    
    func updateDailyPortfolioChange() {
        var openValue = 0.0
        var currentValue = 0.0
        for stock in stockDetail.stockArray {
            openValue += stock.openPrice * Double(stock.numberOfShares ?? 0)
            currentValue += stock.currentPrice * Double(stock.numberOfShares ?? 0)
        }
        let totalDailyChange = ((currentValue - openValue) / openValue ) * 100
        dailyPercentageLabel.text = "\(String(format: "%.2f", totalDailyChange))%"
        if totalDailyChange > 0 {
            dailyPercentageLabel.textColor = UIColor.green
        } else if totalDailyChange < 0 {
            dailyPercentageLabel.textColor = UIColor.red
        } else {
            dailyPercentageLabel.textColor = UIColor.black
        }
    }
    
    func updateAllTimePortfolioChange() {
        var totalInvested = 0.0
        var currentValue = 0.0
        for stock in self.stockDetail.stockArray {
            totalInvested += stock.purchasePrice * Double(stock.numberOfShares ?? 0)
            currentValue += stock.currentPrice * Double(stock.numberOfShares ?? 0)
        }
        let totalChange = ((currentValue - totalInvested)/totalInvested) * 100
        allTimePercentageLabel.text = "\(String(format: "%.2f", totalChange))%"
        if totalChange > 0 {
            allTimePercentageLabel.textColor = UIColor.green
        } else if totalChange < 0 {
            allTimePercentageLabel.textColor = UIColor.red
        } else {
            allTimePercentageLabel.textColor = UIColor.black
        }
    }
    
    func updateCurrentValue() {
        var currentValue = 0.0
        for stock in self.stockDetail.stockArray {
            currentValue += stock.currentPrice * Double(stock.numberOfShares)
        }
        valueLabel.text = "$\(String(format: "%.2f", currentValue))"
    }

    
    
    @IBAction func updateButtonPressed(_ sender: Any!) {
        updateDailyPortfolioChange()
        updateAllTimePortfolioChange()
        updateCurrentValue()
        tableView.reloadData()
        saveDefaultsData()
    }
    
    @IBAction func editBarButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            addBarButton.isEnabled = true
            editBarButton.title = "Edit"
        } else {
            tableView.setEditing(true, animated: true)
            addBarButton.isEnabled = false
            editBarButton.title = "Done"
        }
        saveDefaultsData()
        managePortfolioAdding()
    }
    
    
    
    @IBAction func unwindFromStockDetailVC(segue: UIStoryboardSegue) {
        let sourceViewController = segue.source as! StockDetailVC
        stockDetail.testTicker(ticker: sourceViewController.newStock.ticker) { result in
            if result == true {
                self.stockDetail.stockArray.append(sourceViewController.newStock)
                self.stockDetail.getDataForArray() {
                    self.tableView.reloadData()
                }
                self.saveDefaultsData()
                self.updateButtonPressed(self)
            } else {
                self.showAlert(title: "Bad Ticker", message: "Ticker not found. Please re-try.")
            }
        }
        managePortfolioAdding()
        
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowStock" {
            let destination = segue.destination as! StockDetailVC
            destination.segueMode = "Show"
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.stock = stockDetail.stockArray[selectedIndexPath.row]
        } else {
            if let selectedPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedPath, animated: true)
            }
        }
    }

    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        saveDefaultsData()
        do {
            try authUI.signOut()
            tableView.isHidden = true
            signIn()
        } catch {
            tableView.isHidden = true
            print("Error: Sign Out Failed")
        }
    }
    
}

extension ViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user{
            tableView.isHidden = false
            print("We signed in with user \(user.email ?? "Unknown User")")
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let lightBlueColor = CIColor(red: 157, green: 197, blue: 231)
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        loginViewController.view.backgroundColor = UIColor(ciColor: lightBlueColor)
        let marginInsets: CGFloat = 16
        let imageHeight: CGFloat = 225
        let imageY = self.view.center.y - imageHeight
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - marginInsets*2, height: imageHeight)
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "TrendUp")
        logoImageView.contentMode = .scaleAspectFit
        loginViewController.view.addSubview(logoImageView)
        return loginViewController
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockDetail.stockArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockCell
        cell.updateCell(stock: self.stockDetail.stockArray[indexPath.row])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            stockDetail.stockArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        saveDefaultsData()
    }

}
