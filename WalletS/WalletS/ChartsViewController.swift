//
//  ChartsViewController.swift
//  WalletS
//
//  Created by Benda Krisztián on 2017. 11. 29..
//  Copyright © 2017. krisztianbenda. All rights reserved.
//

import UIKit
import Charts
import CoreData

class ChartsViewController: UIViewController, ChartViewDelegate, IValueFormatter{
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var pieChartView: PieChartView!
    var transactionNames = [String]()
    var transactionIndex = 0
    
    override func viewWillAppear(_ animated: Bool) {
        var walletNames = [String]()
        var walletsAmount = [Double]()

        
        for wallet in DataManager.instance.getWallets() {
            let amount = DataManager.instance.getWalletAmount(which: wallet)
            if amount > 0 {
                walletsAmount.append(Double(amount))
                walletNames.append(DataManager.instance.getWalletName(whichWallet: wallet))
            }
        }
        setChart(dataPoints: walletNames, values: walletsAmount)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChartView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        transactionIndex = 0
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        var entries = [PieChartDataEntry]()
        for (index, value) in values.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = dataPoints[index]
            entries.append( entry)
        }
        
        let set = PieChartDataSet( values: entries, label: "wallet")
        
        var colors: [UIColor] = []
        for _ in 0..<values.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        set.colors = colors
        let data = PieChartData(dataSet: set)
        pieChartView.data = data
        pieChartView.noDataText = "No data available"
        pieChartView.isUserInteractionEnabled = true
        
        let d = Description()
        d.text = "Positive wallets"
        pieChartView.chartDescription = d
        pieChartView.centerText = "WalletS"
        pieChartView.holeRadiusPercent = 0.2
        pieChartView.transparentCircleColor = UIColor.clear
        self.view.addSubview(pieChartView)
        
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let pieEntry = entry as! PieChartDataEntry
        let transactions = DataManager.instance.getTransactions(forWalletName: pieEntry.label!)
        transactionIndex = 0
        transactionNames = DataManager.instance.getTransactionNames(forWalletName: pieEntry.label!)
        transactionNames.insert("", at: 0)

        
        var amounts = [Double]()
        var actualAmount = DataManager.instance.getWalletStartingAmount(whichWallet: DataManager.instance.getWallet(walletName: pieEntry.label!))

        amounts.append(actualAmount)
        
        for transaction in transactions {
            actualAmount = actualAmount + transaction.income - transaction.expense
            amounts.append(actualAmount)
        }
        
        var entries = [ChartDataEntry]()
        for i in 0...(amounts.count-1){
            entries.append(ChartDataEntry(x: Double(i), y: amounts[i]))
        }
        
        let lineChartDataSet: LineChartDataSet = LineChartDataSet(values: entries, label: pieEntry.label!)
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.valueFont = UIFont(name: "HelveticaNeue-Light", size: 12)!
        
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(lineChartDataSet)
        
        let lineChartData: LineChartData = LineChartData(dataSets: dataSets)
        lineChartData.dataSets[0].valueFormatter = self
        
        let d = Description()
        d.text = "Transactions"
        
        self.lineChartView.chartDescription = d
        self.lineChartView.rightAxis.drawAxisLineEnabled = false
        self.lineChartView.xAxis.drawLabelsEnabled = false
        self.lineChartView.data = lineChartData
        self.lineChartView.isUserInteractionEnabled = false
        self.lineChartView.legend.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        
        
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler methodviewPortHandler: ViewPortHandler?) -> String{
        let returnValue = String(transactionNames[transactionIndex])
        transactionIndex += 1
        return returnValue
    }
    
}
