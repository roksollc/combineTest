//
//  ProductCellVoew.swift
//  HarryPotterProducts
//

import UIKit
import SnapKit
import Combine

// collection cell view for product details - part of product list view
final class ProductCellView: UICollectionViewCell {
    static let ident = "productCell"

    private var viewModel: ProductInfo?
    private var imagePublisher: AnyCancellable?
    private var favoritePublisher: AnyCancellable?

    private let spacing: CGFloat = 8
    private let cornerRadius: CGFloat = 5
    private let fontName = "AvenirNext-DemiBold"
    private let fontSize: CGFloat = 12
    private let textColor = UIColor(named: "textColor")

    private lazy var preferredLabelMaxLayoutWidth: CGFloat = {
        UIScreen.main.bounds.width / 3
    }()

    private lazy var maxImageWidth: CGFloat = {
        titleLabel.intrinsicContentSize.width * 0.8
    }()

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
        return imageView
    }()

    // MARK: - Construction

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    override func prepareForReuse() {
        super.prepareForReuse()

        imagePublisher?.cancel()
        favoritePublisher?.cancel()

        titleLabel.text = nil
        authorLabel.text = nil
        imageView.image = nil
        viewModel = nil
    }

    private func setupContents() {
        backgroundColor = .lightGray
        layer.cornerRadius = cornerRadius

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
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
                    .inset(spacing)
        }
    }

    func configure(usingViewModel viewModel: ProductInfo) {
        self.viewModel = viewModel

        // watch for changes to the published favorite
        favoritePublisher = viewModel.productFavoritePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureFavoriteButton()
            }

        titleLabel.text = viewModel.product.title
        authorLabel.text = viewModel.product.author

        if viewModel.productHasImage {
            if let productImage = viewModel.product.image {
                imageView.image = productImage
                constrainProductImage()
            }
            else {
                loadProductImage()
            }
        }

        invalidateIntrinsicContentSize()
    }

    private func configureFavoriteButton() {
        if viewModel?.productIsFavorite ?? false {
            favoriteButton.setImage(favoriteImage, for: .normal)
        }
        else {
            favoriteButton.setImage(nonfavoriteImage, for: .normal)
        }
    }

    private func loadProductImage() {
        guard let viewModel = viewModel else { return }

        // watch for changes to the published image of view model
        imagePublisher = viewModel.productImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.imageView.image = image

                guard let self = self,
                      let imageSize = image?.size,
                      imageSize.width > 0
                    else { return }

                self.constrainProductImage()
                self.invalidateIntrinsicContentSize()
            }

        viewModel.fetchProductImage()
    }

    // MARK: Image view constraints

    private func constrainProductImage() {
        guard let imageSize = imageView.image?.size,
              imageSize.width > 0
            else { return }

        let aspectRatio = imageSize.height / imageSize.width
        let imageWidth = min(maxImageWidth, imageSize.width)
        let imageHeight = imageWidth * aspectRatio
        self.imageView.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(imageWidth)
            make.height.lessThanOrEqualTo(imageHeight)
        }
    }

    // MARK: - Favorite button handler

    @objc
    private func tappedFavorite(_ sender: Any) {
        viewModel?.toggleProductAsFavorite()
        configureFavoriteButton()
    }
}
