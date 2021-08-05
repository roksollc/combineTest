//
//  ProductDataProviderTests.swift
//  HarryPotterProductsTests
//

import XCTest
import Mocker
import Combine
@testable import HarryPotterProducts

class ProductDataProviderTests: XCTestCase {
    private var session: URLSession!
    private var dataProvider: ProductDataProvider!
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
    }

    override func tearDown() {
        disposables.forEach { $0.cancel() }
        disposables.removeAll()
    }

    func testLoadProducts() {
        let expect = expectation(description: "request")
        var products: Products?
        var error: Error?

        dataProvider.$products.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let receivedError):
                error = receivedError
            }
            expect.fulfill()
        }, receiveValue: { value in
            if value.count > 0 {
                products = value
                expect.fulfill()
            }
        }).store(in: &disposables)

        dataProvider.loadProducts()
        waitForExpectations(timeout: 1)

        XCTAssertNil(error)
        XCTAssertNotNil(products)
        XCTAssert(products?.count ?? 0 > 0)
    }
}
