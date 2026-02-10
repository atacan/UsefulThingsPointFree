import Foundation

public enum FetchAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingError

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid Response"
        case .invalidData:
            return "Invalid Data"
        case .decodingError:
            return "Decoding Error"
        }
    }
}

public func fetch<D: Decodable>(url: URL, decoding type: D.Type) async throws -> D {
    // guard let url = URL(string: "Your url") else {
    //     throw APIError.invalidURL
    // }
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw FetchAPIError.invalidResponse
    }
    do {
        let decorder = JSONDecoder()
        let movies = try decorder.decode(D.self, from: data)
        return movies
    } catch {
        throw FetchAPIError.invalidData
    }
}
