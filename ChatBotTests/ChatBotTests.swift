//
//  ChatBotTests.swift
//  ChatBotTests
//
//  Created by 노유빈 on 2023/05/09.
//

import XCTest
@testable import ChatBot

final class ChatBotTests: XCTestCase {
    let networkManager = NetworkManager()

    func test_sampleChatJSON을_ChatDTO로_디코딩한_데이터가_주어진_값과_같아야한다() throws {
        let decoder = JSONDecoder()
        let chat = try decoder.decode(ChatDTO.self, from: sampleChatJSON)

        XCTAssertEqual(chat.choices[0].message.content, "Hello there! How may I assist you today?")
    }

    func test_gpt한테_메시지를_보내면_응답이_nil이_아니어야한다() throws {
        let expectation = XCTestExpectation()

        networkManager.sendMessage("Hi, GPT") { result in
            switch result {
            case .success(let responseMessage):
                XCTAssertNotNil(responseMessage)
            case .failure:
                XCTFail()
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }
}
