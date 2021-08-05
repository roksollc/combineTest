//
//  DetailViewController.swift
//  HarryPotterProducts
//

import UIKit

// controller for product details
class DetailViewController: UIViewController {
    private var viewModel: ProductInfo?

    private lazy var detailView: ProductDetailView = {
        let viewModel = self.viewModel ?? ProductDetailViewModel(product: Product(),
                                                                 session: URLSession.shared,
                                                                 imageCache: nil)
        return ProductDetailView(viewModel: viewModel)
    }()

    // MARK: - Configuration

    func set(viewModel: ProductInfo) {
        self.viewModel = viewModel
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Product"
        view.backgroundColor = .lightGray
        view.addSubview(detailView)

        detailView.snp.makeConstraints { make in
            make.edges.equalTo(view.snp.margins)
        }
    }
}
