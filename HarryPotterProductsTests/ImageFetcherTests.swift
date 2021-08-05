//
//  ImageFetcherTests.swift
//  HarryPotterProductsTests
//

import XCTest
import Mocker
import Combine
@testable import HarryPotterProducts

class ImageFetcherTests: XCTestCase {
    private var session: URLSession!
    private var imageCache: InMemoryImageCache!
    private var imageFetcher: ImageFetcher!
    private var testImage: UIImage!
    private var disposables: [AnyCancellable] = []

    final private class MockedData {
        private static let validImage = UIImage(systemName: "moon")!
        static let newImageData: Data = validImage.pngData()!
    }

    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        session = URLSession(configuration: configuration)

        imageCache = InMemoryImageCache()
        imageFetcher = ImageFetcher(session: session, cache: imageCache)
    }

    override func tearDown() {
        imageCache.clear()
        disposables.forEach { $0.cancel() }
        disposables.removeAll()
    }

    func testTemporaryImageCache() {
        // should be empty intially
        let urlImage = URL(string: "http://www.apple.com")!
        XCTAssertNil(imageCache[urlImage])

        // after adding mock image, cache should now return image
        let mockImage = UIImage(data: MockedData.newImageData)
        mockImage.map { imageCache[urlImage] = $0 }
        XCTAssertNotNil(imageCache[urlImage])

        // setting to nil should remove
        imageCache[urlImage] = nil
        XCTAssertNil(imageCache[urlImage])

        // clearing should remove as well
        mockImage.map { imageCache[urlImage] = $0 }
        XCTAssertNotNil(imageCache[urlImage])
        imageCache.clear()
        XCTAssertNil(imageCache[urlImage])
    }

    func testFetchValidImage() {
        let url = URL(string: "http://www.google.com")!
        let mock = Mock(url: url, dataType: .imagePNG, statusCode: 200, data: [
            .get: MockedData.newImageData
        ])
        mock.register()

        var error: Error?
        var image: UIImage?
        let expect = expectation(description: "request")

        imageFetcher.$image.sink(receiveCompletion: { completion in
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

        imageFetcher.fetchImage(forUrl: url)

        waitForExpectations(timeout: 1)

        XCTAssertNil(error)
        XCTAssertNotNil(image)
    }

    func testFetchInvalidImage() {
        let url = URL(string: "http://www.google.com")!
        let mock = Mock(url: url, dataType: .imagePNG, statusCode: 200, data: [
            .get: Data() // -> invalid image
        ])
        mock.register()

        var error: Error?
        var image: UIImage?
        let expect = expectation(description: "request")
        var receivedInitial = false

        imageFetcher.$image.sink(receiveCompletion: { completion in
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
            }
            // gets called twice, once for initial value
            if receivedInitial {
                expect.fulfill()
            }
            else {
                receivedInitial = true
            }
        }).store(in: &disposables)

        imageFetcher.fetchImage(forUrl: url)

        waitForExpectations(timeout: 1)

        XCTAssertNil(error)
        XCTAssertNil(image)
    }

    func testFetchImageFromCache() {
        let url = URL(string: "http://www.google.com")!

        // no mock data - set in cache
        let mockImage = UIImage(data: MockedData.newImageData)
        mockImage.map { imageCache[url] = $0 }

        var error: Error?
        var image: UIImage?
        let expect = expectation(description: "request")

        imageFetcher.$image.sink(receiveCompletion: { completion in
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

        imageFetcher.fetchImage(forUrl: url)

        waitForExpectations(timeout: 1)

        XCTAssertNil(error)
        XCTAssertNotNil(image)
    }
}
