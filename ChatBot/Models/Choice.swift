//
//  Choice.swift
//  ChatBot
//
//  Created by 노유빈 on 2023/05/09.
//

struct Choice: Decodable {
    let index: Int
    let message: Message
    let finishReason: String

    enum CodingKeys: String, CodingKey {
        case index
        case message
        case finishReason = "finish_reason"
    }
}
