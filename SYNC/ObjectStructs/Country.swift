//
//  Country.swift
//  SYNC
//
//  Created by Marcus Tiffen (CODING) on 16/12/2024.
//

import Foundation


struct Country: Hashable {
    let code: String
    let name: String
    let flag: String
    
    // Implement hash and equality methods
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(name)
    }
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.code == rhs.code && lhs.name == rhs.name
    }
}
