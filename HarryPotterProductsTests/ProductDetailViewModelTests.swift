//
//  ProductDetailViewModelTests.swift
//  HarryPotterProductsTests
//
import XCTest
import Mocker
import Combine
@testable import HarryPotterProducts

class ProductDetailViewModelTests: XCTestCase {
    private var session: URLSession!
    private var dataProvider: ProductDataProvider!
    private var imageFetcher: ImageFetcher!
    private var testImage: UIImage!
    private var viewModel: ProductDetailViewModel!
    private var product: Product!
    private var disposables: [AnyCancellable] = []

    private final class MockedData {
        private static let validImage = UIImage(systemName: "moon")!
        static let newImageData: Data = validImage.pngData()!
    }

    private var productTitle = "Title"
    private var productAuthor = "Author"
    private var productImageUrl = "http://www.apple.com"

    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        session = URLSession(configuration: configuration)

        imageFetcher = ImageFetcher(session: session)
        dataProvider = ProductDataProvider(session: session,
                                           imageCache: nil)
        product = Product()
        product.title = productTitle
        product.author = productAuthor
        product.imageURL = productImageUrl
        viewModel = ProductDetailViewModel(product: product,
                                           session: session)
    }

    override func tearDown() {
        disposables.forEach { $0.cancel() }
        disposables.removeAll()
    }

    func testProductDetails() {
        XCTAssertEqual(product.title, productTitle)
        XCTAssertEqual(product.author, productAuthor)
        XCTAssertEqual(product.imageURL, productImageUrl)
        XCTAssertEqual(product, viewModel.product)
        XCTAssertEqual(viewModel.productHasImage, true)
        XCTAssertEqual(product.isFavorite, false)
        XCTAssertEqual(product.isFavorite, viewModel.productIsFavorite)

        product.imageURL = nil
        XCTAssertNil(product.imageURL)
        XCTAssertNil(viewModel.product.imageURL)
        XCTAssertEqual(viewModel.productHasImage, false)

        product.isFavorite = true
        XCTAssertEqual(product.isFavorite, true)
        XCTAssertEqual(product.isFavorite, viewModel.productIsFavorite)
    }

    func testToggleProductAsFavorite() {
        XCTAssertEqual(product.isFavorite, false)
        XCTAssertEqual(product.isFavorite, viewModel.productIsFavorite)

        viewModel.toggleProductAsFavorite()
        XCTAssertEqual(product.isFavorite, true)
        XCTAssertEqual(product.isFavorite, viewModel.productIsFavorite)
    }

    func testFetchProductImage_andPublisher() {
        let url = URL(string: productImageUrl)!
        let mock = Mock(url: url, dataType: .imagePNG, statusCode: 200, data: [
            .get: MockedData.newImageData
        ])
        mock.register()

        var error: Error?
        var image: UIImage?
        let expect = expectation(description: "request")

        viewModel.productImagePublisher.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let receivedError):
                error = receivedError
            }
            expect.fulfill()
        }, receiveValue: { value in
            if let value = value {
                image = value
                expect.fulfill()
            }
        }).store(in: &disposables)

        viewModel.fetchProductImage()

        waitForExpectations(timeout: 1)

        XCTAssertNil(error)
        XCTAssertNotNil(image)
    }
}
