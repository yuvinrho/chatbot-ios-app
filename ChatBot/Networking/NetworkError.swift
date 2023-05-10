//
//  NetworkError.swift
//  ChatBot
//
//  Created by 노유빈 on 2023/05/09.
//

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
            return "유효하지 않은 URL입니다."
        case .invalidResponse:
            return "유효하지 않은 응답입니다."
        case .unknown:
            return "알 수 없는 에러입니다."
        case .requestFailed(let statusCode):
            return "HTTP요청 실패. 에러코드: \(statusCode)"
        case .invalidRequest:
            return "유효하지 않은 요청입니다."
        }
    }
}
