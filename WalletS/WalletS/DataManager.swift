//
//  DataManager.swift
//  WalletS
//
//  Created by Benda Krisztián on 2017. 12. 02..
//  Copyright © 2017. krisztianbenda. All rights reserved.
//

import UIKit
import CoreData

class DataManager {
    
    // MARK: - Properties
    
    private var wallets = [Wallet]()
    public static let instance = DataManager()
    public var fetchedResultsController: NSFetchedResultsController<Transaction>!
    
    // MARK: - Initialization
    
    private init(){
        fetchWallets()
    }
    
    private func fetchWallets(){
        let managedObjectContext = AppDelegate.managedContext
        
        let fetchRequest: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        
        do {
            wallets = try managedObjectContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func fetchTransactions(forWallet wallet: Wallet) -> [Transaction] {
        var transactions = [Transaction]()
        let managedObjectContext = AppDelegate.managedContext
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Transaction.wallet), wallet)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Transaction.date), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.fetchBatchSize = 60
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            transactions = (fetchedResultsController.fetchedObjects)!
        } catch let error as NSError {
            print("\(error.userInfo)")
        }
        fetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
        return transactions
    }
    
    // MARK: Get Functions
    
    public func getWalletsCount() -> Int {
        return wallets.count
    }
    
    public func getWallet(index n: Int) -> Wallet{
        return wallets[n]
    }
    
    public func getWalletAmount(which wallet: Wallet) -> Double {
        var amount:Double = Double(wallet.initValue)
        for transaction in wallet.transactions! {
            amount += Double((transaction as! Transaction).income)
            amount -= Double((transaction as! Transaction).expense)
        }
        return amount
    }
    
    public func getWalletsAmount() -> Double {
        var amount:Double = 0.0
        for wallet in wallets {
            amount += wallet.initValue
            for transaction in wallet.transactions! {
                amount += Double((transaction as! Transaction).income)
                amount -= Double((transaction as! Transaction).expense)
            }
        }
        return amount
    }
    
    public func getWalletName(whichWallet wallet: Wallet) -> String {
        return wallet.name!
    }
    
    public func getWalletsExpense() -> Double {
        var amount:Double = 0.0
        for wallet in wallets {
            for transaction in wallet.transactions! {
                amount += Double((transaction as! Transaction).expense)
            }
        }
        return amount
    }
    
    
    public func getWalletsIncome() -> Double {
        var amount:Double = 0.0
        for wallet in wallets {
            for transaction in wallet.transactions! {
                amount += Double((transaction as! Transaction).income)
            }
        }
        return amount
    }
    
    public func getTransactions(forWallet wallet: Wallet) -> [Transaction]{
        return fetchTransactions(forWallet: wallet)
    }
    
    public func getTransaction(forWallet wallet: Wallet, index row: Int) -> Transaction {
        return getTransactions(forWallet: wallet)[row]
    }
    
    public func getFetchedResultController(forWallet wallet: Wallet) -> NSFetchedResultsController<Transaction>! {
        _ = fetchTransactions(forWallet: wallet)
        return self.fetchedResultsController
    }
    
    public func getWallets() -> [Wallet]{
        return wallets
    }
    
    public func getTransactions(forWalletName walletName: String) -> [Transaction]{
        var transactions = [Transaction]()
        for wallet in wallets {
            if wallet.name == walletName{
                for transaction in wallet.transactions!{
                    transactions.append(transaction as! Transaction)
                }
            }
        }
        var retTrans: [Transaction]
        retTrans = transactions.sorted(by: { $0.date! < $1.date! })
        return retTrans
    }
    
    public func getTransactionNames(forWalletName walletName: String) -> [String] {
        let transactions = getTransactions(forWalletName: walletName).sorted(by: {$0.date! < $1.date!})
        var transactionNames = [String]()
        for t in transactions {
            transactionNames.append(t.name!)
        }
        return transactionNames
    }
    
    public func getWallet(walletName name: String) -> Wallet{
        for wallet in wallets{
            if wallet.name == name {
                return wallet
            }
        }
        return Wallet()
    }
    
    public func getWalletStartingAmount(whichWallet wallet: Wallet) -> Double {
        return wallet.initValue
    }
    
    public func getWalletsStartingAmount() -> Double {
        var amount = 0.0
        for wallet in wallets{
            amount += wallet.initValue
        }
        return amount
    }
    
    // MARK: - Functions
    
    public func createWallet(with name: String, amount initValue: Double) {
        let managedObjectContext = AppDelegate.managedContext
        
        let wallet = Wallet(context: managedObjectContext)
        wallet.name = name
        wallet.initValue = initValue
        
        saveContext()
        wallets.insert(wallet, at: 0)
    }
    
    public func saveContext () {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    public func removeWallet(at n: Int) {
        wallets.remove(at: n)
    }
    
    public func createTransaction(toWallet wallet: Wallet){
        let managedObjectContext = AppDelegate.managedContext
        
        let transaction = Transaction(context: managedObjectContext)
        transaction.name = "EmptyTransaction"
        transaction.setValue("EmptyTransaction", forKey: "name")
        transaction.date = Date()
        transaction.wallet = wallet
        transaction.transDescription = "Description"
        transaction.setValuesForKeys(["latitude":0.0, "longitude":0.0])
        saveContext()
    }
    
    public func removeTransaction(at indexPath: IndexPath){
        let managedObjectContext = AppDelegate.managedContext
        let transactionToDelete = fetchedResultsController.object(at: indexPath)
        managedObjectContext.delete(transactionToDelete)
    }
    
    public func modifyTransaction(which transaction: Transaction, toWallet wallet: Wallet, toName name: String, toIncome income: Double, toExpense expense: Double, toDescription descript: String, toLatitude latitude: Double, toLongitude longitude: Double){
        transaction.date = Date()
        transaction.wallet = wallet
        transaction.name = name
        transaction.income = income
        transaction.expense = expense
        transaction.transDescription = descript
        transaction.latitude = latitude
        transaction.longitude = longitude
        saveContext()
    }
    
}
