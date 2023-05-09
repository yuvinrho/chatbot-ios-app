//
//  RequestBody.swift
//  ChatBot
//
//  Created by 노유빈 on 2023/05/10.
//

struct RequestBody: Encodable {
    let model: String
    let messages: [Message]

    init(model: String = "gpt-3.5-turbo", messages: [Message]) {
        self.model = model
        self.messages = messages
    }
}
