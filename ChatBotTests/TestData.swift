//
//  TestData.swift
//  ChatBotTests
//
//  Created by 노유빈 on 2023/05/09.
//

import Foundation

let sampleChatJSON: Data = """
    {
        "id": "chatcmpl-7EElHlW2o9lYjRPBhXeYkeK3zxcJG",
        "object": "chat.completion",
        "created": 1683627691,
        "model": "gpt-3.5-turbo-0301",
        "usage": {
            "prompt_tokens": 10,
            "completion_tokens": 10,
            "total_tokens": 20
        },
        "choices": [
            {
                "message": {
                    "role": "assistant",
                    "content": "Hello there! How may I assist you today?"
                },
                "finish_reason": "stop",
                "index": 0
            }
        ]
    }
    """.data(using: .utf8)!
