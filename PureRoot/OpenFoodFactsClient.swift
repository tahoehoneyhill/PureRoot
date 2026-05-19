//
//  OpenFoodFactsClient.swift
//  PureRoot
//

import Foundation

struct OpenFoodFactsProduct: Codable {
    let product_name: String?
    let brands: String?
    let ingredients_text: String?
    let nova_group: Int?
    let additives_tags: [String]?
    let image_front_url: String?
    let image_url: String?

    var displayName: String { product_name ?? "Unknown product" }
    var brandName: String? { brands?.split(separator: ",").first.map { String($0).trimmingCharacters(in: .whitespaces) } }
    var imageURL: URL? {
        if let s = image_front_url, let u = URL(string: s) { return u }
        if let s = image_url, let u = URL(string: s) { return u }
        return nil
    }

    var novaDescription: String? {
        switch nova_group {
        case 1: return "Unprocessed / minimally processed"
        case 2: return "Processed culinary ingredients"
        case 3: return "Processed foods"
        case 4: return "Ultra-processed (avoid)"
        default: return nil
        }
    }
}

struct OpenFoodFactsResponse: Codable {
    let code: String?
    let status: Int?
    let product: OpenFoodFactsProduct?
}

enum OpenFoodFactsClient {
    enum FetchError: LocalizedError {
        case notFound
        case noIngredients
        case http(Int)
        case decoding(String)

        var errorDescription: String? {
            switch self {
            case .notFound: return "Product not found in Open Food Facts database."
            case .noIngredients: return "Product found, but it has no ingredient list in the database."
            case .http(let code): return "Lookup failed (HTTP \(code))."
            case .decoding(let s): return "Could not read product data: \(s)"
            }
        }
    }

    static func fetch(barcode: String) async throws -> OpenFoodFactsProduct {
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json"
        guard let url = URL(string: urlString) else { throw FetchError.notFound }

        var request = URLRequest(url: url)
        request.setValue("PureRoot/1.0 (iOS app, contact@pureroot.app)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw FetchError.http(0) }
        guard (200..<300).contains(http.statusCode) else { throw FetchError.http(http.statusCode) }

        do {
            let decoded = try JSONDecoder().decode(OpenFoodFactsResponse.self, from: data)
            guard decoded.status == 1, let product = decoded.product else {
                throw FetchError.notFound
            }
            return product
        } catch let err as FetchError {
            throw err
        } catch {
            throw FetchError.decoding(error.localizedDescription)
        }
    }
}
