//
//  NetworkManager.swift
//  ChatBot
//
//  Created by 노유빈 on 2023/05/09.
//

import Foundation

struct NetworkManager {
    private let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func request<T: Decodable>(url: String,
                               method: HTTPMethod,
                               headers: [String: String]?,
                               body: Encodable?,
                               completion: @escaping (Result<T, Error>) -> Void) {

        guard let url = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData
            } catch {
                completion(.failure(error))
            }
        }

        if let headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        let task = session.dataTask(with: request) { data, response, error in
            if let error {
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

            guard let data else {
                completion(.failure(NetworkError.unknown))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
