//
//  Product.swift
//  MyShopping
//
//  Created by Sami Rämö on 11/05/2017.
//  Copyright © 2017 Sami Ramo. All rights reserved.
//

import UIKit
import CoreData

class Product: NSManagedObject {
    
    struct OrderNumberKey {
        static let shop1 = "shop1OrderNumber"
        static let shop2 = "shop2OrderNumber"
        static let shop3 = "shop3OrderNumber"
        static let shop4 = "shop4OrderNumber"
    }
    
    class func findOrCreateProduct(matching name: String, in context: NSManagedObjectContext) throws -> Product {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        let count = (try? context.count(for: request)) ?? 0
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
        let product = Product(context: context)
        product.name = name
        product.shop1OrderNumber = Int32(count + 1)
        product.shop2OrderNumber = Int32(count + 1)
        product.shop3OrderNumber = Int32(count + 1)
        product.shop4OrderNumber = Int32(count + 1)
        return product
    }
}
