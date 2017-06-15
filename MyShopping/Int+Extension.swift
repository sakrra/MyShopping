//
//  Double+Extension.swift
//  MyShopping
//
//  Created by Sami Rämö on 31/05/2017.
//  Copyright © 2017 Sami Ramo. All rights reserved.
//

import Foundation

extension Int {
    
    func randomNumber() -> Int {
        return Int(arc4random_uniform(UInt32(self)))
    }
}
