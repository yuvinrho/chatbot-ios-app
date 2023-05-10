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
        let chat = try decoder.decode(ChatResponseDTO.self, from: sampleChatJSON)

        XCTAssertEqual(chat.choices[0].message.content, "Hello there! How may I assist you today?")
    }

    func test_gpt한테_메시지를_보내면_응답이_nil이_아니어야한다() throws {
        let expectation = XCTestExpectation()

        let body = ChatRequestDTO(messages: [Message(role: "user", content: "HI, GPT")])

        networkManager.request(url: OpenAIAPI.chat.url,
                               method: OpenAIAPI.chat.method,
                               headers: OpenAIAPI.chat.headers,
                               body: body) { (result: Result<ChatResponseDTO, Error>) in
            switch result {
            case .success(let responseMessage):
                print(responseMessage.choices[0].message.content)
                XCTAssertNotNil(responseMessage)
            case .failure(_):
                XCTFail()
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }
}
