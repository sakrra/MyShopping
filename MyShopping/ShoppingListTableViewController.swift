//
//  ShoppingListTableViewController.swift
//  MyShopping
//
//  Created by Sami Rämö on 11/05/2017.
//  Copyright © 2017 Sami Ramo. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewController: FetchedResultsTableViewController {

    var fetchedResultsController: NSFetchedResultsController<Product>?
    
    // imageArray for background images, tuple with name and boolean to indicate if image is dark.
    let imageArray = [("tableViewBackground1", false), ("tableViewBackground2", false), ("tableViewBackground3", true), ("tableViewBackground4", false), ("tableViewBackground5", true)]
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet {
            updateUI()
        }
    }
    
    var shoppingListName = "Shopping List" {
        didSet {
            updateUI()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.contentInset = UIEdgeInsetsMake(3.0, 0.0, 0.0, 0.0)
        
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = UIColor.lightBackgroundColor
        let frame = tableView.frame
        let backgroundImageView = UIImageView(frame: frame)
        let randomImageNumber = 5.randomNumber()
        let (imageName, _) = imageArray[randomImageNumber]
        /*
        if (isDark) {
            navigationController?.navigationBar.barStyle = .black
            navigationController?.navigationBar.tintColor = UIColor.white
        } else {
             navigationController?.navigationBar.barStyle = .default
            navigationController?.navigationBar.tintColor = UIColor.black
        }
         */
        print(randomImageNumber)
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.image = nil
        tableView.backgroundView = backgroundImageView
        updateUI()
    }
    
    private func updateUI() {
        fetchData()
    }
    
    private func fetchData() {
        let selectedShopIndex = userDefaults.integer(forKey: "selectedShopIndex")
        let sortingKey = "shop\(selectedShopIndex+1)OrderNumber"
        if let context = container?.viewContext {
            let request: NSFetchRequest<Product> = Product.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: sortingKey, ascending: true)]
            request.predicate = NSPredicate(format: "ANY shoppingList.name LIKE[cd] %@", shoppingListName)
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil)
            try? fetchedResultsController?.performFetch()
            fetchedResultsController?.delegate = self
            tableView.reloadData()
        }
    }
    
    @IBAction func moreActions(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let clearAllAction = UIAlertAction(title: "Clear All", style: .destructive) { action in
            self.clearItems(all: true)
        }
        let clearPickedAction = UIAlertAction(title: "Clear Picked", style: .default) { action in
            self.clearItems(all: false)
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { action in
            self.openSettings()
        }

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(clearAllAction)
        actionSheet.addAction(clearPickedAction)
        actionSheet.addAction(settingsAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
    
    private func clearItems(all: Bool) {
        
        if all {
            let actionSheet = UIAlertController(title: "Are you sure?", message: "Really delete all items?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .destructive) { alert in
            }
            let noAction = UIAlertAction(title: "No", style: .default) { alert in
                return
            }
            
            actionSheet.addAction(yesAction)
            actionSheet.addAction(noAction)
            self.present(actionSheet, animated: true)
        } else {
            
        }
        
        // really clear
        
        
    }
    
    private func openSettings() {
        print("Settings opened")
        performSegue(withIdentifier: "showSettings", sender: nil)
    }
    
    // MARK: - Table view data source
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of section
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return products.count
        } else {
            return boughtProducts.count
        }
    }

    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)

        // Configure the cell...
        
        if let itemCell = cell as? ShoppingListTableViewCell {
            if let product = fetchedResultsController?.object(at: indexPath) {
                if indexPath.section == 0 {
                    itemCell.productName = product.name
                    if product.isPicked {
                        itemCell.cellColor = UIColor.cellSelectColor
                        itemCell.strikeImageView.isHidden = false
                    } else {
                        itemCell.cellColor = UIColor.cellColor
                        itemCell.strikeImageView.isHidden = true
                    }
                    if product.count > 1 {
                        itemCell.itemCountLabel.isHidden = false
                        itemCell.itemCountLabel.text = String(product.count)
                    } else {
                        itemCell.itemCountLabel.isHidden = true
                    }
                } else {
                    itemCell.cellColor = UIColor.red
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        } else {
            return tableView.sectionHeaderHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            return tableView.headerView(forSection: 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1. mark model to be picked
        // 2. picked items should be marked accordingly (cellforrowat)
        // 3. move picked items to end of the list or leave them, behavior is decided in settings.
        if let context = container?.viewContext {
            if let item = fetchedResultsController?.object(at: indexPath) {
                item.isPicked = !item.isPicked
                try? context.save()
            }
        }
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addItems" {
            if let vc = segue.destination as? ProductsViewController {
            }
        }
    }

}

extension ShoppingListTableViewController
{
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
}
