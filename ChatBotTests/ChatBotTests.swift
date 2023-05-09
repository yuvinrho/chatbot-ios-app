//
//  ChatBotTests.swift
//  ChatBotTests
//
//  Created by 노유빈 on 2023/05/09.
//

import XCTest
@testable import ChatBot

final class ChatBotTests: XCTestCase {

    func test_sampleChatJSON을_ChatDTO로_디코딩한_데이터가_주어진_값과_같아야한다() throws {
        let decoder = JSONDecoder()
        let chat = try decoder.decode(ChatDTO.self, from: sampleChatJSON)

        XCTAssertEqual(chat.choices[0].message.content, "Hello there! How may I assist you today?")
    }
}
