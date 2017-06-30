//
//  ShoppingList.swift
//  MyShopping
//
//  Created by Sami Rämö on 11/05/2017.
//  Copyright © 2017 Sami Ramo. All rights reserved.
//

import UIKit
import CoreData

class ShoppingList: NSManagedObject {

    class func findOrCreateShoppingList(matching name: String, in context: NSManagedObjectContext) throws -> ShoppingList {
        let request: NSFetchRequest<ShoppingList> = ShoppingList.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        let shoppingList = ShoppingList(context: context)
        shoppingList.name = name
        return shoppingList
    }
}
