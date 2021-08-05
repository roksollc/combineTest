//
//  ProductTests.swift
//  HarryPotterProductsTests
//

import XCTest
@testable import HarryPotterProducts

class ProductTests: XCTestCase {
    override func setUp() {}
    override func tearDown() {}

    func testDecode() {
        let decoder = JSONDecoder()

        // test product with all traits
        guard let dataComplete = completeProductJsonString.data(using: .utf8)
            else { return XCTFail("invalid complete data") }
        let productComplete = try? decoder.decode(Product.self, from: dataComplete)
        XCTAssertNotNil(productComplete)
        XCTAssertEqual(productComplete?.title, productTitle)
        XCTAssertEqual(productComplete?.author, productAuthor)
        XCTAssertEqual(productComplete?.imageURL, productImageUrl)

        // test product with only title
        guard let dataIncomplete = incompleteProductJsonString.data(using: .utf8)
            else { return XCTFail("invalid incomplete data") }
        let productIncomplete = try? decoder.decode(Product.self, from: dataIncomplete)
        XCTAssertNotNil(productIncomplete)
        XCTAssertEqual(productIncomplete?.title, productTitle)
        XCTAssertNil(productIncomplete?.author)
        XCTAssertNil(productIncomplete?.imageURL)

        // test multiple products
        // additionally tests `Equatable`
        guard let dataAll = multipleProductsJsonString.data(using: .utf8)
            else { return XCTFail("invalid combined data") }
        let products = try? decoder.decode(Products.self, from: dataAll)
        XCTAssertNotNil(products)
        XCTAssertEqual(products?.count, 2)
        let product1 = products?.first
        XCTAssertEqual(product1, productComplete)
        XCTAssertEqual(product1?.title, productTitle)
        XCTAssertEqual(product1?.author, productAuthor)
        XCTAssertEqual(product1?.imageURL, productImageUrl)
        let product2 = products?.last
        XCTAssertEqual(product2, productIncomplete)
        XCTAssertEqual(product2?.title, productTitle)
        XCTAssertNil(product2?.author)
        XCTAssertNil(product2?.imageURL)
    }

    func testProductImageUrl() {
        // productImageUrl with no imageUrl is nil
        let product = Product()
        product.title = "Title"
        product.author = "Author"
        XCTAssertNil(product.productImageUrl)

        // with valid imageUrl is notNil
        product.imageURL = productImageUrl
        XCTAssertNotNil(product.productImageUrl)
        XCTAssertEqual(productImageUrl, product.productImageUrl?.absoluteString)

        // with invalid imageUrl is nil
        product.imageURL = "not a url"
        XCTAssertNil(product.productImageUrl)
    }

    private var productTitle = "Title"
    private var productAuthor = "Author"
    private var productImageUrl = "http://www.apple.com"

    private var completeProductJsonString: String {
        """
        {
          "title" : "\(productTitle)",
          "author" : "\(productAuthor)",
          "imageURL" : "\(productImageUrl)"
        }
        """
    }
    private var incompleteProductJsonString: String {
        """
        {
          "title" : "\(productTitle)",
        }
        """
    }
    private var multipleProductsJsonString: String {
        """
        [\(completeProductJsonString),
        \(incompleteProductJsonString)]
        """
    }
}
