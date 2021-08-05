//
//  ProductInfo.swift
//  HarryPotterProducts
//

import UIKit
import Combine

// protocol for interfacing with product
protocol ProductInfo {
    var product: Product { get }

    var productIsFavorite: Bool { get }
    var productFavoritePublisher: Published<Bool>.Publisher { get }

    var productHasImage: Bool { get }
    var productImagePublisher: Published<UIImage?>.Publisher { get }

    func fetchProductImage()
    func toggleProductAsFavorite()
}
