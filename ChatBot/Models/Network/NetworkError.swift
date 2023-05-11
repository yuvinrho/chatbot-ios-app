import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case unknown
    case requestFailed(statusCode: Int)
    case invalidRequest
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL Error."
        case .invalidResponse:
            return "Invalid Response."
        case .unknown:
            return "Unknown Error."
        case .requestFailed(let statusCode):
            return "HTTP Request Failed. Error Code: \(statusCode)"
        case .invalidRequest:
            return "Invalid Request Error."
        }
    }
}
