//
//  NetworkManager.swift
//  ChatBot
//
//  Created by 노유빈 on 2023/05/09.
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

struct NetworkManager {
    private let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    private func createRequest(with message: String) -> URLRequest? {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "post"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let parameters = RequestBody(messages: [Message(role: "user", content: "\(message)")])
        guard let encodedData = try? JSONEncoder().encode(parameters) else {
            return nil
        }

        request.httpBody = encodedData

        return request
    }

    func sendMessage(_ message: String, completion: @escaping (Result<Message, Error>) -> Void) {
        guard let request = createRequest(with: message) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.requestFailed(statusCode: httpResponse.statusCode)))
                return
            }

            guard let data,
                  let messageResponse = try? JSONDecoder().decode(ChatDTO.self, from: data) else {
                completion(.failure(NetworkError.decodeFailed))
                return
            }

            completion(.success(messageResponse.choices[0].message))
        }

        task.resume()
    }
}
