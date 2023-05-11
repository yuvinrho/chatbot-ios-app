struct ChatRequestDTO: Encodable {
    let model: String
    let messages: [Message]

    init(model: String = "gpt-3.5-turbo", messages: [Message]) {
        self.model = model
        self.messages = messages
    }
}
