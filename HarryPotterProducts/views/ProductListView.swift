//
//  ProductListView.swift
//  HarryPotterProducts
//

import UIKit
import SnapKit
import Combine

// view for product list
final class ProductListView: UIView {
    private let viewModel: ListViewModel
    private let gridSpacing: CGFloat = 16
    private var productsPublisher: AnyCancellable?

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = gridSpacing
        layout.minimumLineSpacing = gridSpacing
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }()

    private var layoutWidth: CGFloat {
        let viewWidth = layout.collectionViewContentSize.width
        let spacing = gridSpacing * 2
        let width = viewWidth - spacing
        return max(width, 0)
    }

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero,
                                    collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(ProductCellView.classForCoder(),
                      forCellWithReuseIdentifier: ProductCellView.ident)
        view.refreshControl = refreshControl
        return view
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(refresh),
                                 for: .valueChanged)
        return refreshControl
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        UIActivityIndicatorView(style: .large)
    }()

    // MARK: - Construction

    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        setupContents()
        activityIndicator.startAnimating()

        productsPublisher = viewModel.productsPublisher
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func setupContents() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - Refresh control handler

    @objc private func refresh(_ sender: Any) {
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
}

// MARK: - UICollectionViewDataSource

extension ProductListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.products.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let product = viewModel.products[safe: indexPath.row],
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCellView.ident,
                                                            for: indexPath) as? ProductCellView
            else { return UICollectionViewCell() }

        let cellViewModel = viewModel.cellViewModel(forProduct: product)
        cell.configure(usingViewModel: cellViewModel)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let product = viewModel.products[safe: indexPath.row]
            else { return }
        viewModel.selected(product: product)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProductListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = gridSpacing
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
}
