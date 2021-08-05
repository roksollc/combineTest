//
//  Product.swift
//  HarryPotterProducts
//

import UIKit
import Combine

// the one-and-only `Product`
class Product: Codable {
    var title: String = ""
    var author: String?
    var imageURL: String?

    // added published properties for dynamic changes
    @Published var isFavorite: Bool = false
    @Published var image: UIImage?

    // introduction of UIImage requires manual encoding/decoding
    private enum CodingKeys: String, CodingKey {
        case title
        case author
        case imageURL
        case favorite
        case image
    }

    // MARK: - Construction/Encoding/Decoding

    init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        if let favorite = try container.decodeIfPresent(Bool.self, forKey: .favorite) {
            self.isFavorite = favorite
        }
        if let data = try container.decodeIfPresent(Data.self, forKey: .image) {
            image = UIImage(data: data)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        if let author = author {
            try container.encode(author, forKey: .author)
        }
        if let imageURL = imageURL {
            try container.encode(imageURL, forKey: .imageURL)
        }
        try container.encode(isFavorite, forKey: .favorite)
        if let data = image?.pngData() {
            try container.encode(data, forKey: .image)
        }
    }
}

extension Product: Equatable {
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.title == rhs.title &&
        lhs.author == rhs.author &&
        lhs.imageURL == rhs.imageURL
    }
}

typealias Products = [Product]

// convenience for product image URL
extension Product {
    var productImageUrl: URL? {
        guard let imageURL = imageURL else { return nil }
        return URL(string: imageURL)
    }
}
