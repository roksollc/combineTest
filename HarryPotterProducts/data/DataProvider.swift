//
//  DataProvider.swift
//  HarryPotterProducts
//

import Foundation
import Combine

// protocol for a product data provider
protocol DataProvider {
    var session: URLSession { get }
    var imageCache: ImageCache? { get }
    var products: Products { get }
    var productsPublisher: Published<Products>.Publisher { get }
    func loadProducts()
}

// implementation of `DataProvider`
class ProductDataProvider: DataProvider {
    // for this app, we'll provide a singleton for access via starting view controller
    //    -- uses `URLSession.shared` for session
    //    -- uses `TemporaryImageCache` for image cache
    static let `default` = ProductDataProvider(session: nil,
                                               imageCache: InMemoryImageCache())

    @Published var products: Products = []

    // errors for retrieving/parsing data from JSON file
    enum DataError: Error {
        case missingJsonFile
        case jsonFile(error: Error)
    }

    let session: URLSession
    let imageCache: ImageCache?

    var productsPublisher: Published<Products>.Publisher {
        $products
    }

    // MARK: - Construction

    // injectable URLSession and ImageCache
    init(session: URLSession?, imageCache: ImageCache?) {
        self.session = session ?? URLSession.shared
        self.imageCache = imageCache
    }

    // load products from data source
    func loadProducts() {
        DispatchQueue.global().async {
            let products = try? self.parse(productData: self.productData)
            self.products = products ?? []
        }
    }

    // supporting functions for loading/parsing data from JSON file
    // no streaming at this point
    private var productData: Data? {
        guard let bundlePath = Bundle.main.path(forResource: "products",
                                                ofType: "json")
            else { return nil }
        return try? String(contentsOfFile: bundlePath).data(using: .utf8)
    }

    private func parse(productData: Data?) throws -> Products {
        guard let productData = productData
            else { throw DataError.missingJsonFile }
        do {
            return try JSONDecoder().decode(Products.self, from: productData)
        }
        catch {
            throw DataError.jsonFile(error: error)
        }
    }
}
