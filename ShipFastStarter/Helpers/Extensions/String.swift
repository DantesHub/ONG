//
//  String.swift
//  ONG
//
//  Created by Dante Kim on 9/10/24.
//

import Foundation

extension String {
    func containsNumber() -> Bool {
        let numberRange = self.rangeOfCharacter(from: .decimalDigits)
        return numberRange != nil
    }
}
