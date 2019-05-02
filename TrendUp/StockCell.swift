//
//  StockCell.swift
//  TrendUp
//
//  Created by Blake Mazzaferro on 4/25/19.
//  Copyright © 2019 Blake Mazzaferro. All rights reserved.
//

import UIKit
 
class StockCell: UITableViewCell {
    
    @IBOutlet weak var cellNicknameLabel: UILabel!
    @IBOutlet weak var cellPriceLabel: UILabel!
    @IBOutlet weak var cellChangeLabel: UILabel!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func updateCell(stock: Stock) {
        cellNicknameLabel.text = stock.nickname
        cellPriceLabel.text = "$\(String(format: "%.2f", stock.currentPrice!))"
        var absoluteValueChange = stock.change
        if (absoluteValueChange?.hasPrefix("-"))! {
            cellChangeLabel.textColor = UIColor.red
            absoluteValueChange?.removeFirst()
        } else {
            cellChangeLabel.textColor = UIColor.green
        }
        cellChangeLabel.text = absoluteValueChange
        
    }
    
}
