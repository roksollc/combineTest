//
//  ProductListViewModelTests.swift
//  HarryPotterProductsTests
//

import XCTest
import Mocker
import Combine
@testable import HarryPotterProducts

class ProductListViewModelTests: XCTestCase {
    private var session: URLSession!
    private var dataProvider: ProductDataProvider!
    private var viewModel: ProductListViewModel!
    private var disposables: [AnyCancellable] = []

    final private class MockedData {
        private static let validImage = UIImage(systemName: "moon")!
        static let newImageData: Data = validImage.pngData()!
    }

    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        session = URLSession(configuration: configuration)

        dataProvider = ProductDataProvider(session: session, imageCache: nil)
        viewModel = ProductListViewModel(dataProvider: dataProvider)
    }

    override func tearDown() {
        disposables.forEach { $0.cancel() }
        disposables.removeAll()
    }

    func testLoadProducts_productsUpdated() {
        let expect = expectation(description: "request")
        var error: Error?

        viewModel.$updatedProducts.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let receivedError):
                error = receivedError
            }
            expect.fulfill()
        }, receiveValue: {
            if $0, self.dataProvider.products.count > 0 {
                expect.fulfill()
            }
        }).store(in: &disposables)

        viewModel.loadProducts()
        waitForExpectations(timeout: 1)

        XCTAssertNil(error)
        XCTAssert(dataProvider.products.count > 0)
        XCTAssert(viewModel.products.count > 0)
        XCTAssertEqual(viewModel.products, dataProvider.products)
    }
}
