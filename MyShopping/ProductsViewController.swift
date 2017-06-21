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
    
    @IBOutlet weak var sortByShopButton: UIImageView!
    @IBOutlet weak var sortByTimeButton: UIImageView!
    @IBOutlet weak var sortAlphabeticallyButton: UIImageView!
    
    let defaultCornerRadius: CGFloat = 5.0
    
    let colorTheme = AppColors.Theme1()
    
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
    
    enum ListOrder: Int {
        case alphabetically
        case recency
        case shop
    }
    
    private var listSortedBy = ListOrder.shop {
        didSet {
            updateUI()
        }
    }
    
    private var searchText: String? {
        didSet {
            fetchData()
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
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(editButtonTapped(_:))), animated: false)
        shoppingList = try? ShoppingList.findOrCreateShoppingList(matching: "Shopping List", in: (container?.viewContext)!)
        tableView.backgroundColor = colorTheme.lightBackgroundColor
        tableView.sectionIndexBackgroundColor = colorTheme.lightBackgroundColor
        tableView.sectionIndexColor = colorTheme.darkestColor
        tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 3.0, 0.0)
        view.backgroundColor = colorTheme.lightBackgroundColor
        textField.backgroundColor = colorTheme.lightBackgroundColor
        textField.layer.borderColor = colorTheme.darkestColor.cgColor
        textField.layer.borderWidth = 2.0
        textField.layer.cornerRadius = defaultCornerRadius
        let textFieldSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleTextFieldSwipe(gesture:)))
        textFieldSwipeGesture.direction = .left
        textField.addGestureRecognizer(textFieldSwipeGesture)
        
        configureShopButtons()
        configureSortingButtons()
        addSwipeGestureToTableView()
        
        guard let shop1Name = userDefaults.string(forKey:"shop1Name"),
            let shop2Name = userDefaults.string(forKey:"shop2Name"),
            let shop3Name = userDefaults.string(forKey:"shop3Name"),
            let shop4Name = userDefaults.string(forKey:"shop4Name") else {
                return
        }
        let selectedShopIndex = userDefaults.integer(forKey: "selectedShopIndex")
        let productListSorting = userDefaults.integer(forKey: "productListsSorting")
        
        listSortedBy = ListOrder(rawValue: productListSorting) ?? .shop
        
        shops = [Shop(name: shop1Name, isSelected: selectedShopIndex == 0),
                 Shop(name: shop2Name, isSelected: selectedShopIndex == 1),
                 Shop(name: shop3Name, isSelected: selectedShopIndex == 2),
                 Shop(name: shop4Name, isSelected: selectedShopIndex == 3)]
        updateUI()
        printProducts()
    }

    private func configureShopButtons() {
        for index in 0..<shopViews.count {
            shopViews[index].layer.cornerRadius = defaultCornerRadius
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleShopButtonTap(gesture:)))
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOfShopButton(gesture:)))
            shopViews[index].addGestureRecognizer(tapGestureRecognizer)
            shopViews[index].addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    private func configureSortingButtons() {
        sortByShopButton.tintColor = colorTheme.darkestColor
        let tapToShopSortButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleSortByShopButtonTap(gesture:)))
        sortByShopButton.addGestureRecognizer(tapToShopSortButtonGesture)
        
        sortByTimeButton.tintColor = colorTheme.darkestColor
        let tapToTimeSortButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleSortByTimeButtonTap(gesture:)))
        sortByTimeButton.addGestureRecognizer(tapToTimeSortButtonGesture)
        
        sortAlphabeticallyButton.tintColor = colorTheme.darkestColor
        let tapToAlphabeticalSortButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleSortAlphabeticallyButtonTap(gesture:)))
        sortAlphabeticallyButton.addGestureRecognizer(tapToAlphabeticalSortButtonGesture)
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
    
    // MARK: - gesture handlers
    
    func handleLongPressOfShopButton(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            var shopIndex = 0
            for index in 0..<shopViews.count {
                if gesture.view == shopViews[index] {
                    shopIndex = index
                }
            }
            let alert = UIAlertController(title: "Rename \(shops[shopIndex].name!)", message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (alertAction) in
                self.shops[shopIndex].name = alert.textFields?[0].text
                self.updateUI()
                self.saveButtonTitlesToUserDefaults()
            })
            alert.addTextField(configurationHandler: { textField in
                textField.text = self.shops[shopIndex].name!
                textField.autocapitalizationType = .sentences
            })
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            
        }
    }
    
    func handleSwipe(gesture: UISwipeGestureRecognizer) {
        if !tableView.isEditing {
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
    }
    
    func handleSortByShopButtonTap(gesture: UITapGestureRecognizer) {
        listSortedBy = .shop
        userDefaults.set(ListOrder.shop.rawValue, forKey: "productListsSorting")
    }
    
    func handleSortByTimeButtonTap(gesture: UITapGestureRecognizer) {
        listSortedBy = .recency
        userDefaults.set(ListOrder.recency.rawValue, forKey: "productListsSorting")
    }
    
    func handleSortAlphabeticallyButtonTap(gesture: UITapGestureRecognizer) {
        listSortedBy = .alphabetically
        userDefaults.set(ListOrder.alphabetically.rawValue, forKey: "productListsSorting")
    }
    
    func handleTextFieldSwipe(gesture: UISwipeGestureRecognizer) {
        textField.text = ""
        searchText = ""
    }
    
    // MARK: - Help and action methods
    private func saveButtonTitlesToUserDefaults() {
        for index in 0..<shops.count {
            userDefaults.set(shops[index].name, forKey: "shop\(index+1)Name")
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            navigationItem.rightBarButtonItem? = UIBarButtonItem(title: "Edit", style: .plain ,  target: self, action: #selector(editButtonTapped(_:))) //"Edit"
            tableView.setEditing(false, animated: true)
            if let context = container?.viewContext {
                try? context.save()
            }
        } else {
            navigationItem.rightBarButtonItem? = UIBarButtonItem(title: "Done", style: .done ,  target: self, action: #selector(editButtonTapped(_:))) //"Done"
            tableView.setEditing(true, animated: true)
        }
    }

    private func updateUI() {
        // update selected shop and shop labels
        switch listSortedBy {
        case .alphabetically:
            sortAlphabeticallyButton.image = UIImage(named: "sort-az-selected")
            sortByTimeButton.image = UIImage(named: "sort-time")
            sortByShopButton.image = UIImage(named: "sort-shop")
        case .recency:
            sortByTimeButton.image = UIImage(named: "sort-time-selected")
            sortAlphabeticallyButton.image = UIImage(named: "sort-az")
            sortByShopButton.image = UIImage(named: "sort-shop")
        case .shop:
            sortByShopButton.image = UIImage(named: "sort-shop-selected")
            sortByTimeButton.image = UIImage(named: "sort-time")
            sortAlphabeticallyButton.image = UIImage(named: "sort-az")
        }
        for index in 0..<shopViews.count {
            shopLabels[index].text = shops[index].name
            
            if shops[index].isSelected {
                UIView.animate(withDuration: 0.2, animations: {
                    self.shopViews[index].backgroundColor = self.colorTheme.cellSelectColor
                })
            } else  {
                UIView.animate(withDuration: 0.2, animations: {
                    self.shopViews[index].backgroundColor = self.colorTheme.cellColor
                })
            }
        }
        fetchData()
    }
    
    private func fetchData() {
        var sortingKey = "shop1OrderNumber"
        var sortAscending = true
        var sectionNameKeyPath: String?
        
        switch listSortedBy {
        case .alphabetically:
            sortingKey = "name"
            sectionNameKeyPath = "name"
        case .recency:
            sortingKey = "lastAddedToList"
            sortAscending = false
            sectionNameKeyPath = nil
        case .shop:
            for index in 0..<shops.count {
                if shops[index].isSelected {
                    sortingKey = "shop\(index+1)OrderNumber"
                }
            }
            sectionNameKeyPath = nil
        }
        
        if let context = container?.viewContext {
            let request: NSFetchRequest<Product> = Product.fetchRequest()
            if let text = searchText {
                let newText = "*\(text)*"
                request.predicate = NSPredicate(format: "name LIKE[c] %@", newText)
            }
            request.sortDescriptors = [NSSortDescriptor(key: sortingKey, ascending: sortAscending)]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: sectionNameKeyPath,
                cacheName: nil)
            try? fetchedResultsController?.performFetch()
            fetchedResultsController?.delegate = self
            tableView.reloadData()
        }
    }
    
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
                item!.count = count + 1
            }
            try? context.save()
        }
        
        //updateUI()
        //printProducts()
    }
    
    private func printProducts() {
        if let products = fetchedResultsController?.fetchedObjects {
            for product in products {
                print("product \(product.name) shop1OrderNumber = \(product.shop1OrderNumber)")
            }
        }
    }
    
    private func updateBadgeCount() {
        if let fetchedObjects = fetchedResultsController?.fetchedObjects {
            var count = 0
            for item in fetchedObjects {
                if item.count > 0 && !item.isPicked {
                    count = count + 1
                }
            }
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textField.resignFirstResponder()
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
                    productCell.cellColor = colorTheme.cellSelectColor
                    productCell.productCountLabel.isHidden = false
                } else {
                    productCell.cellColor = colorTheme.cellColor
                    productCell.productCountLabel.isHidden = true
                }
                productCell.productCountLabel.text = String(product.count)
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if listSortedBy == .shop {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // get moved cell
        // update its order number for current selected shop
        // update order numbers for cells from source to destination indexpaths like so:
        // if moving down, decrease those order numbers
        // if moving up, increase those order numbers
        var sortingKey = "shop1OrderNumber"
        for index in 0..<shops.count {
            if shops[index].isSelected {
                sortingKey = "shop\(index+1)OrderNumber"
            }
        }
        guard let movedProduct = fetchedResultsController?.object(at: sourceIndexPath) else {
            return
        }
        movedProduct.setValue(destinationIndexPath.row+1, forKey: sortingKey)
        if sourceIndexPath.row < destinationIndexPath.row {
            for index in sourceIndexPath.row+1...destinationIndexPath.row {
                if let product = fetchedResultsController?.object(at: IndexPath(row: index, section: 0)) {
                    product.setValue(index, forKey: sortingKey)
                }
            }
        } else {
            for index in destinationIndexPath.row..<sourceIndexPath.row {
                if let product = fetchedResultsController?.object(at: IndexPath(row: index, section: 0)) {
                    product.setValue(index+2, forKey: sortingKey)
                }
            }
        }
        printProducts()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // handle deleting product
            if let product = fetchedResultsController?.object(at: indexPath) {
                if let context = container?.viewContext {
                    context.delete(product)
                    try? context.save()
                }
            }
        }
    }
    
    // disable swipe delete when not in edit mode so swipe can be used to decrease item count
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            if let product = fetchedResultsController?.object(at: indexPath) {
                let alert = UIAlertController(title: "Rename \(product.name ?? "product")", message: nil, preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (alertAction) in
                    product.name = alert.textFields?[0].text
                })
                alert.addTextField(configurationHandler: { textField in
                    textField.text = product.name ?? ""
                    textField.autocapitalizationType = .sentences
                })
                
                alert.addAction(cancelAction)
                alert.addAction(saveAction)
                self.present(alert, animated: true)
            }
        } else {
            if let cell = tableView.cellForRow(at: indexPath) as? ProductTableViewCell {
                if let name = cell.productName {
                    addItemToList(name)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // MARK: - TextField methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != nil && textField.text != "" {
            addItemToList(textField.text!)
        }
        textField.text = ""
        searchText = nil
        return true
        
    }

    @IBAction func textFieldChanged(_ sender: UITextField) {
        searchText = sender.text
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
        updateBadgeCount()
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
