//
//  ChatMessage.swift
//  SerialDebug
//
//  Created by 何秋洋 on 2025/7/6.
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isReceived: Bool
    let timestamp: Date
} 