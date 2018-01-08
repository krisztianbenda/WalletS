//
//  SummaryViewController.swift
//  WalletS
//
//  Created by Benda Krisztián on 2017. 12. 02..
//  Copyright © 2017. krisztianbenda. All rights reserved.
//

import UIKit
import CoreData

class SummaryViewController: UIViewController {

    @IBOutlet weak var totalBudgetValueLabel: UILabel!
    @IBOutlet weak var totalIncomeValueLabel: UILabel!
    @IBOutlet weak var totalExpenseValueLabel: UILabel!
    @IBOutlet weak var sumOfStartingAmountsValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        totalBudgetValueLabel.text = String(Int64(DataManager.instance.getWalletsAmount())) + " HUF"
        totalBudgetValueLabel.font = UIFont(name: totalBudgetValueLabel.font.fontName, size: 30)
        
        totalIncomeValueLabel.text = String(Int64(DataManager.instance.getWalletsIncome())) + " HUF"
        totalIncomeValueLabel.textColor = .green
        totalIncomeValueLabel.font = UIFont(name: totalIncomeValueLabel.font.fontName, size: 28)
        
        totalExpenseValueLabel.font = UIFont(name: totalExpenseValueLabel.font.fontName, size: 28)
        totalExpenseValueLabel.text = String(Int64(DataManager.instance.getWalletsExpense())) + " HUF"
        totalExpenseValueLabel.textColor = .red
        
        sumOfStartingAmountsValueLabel.text = String(Int64(DataManager.instance.getWalletsStartingAmount()))  + " HUF"
        sumOfStartingAmountsValueLabel.font = UIFont(name: sumOfStartingAmountsValueLabel.font.fontName, size: 28)
    }
}
