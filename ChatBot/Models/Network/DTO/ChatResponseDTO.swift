//
//  ChatDTO.swift
//  ChatBot
//
//  Created by 노유빈 on 2023/05/09.
//

import Foundation

struct ChatResponseDTO: Decodable {
    let id: String
    let object: String
    let created: Date
    let choices: [Choice]
    let usage: Usage

    enum CodingKeys: CodingKey {
        case id
        case object
        case created
        case choices
        case usage
    }
}
