//
//  ProductDetailViewModel.swift
//  HarryPotterProducts
//

import UIKit
import Combine

typealias VoidCallback = () -> Void

// implementation of `ProductInfo`
class ProductDetailViewModel: ProductInfo {
    let product: Product

    var productIsFavorite: Bool {
        product.isFavorite
    }
    var productHasImage: Bool {
        product.imageURL != nil
    }

    // publisher for dynamic product image
    var productImagePublisher: Published<UIImage?>.Publisher {
        product.$image
    }

    // publisher for dynamic product favorite
    var productFavoritePublisher: Published<Bool>.Publisher {
        product.$isFavorite
    }

    private let fetcher: ImageFetcher
    private var imagePublisher: AnyCancellable?

    // MARK: - Construction

    // injectable Product, URLSession, and ImageCache
    init(product: Product,
         session: URLSession,
         imageCache: ImageCache? = nil) {
        self.product = product
        self.fetcher = ImageFetcher(session: session,
                                    cache: imageCache)

        imagePublisher = fetcher.$image
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] image in
                guard let image = image else { return }
                self?.product.image = image
            })
    }

    // fetch associated product image if available
    func fetchProductImage() {
        guard let imageUrl = product.productImageUrl
            else { return }
        fetcher.fetchImage(forUrl: imageUrl)
    }

    // toggle product as favorite
    func toggleProductAsFavorite() {
        product.isFavorite = !product.isFavorite
    }
}
