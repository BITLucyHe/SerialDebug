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
                VStack(alignment: message.isReceived ? .leading : .trailing, spacing: 2) {
                    Text(displayContent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(message.isReceived ? Color.gray.opacity(0.2) : Color.blue)
                        .foregroundColor(message.isReceived ? .primary : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                    
                    // 如果是十六进制模式，同时显示原始文本（如果可读）
                    if hexMode && !message.content.hasPrefix("HEX:") {
                        Text(message.content)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                }
                
                HStack(spacing: 4) {
                    Text(message.timestamp, formatter: timeFormatter)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // 显示字节数（如果是十六进制数据）
                    if message.content.hasPrefix("HEX:") {
                        let hexData = message.content.replacingOccurrences(of: "HEX: ", with: "")
                        let byteCount = hexData.split(separator: " ").count
                        Text("(\(byteCount) bytes)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: 300, alignment: message.isReceived ? .leading : .trailing)
            
            if message.isReceived {
                Spacer()
            }
        }
        .contextMenu {
            Button("复制") {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(displayContent, forType: .string)
            }
            
            if hexMode {
                Button("复制原始文本") {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(message.content, forType: .string)
                }
            }
            
            Button("复制时间戳") {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(timeFormatter.string(from: message.timestamp), forType: .string)
            }
        }
    }
    
    private var displayContent: String {
        if hexMode && !message.content.hasPrefix("HEX:") {
            // 将普通文本转换为十六进制显示
            return message.content.data(using: String.Encoding.utf8)?.map { String(format: "%02X", $0) }.joined(separator: " ") ?? message.content
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