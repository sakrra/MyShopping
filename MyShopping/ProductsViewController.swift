//
//  ItemsTableViewController.swift
//  MyShopping
//
//  Created by Sami Rämö on 11/05/2017.
//  Copyright © 2017 Sami Ramo. All rights reserved.
//

import UIKit
import CoreData

class ProductsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var shopViews: [UIView]!
    @IBOutlet var shopLabels: [UILabel]!
    
    var shoppingList: ShoppingList?
    
    private let userDefaults = UserDefaults.standard
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet {
            updateUI()
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<Product>?
    
    struct Shop: Equatable {
        var name: String?
        var isSelected: Bool
        
        init(name: String, isSelected: Bool) {
            self.name = name
            self.isSelected = isSelected
        }
        
        static func == (lhs: Shop, rhs: Shop) -> Bool {
            return lhs.name == rhs.name
        }
    }
    
    private var shops: Array<Shop> = [Shop(name: "Shop1", isSelected: true), Shop(name: "Shop2", isSelected: false), Shop(name: "Shop3", isSelected: false), Shop(name: "Shop4", isSelected: false)] {
        didSet {
            //updateUI()
        }
    }
    
    private func selectShop(_ selectedShop: Shop) {
        for index in 0..<shops.count {
            if shops[index] == selectedShop {
                userDefaults.set(index, forKey: "selectedShopIndex")
                shops[index].isSelected = true
            } else {
                shops[index].isSelected = false
            }
        }
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shoppingList = try? ShoppingList.findOrCreateShoppingList(matching: "Shopping List", in: (container?.viewContext)!)
        tableView.backgroundColor = UIColor.lightBackgroundColor
        view.backgroundColor = UIColor.lightBackgroundColor
        textField.backgroundColor = UIColor.lightCyanColor
        configureShopButtons()
        addSwipeGestureToTableView()
        
        guard let shop1Name = userDefaults.string(forKey:"shop1Name"),
            let shop2Name = userDefaults.string(forKey:"shop2Name"),
            let shop3Name = userDefaults.string(forKey:"shop3Name"),
            let shop4Name = userDefaults.string(forKey:"shop4Name") else {
                return
        }
        let selectedShopIndex = userDefaults.integer(forKey: "selectedShopIndex")
        shops = [Shop(name: shop1Name, isSelected: selectedShopIndex == 0),
                 Shop(name: shop2Name, isSelected: selectedShopIndex == 1),
                 Shop(name: shop3Name, isSelected: selectedShopIndex == 2),
                 Shop(name: shop4Name, isSelected: selectedShopIndex == 3)]
        updateUI()
    }

    private func configureShopButtons() {
        for index in 0..<shopViews.count {
            shopViews[index].layer.cornerRadius = shopViews[index].frame.height / 8
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleShopButtonTap(gesture:)))
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOfShopButton(gesture:)))
            shopViews[index].addGestureRecognizer(tapGestureRecognizer)
            shopViews[index].addGestureRecognizer(longPressGestureRecognizer)
        }
    }
    
    private func addSwipeGestureToTableView() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gesture:)))
        swipeGesture.direction = .left
        tableView.addGestureRecognizer(swipeGesture)
    }
    
    func handleShopButtonTap(gesture: UITapGestureRecognizer) {
        for index in 0..<shopViews.count {
            if gesture.view == shopViews[index] {
                selectShop(shops[index])
            }
        }
    }
    
    func handleLongPressOfShopButton(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            var shopIndex = 0
            for index in 0..<shopViews.count {
                if gesture.view == shopViews[index] {
                    shopIndex = index
                }
            }
            print("longPressed")
            let alert = UIAlertController(title: "Rename \(shops[shopIndex].name!)", message: "Enter new name", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (alertAction) in
                self.shops[shopIndex].name = alert.textFields?[0].text
                self.updateUI()
                self.saveButtonTitlesToUserDefaults()
            })
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "New name"
            })
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            
        }
    }
    
    func handleSwipe(gesture: UISwipeGestureRecognizer) {
        let swipeLocation = gesture.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: swipeLocation) {
            if let cell = tableView.cellForRow(at: indexPath) as? ProductTableViewCell {
                if let context = container?.viewContext {
                    let item = try? Product.findOrCreateProduct(matching: cell.productName!, in: context)
                    if item != nil {
                        let oldCount = item!.count
                        if oldCount > 0 {
                            item!.count = oldCount - 1
                            if oldCount == 1 {
                                shoppingList?.removeFromProducts(item!)
                            }
                        }
                    }
                    try? context.save()
                }
            }
        }
    }
    
    private func saveButtonTitlesToUserDefaults() {
        for index in 0..<shops.count {
            userDefaults.set(shops[index].name, forKey: "shop\(index+1)Name")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func updateUI() {
        // update selected shop and shop labels
        for index in 0..<shopViews.count {
            shopLabels[index].text = shops[index].name
            
            if shops[index].isSelected {
                UIView.animate(withDuration: 0.3, animations: {
                    self.shopViews[index].backgroundColor = UIColor.darkCyanColor
                })
            } else  {
                UIView.animate(withDuration: 0.3, animations: {
                    self.shopViews[index].backgroundColor = UIColor.white
                })
            }
        }
        fetchData()
    }
    
    private func fetchData() {
        var sortingKey = "shop1OrderNumber"
        for index in 0..<shops.count {
            if shops[index].isSelected {
                sortingKey = "shop\(index+1)OrderNumber"
            }
        }
        print("sortingKey = \(sortingKey)")
        if let context = container?.viewContext {
            let request: NSFetchRequest<Product> = Product.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: sortingKey, ascending: true)]
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
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)

        // Configure the cell...
        if let product = fetchedResultsController?.object(at: indexPath) {
            if let productCell = cell as? ProductTableViewCell {
                productCell.productName = product.name
                //productCell.backgroundColor = UIColor.lightBackgroundColor
                if product.count > 0 {
                    productCell.cellColor = UIColor.darkCyanColor
                    productCell.productCountLabel.isHidden = false
                } else {
                    productCell.cellColor = UIColor.cellColor
                    productCell.productCountLabel.isHidden = true
                }
                productCell.productCountLabel.text = String(product.count)
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let context = container?.viewContext {
            if let product = fetchedResultsController?.object(at: indexPath) {
                context.delete(product)
                try? context.save()
            }
        }
        
    }
    */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ProductTableViewCell {
            if let name = cell.productName {
                addItemToList(name)
            }
        }
    }
    
    // MARK: - TextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != nil && textField.text != "" {
            addItemToList(textField.text!)
        }
        textField.text = ""
        return true
        
    }
    
    // MARK: - help methods
    
    private func addItemToList(_ item: String) {
        // here we create or fetch item to/from db and add it to the list
        let trimmedString = item.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if let context = container?.viewContext {
            let item = try? Product.findOrCreateProduct(matching: trimmedString, in: context)
            //item?.product = product
            if item != nil {
                if item!.count == 0 {
                    item!.inTheListCount = item!.inTheListCount + 1
                    item!.lastAddedToList = NSDate()
                    item!.isPicked = false
                    shoppingList?.addToProducts(item!)
                }
                let count = item!.count
                print(count)
                item!.count = count + 1
            }
            try? context.save()
        }
        
        //updateUI()
        //printProducts()
    }
    
    private func printProducts() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        if let context = container?.viewContext {
            if let products = try? context.fetch(request) {
                if products.count > 0 {
                    print(products)
                }
            }
        }
    }
    
    // MARK: FetchedResultsController delegate
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .bottom)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
