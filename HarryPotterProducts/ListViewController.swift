//
//  ListViewController.swift
//  HarryPotterProducts
//

import UIKit
import SnapKit
import Combine

// controller for product list
class ListViewController: UIViewController {
    private var dataProvider: DataProvider {
        ProductDataProvider.default
    }
    private lazy var viewModel: ListViewModel = {
        ProductListViewModel(dataProvider: dataProvider)
    }()
    private lazy var listView: ProductListView = {
        ProductListView(viewModel: viewModel)
    }()

    private var selectedProductPublisher: AnyCancellable?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "All Products"
        view = listView

        // publisher for selected product via collection cell tap
        selectedProductPublisher = viewModel.selectedProductPublisher
            .sink { self.openDetails(withProduct: $0) }

        // load products
        self.viewModel.loadProducts()
    }

    // MARK: - Product details

    private func openDetails(withProduct product: Product?) {
        guard let product = product else { return }
        let detailViewModel = viewModel.detailViewModel(forProduct: product)
        let details = DetailViewController()
        details.set(viewModel: detailViewModel)
        navigationController?.pushViewController(details, animated: true)
    }
}
