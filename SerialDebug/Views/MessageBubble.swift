//
//  MessageBubble.swift
//  SerialDebug
//
//  Created by 何秋洋 on 2025/7/6.
//

import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    let hexMode: Bool
    
    var body: some View {
        HStack {
            if !message.isReceived {
                Spacer()
            }
            
            VStack(alignment: message.isReceived ? .leading : .trailing, spacing: 4) {
                Text(displayContent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(message.isReceived ? Color.gray.opacity(0.2) : Color.blue)
                    .foregroundColor(message.isReceived ? .primary : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .font(.system(.body, design: .monospaced))
                
                Text(message.timestamp, formatter: timeFormatter)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 300, alignment: message.isReceived ? .leading : .trailing)
            
            if message.isReceived {
                Spacer()
            }
        }
    }
    
    private var displayContent: String {
        if hexMode {
            return message.content.data(using: .utf8)?.map { String(format: "%02X", $0) }.joined(separator: " ") ?? message.content
        } else {
            return message.content
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }
} 