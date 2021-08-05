//
//  Collection+ext.swift
//  HarryPotterProducts
//

import Foundation

extension Collection {
    // returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
