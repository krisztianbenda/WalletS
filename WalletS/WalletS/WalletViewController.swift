//
//  WalletsTableViewController.swift
//  WalletS
//
//  Created by Benda Krisztián on 2017. 11. 28..
//  Copyright © 2017. krisztianbenda. All rights reserved.
//

import UIKit
import CoreData

class WalletViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return DataManager.instance.getWalletsCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath)
        let wallet = DataManager.instance.getWallet(index: indexPath.row)
        cell.textLabel?.text = wallet.name
        let walletAmount = DataManager.instance.getWalletAmount(which: wallet)
        cell.detailTextLabel?.text = String(Int64(walletAmount)) + " Ft"
        if walletAmount > 0.0 {
            cell.detailTextLabel?.textColor = .green
        } else if walletAmount < 0.0 {
            cell.detailTextLabel?.textColor = .red
        } else if walletAmount == 0.0 {
            cell.detailTextLabel?.textColor = .blue
        }
        return cell
    }
    
    @IBAction func createNewWallet(_ sender: Any) {
        let createWalletAlert = UIAlertController(title: "Create Wallet", message: "Enter the name and amount", preferredStyle: .alert)
        
        createWalletAlert.addTextField() {
            textField in
            textField.placeholder = "Wallet name"
        }
        
        createWalletAlert.addTextField() {
            textField in
            textField.placeholder = "Wallet amount"
            textField.keyboardType = .numberPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        createWalletAlert.addAction(cancelAction)
        
        let createAction = UIAlertAction(title: "Create", style: .default) {
            action in
            
            let textField = createWalletAlert.textFields!.first!
            if let amount = Double(createWalletAlert.textFields!.last!.text!){
                    DataManager.instance.createWallet(with: textField.text!, amount: amount)
            } else {
                DataManager.instance.createWallet(with: textField.text!, amount: 0.0)
            }
            self.tableView.reloadData()
            
        }
        createWalletAlert.addAction(createAction)
        present(createWalletAlert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let managedObjectContext = AppDelegate.managedContext
            let walletToDelete = DataManager.instance.getWallet(index: indexPath.row)
            DataManager.instance.removeWallet(at: indexPath.row)
            
            managedObjectContext.delete(walletToDelete)
            tableView.reloadData()
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTransactionsSegue" {
            let transactionViewController = segue.destination as! TransactionViewController
            transactionViewController.wallet = DataManager.instance.getWallet(index: tableView.indexPathForSelectedRow!.row)
        }
    }

}

extension WalletViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
