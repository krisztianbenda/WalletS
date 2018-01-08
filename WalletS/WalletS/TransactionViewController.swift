//
//  TransactionTableViewController.swift
//  WalletS
//
//  Created by Benda Krisztián on 2017. 11. 28..
//  Copyright © 2017. krisztianbenda. All rights reserved.
//

import UIKit
import CoreData

class TransactionViewController: UITableViewController {

    var wallet: Wallet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = wallet.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = DataManager.instance.getFetchedResultController(forWallet: wallet).sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        let transaction = DataManager.instance.fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = transaction.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        cell.detailTextLabel?.text = dateFormatter.string(from: transaction.date!)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    @IBAction func createTransactionButtonTap(_ sender: Any) {
        DataManager.instance.createTransaction(toWallet: wallet)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataManager.instance.removeTransaction(at: indexPath)
            tableView.reloadData()
        }
    }
    
    //   MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modifyTransactionSegue" {
            let vc = segue.destination as? ModifyTransactionViewController
            let row = tableView.indexPathForSelectedRow?.row
            vc?.transaction = DataManager.instance.getTransaction(forWallet: wallet, index: row!)
            vc?.wallet = wallet
        }
    }

}

extension TransactionViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!)!
            configure(cell: cell, at: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
