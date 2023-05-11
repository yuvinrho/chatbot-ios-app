import Foundation

enum OpenAIAPI {
    case chat

    static let baseURL = "https://api.openai.com/v1"

    var path: String {
        switch self {
        case .chat:
            return "/chat/completions"
        }
    }

    var url: String {
        switch self {
        case .chat:
            return "\(Self.baseURL)\(self.path)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .chat:
            return .post
        }
    }

    var headers: [String: String] {
        switch self {
        case .chat:
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(YOUR API KEY)"
            ]
        }
    }
}
