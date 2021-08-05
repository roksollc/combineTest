//
//  ProductDetailView.swift
//  HarryPotterProducts
//

import UIKit
import SnapKit
import Combine

// view for product details
final class ProductDetailView: UIView {
    private let viewModel: ProductInfo
    private var imagePublisher: AnyCancellable?

    private let spacing: CGFloat = 8
    private let fontName = "AvenirNext-DemiBold"
    private let fontSize: CGFloat = 12
    private let textColor = UIColor(named: "textColor")

    private lazy var favoriteImage: UIImage? = {
        UIImage(systemName: "star.fill")
    }()
    private lazy var nonfavoriteImage: UIImage? = {
        UIImage(systemName: "star")
    }()

    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self,
                         action: #selector(tappedFavorite(_:)),
                         for: .touchUpInside)
        return button
    }()

    private lazy var preferredLabelMaxLayoutWidth: CGFloat = {
        UIScreen.main.bounds.width * 0.8
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = preferredLabelMaxLayoutWidth
        label.font = UIFont(name: fontName, size: fontSize)?.semibolded
        label.textColor = textColor
        return label
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = preferredLabelMaxLayoutWidth
        label.font = UIFont(name: fontName, size: fontSize)?.italicized
        label.textColor = textColor
        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .yellow
        return imageView
    }()

    // MARK: - Construction

    init(viewModel: ProductInfo) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupContents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func setupContents() {
        backgroundColor = .lightGray

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left
                .right
                .top.equalToSuperview()
                        .inset(spacing)
        }

        addSubview(authorLabel)
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
                .offset(spacing)
            make.left.right.equalTo(titleLabel)
        }

        addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom)
                        .offset(spacing)
            make.left.equalTo(authorLabel)
        }

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(favoriteButton.snp.bottom)
                    .offset(spacing)
        }

        configure(usingProduct: viewModel.product)
    }

    private func configure(usingProduct product: Product) {
        titleLabel.text = viewModel.product.title

        if let productAuthor = viewModel.product.author {
            authorLabel.text = "Author: \(productAuthor)"
        }
        else {
            authorLabel.text = "Author: N/A"
        }

        if let productImage = viewModel.product.image {
            imageView.image = productImage
        }
        else {
            loadProductImage()
        }
        configureFavoriteButton()
    }

    private func configureFavoriteButton() {
        if viewModel.productIsFavorite {
            favoriteButton.setImage(favoriteImage, for: .normal)
        }
        else {
            favoriteButton.setImage(nonfavoriteImage, for: .normal)
        }
    }

    private func loadProductImage() {
        // watch for changes to the published image of view model
        imagePublisher = viewModel.productImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.imageView.image = image
            }

        viewModel.fetchProductImage()
    }

    // MARK: - Favorite button handler

    @objc
    private func tappedFavorite(_ sender: Any) {
        viewModel.toggleProductAsFavorite()
        configureFavoriteButton()
    }
}
