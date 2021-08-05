//
//  ProductListViewModel.swift
//  HarryPotterProducts
//

import UIKit
import Combine

// protocol for a list view model
protocol ListViewModel {
    var products: Products { get }
    var productsPublisher: Published<Bool>.Publisher { get }
    var selectedProductPublisher: Published<Product?>.Publisher { get }

    func loadProducts()
    func cellViewModel(forProduct product: Product) -> ProductInfo
    func detailViewModel(forProduct product: Product) -> ProductInfo
    func selected(product: Product)
}

// implementation of ListViewModel
class ProductListViewModel: ListViewModel {
    private let dataProvider: DataProvider
    private var productPublisher: AnyCancellable?

    var products: Products {
        dataProvider.products
    }

    // published properties for dynamic changes:
    // -- list of products
    // -- selected product
    @Published var updatedProducts: Bool = false
    var productsPublisher: Published<Bool>.Publisher {
        $updatedProducts
    }

    @Published var selectedProduct: Product?
    var selectedProductPublisher: Published<Product?>.Publisher {
        $selectedProduct
    }

    // MARK: - Construction

    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider

        productPublisher = dataProvider.productsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatedProducts = true
        }
    }

    // MARK: - Loading and selecting of products

    func loadProducts() {
        dataProvider.loadProducts()
    }

    func selected(product: Product) {
        self.selectedProduct = product
    }

    // MARK: - Related view models

    func cellViewModel(forProduct product: Product) -> ProductInfo {
        detailViewModel(forProduct: product)
    }

    func detailViewModel(forProduct product: Product) -> ProductInfo {
        ProductDetailViewModel(product: product,
                               session: dataProvider.session,
                               imageCache: dataProvider.imageCache)
    }
}
