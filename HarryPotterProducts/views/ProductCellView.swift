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

    private let cornerRadius: CGFloat = 5
    private let inset: CGFloat = 8
    private let fontName = "AvenirNext-DemiBold"
    private let fontSize: CGFloat = 12
    private let textColor = UIColor(named: "textColor")

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 5
        return stackView
    }()

    private lazy var preferredLabelMaxLayoutWidth: CGFloat = {
        UIScreen.main.bounds.width / 3
    }()

    private lazy var favoriteImage: UIImage? = {
        UIImage(systemName: "star.fill")
    }()
    private lazy var nonfavoriteImage: UIImage? = {
        UIImage(systemName: "star")
    }()

    private lazy var favoriteImageView: UIImageView = {
        UIImageView(image: nonfavoriteImage)
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
        clearStackView()

        titleLabel.text = nil
        authorLabel.text = nil
        imageView.image = nil
        viewModel = nil
    }

    private func setupContents() {
        backgroundColor = .lightGray
        layer.cornerRadius = cornerRadius

        contentView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                        .inset(inset)
        }
    }

    func configure(usingViewModel viewModel: ProductInfo) {
        self.viewModel = viewModel

        // title on top
        titleLabel.text = viewModel.product.title
        stackView.addArrangedSubview(titleLabel)

        // then author if present
        if let productAuthor = viewModel.product.author {
            authorLabel.text = "Author: \(productAuthor)"
            stackView.addArrangedSubview(authorLabel)
        }

        // then favorite/non-favorite image
        stackView.addArrangedSubview(favoriteImageView)
        // watch for changes to the published favorite
        favoritePublisher = viewModel.productFavoritePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureFavoriteImage()
            }

        // then image if present
        if viewModel.productHasImage {
            stackView.addArrangedSubview(imageView)

            if let productImage = viewModel.product.image {
                imageView.image = productImage
                constrainProductImage()
            }
            else {
                loadProductImage()
            }
        }

        stackView.sizeToFit()
        invalidateIntrinsicContentSize()
        // TODO: This does not yield a redraw in the collection view
        // Tried a notification to the collection view
        // but it forced it to upset the scroll position and lagged it eventually
        // -> Check constraints.
    }

    private func configureFavoriteImage() {
        if viewModel?.productIsFavorite ?? false {
            favoriteImageView.image = favoriteImage
        }
        else {
            favoriteImageView.image = nonfavoriteImage
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

    private func clearStackView() {
        for arrangedSubview in stackView.arrangedSubviews {
            arrangedSubview.removeFromSuperview()
        }
    }

    // MARK: Image view constraints

    private func constrainProductImage() {
        guard let imageSize = imageView.image?.size,
              imageSize.width > 0
            else { return }

        let aspectRatio = imageSize.height / imageSize.width
        let imageWidth = min(self.preferredLabelMaxLayoutWidth,
                             imageSize.width)
        let imageHeight = imageWidth * aspectRatio
        self.imageView.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(imageWidth)
            make.height.lessThanOrEqualTo(imageHeight)
        }
    }
}
