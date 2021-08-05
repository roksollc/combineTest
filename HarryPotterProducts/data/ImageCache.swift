//
//  ImageCache.swift
//  HarryPotterProducts
//

import UIKit

// protocol of an image cache
protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
    func clear()
}

// implementation of an in-memory image cache
struct InMemoryImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()

    subscript(_ key: URL) -> UIImage? {
        get {
            cache.object(forKey: key as NSURL)
        }
        set {
            newValue == nil ?
                cache.removeObject(forKey: key as NSURL) :
                cache.setObject(newValue!, forKey: key as NSURL)
        }
    }

    func clear() {
        cache.removeAllObjects()
    }
}
