//
//  OpenAIAPI.swift
//  ChatBot
//
//  Created by 노유빈 on 2023/05/10.
//

import Foundation

private var apiKey: String {
    get {
        guard let filePath = Bundle.main.path(forResource: "APIKey", ofType: "plist") else {
            fatalError("Couldn't find file 'APIKey.plist'.")
        }

        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API Key") as? String else {
            fatalError("Couldn't find key 'API Key' in 'APIKey.plist'.")
        }

        return value
    }
}

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
                "Authorization": "Bearer \(apiKey)"
            ]
        }
    }
}
