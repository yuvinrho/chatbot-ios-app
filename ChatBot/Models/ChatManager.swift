import Foundation

struct ChatManager: Networkable {
    private let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func sendMessage(_ message: String, completion: @escaping (Result<String, Error>) -> Void) {
        let body = ChatRequestDTO(messages: [Message(role: "user", content: message)])

        request(url: OpenAIAPI.chat.url,
                session: session,
                method: OpenAIAPI.chat.method,
                headers: OpenAIAPI.chat.headers,
                body: body) { (result: Result<ChatResponseDTO, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.choices[0].message.content))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
