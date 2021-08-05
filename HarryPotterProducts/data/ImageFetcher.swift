//
//  ImageFetcher.swift
//  HarryPotterProducts
//

import UIKit
import Combine

protocol ImageFetchable {
    func fetchImage(forUrl url: URL)
}

class ImageFetcher: ImageFetchable {
    // published: the image, if fetched successfully
    @Published var image: UIImage?

    private let session: URLSession
    private var cache: ImageCache?
    private var disposable: AnyCancellable?

    // MARK: - Construction

    // injectable URLSession and ImageCache
    init(session: URLSession, cache: ImageCache? = nil) {
        self.session = session
        self.cache = cache
    }

    // MARK: - Image fetching and caching

    // fetch image at specified url using provided session & cache
    func fetchImage(forUrl url: URL) {
        disposable?.cancel()
        disposable = nil

        if let image = cache?[url] {
            self.image = image
            return
        }

        disposable = session.dataTaskPublisher(for: url)
            .map {
                UIImage(data: $0.data)
            }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] in
                self?.cacheImage($0, forUrl: url)
            })
            .sink {
                self.image = $0
            }
    }

    // cache the provided image for provided url
    private func cacheImage(_ image: UIImage?, forUrl url: URL) {
        image.map { cache?[url] = $0 }
    }
}
