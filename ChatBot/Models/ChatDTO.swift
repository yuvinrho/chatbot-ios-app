//
//  ChatDTO.swift
//  ChatBot
//
//  Created by 노유빈 on 2023/05/09.
//

struct ChatDTO: Decodable {
    let id: String
    let object: String
    let created: Int
    let choices: [Choice]
    let usage: Usage
}
