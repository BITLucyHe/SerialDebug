//
//  ChatView.swift
//  SerialDebug
//
//  Created by 何秋洋 on 2025/7/6.
//

import SwiftUI

struct ChatView: View {
    @Binding var messages: [ChatMessage]
    @Binding var messageText: String
    let isConnected: Bool
    @State private var hexMode = false
    @State private var autoScroll = true
    
    var body: some View {
        VStack(spacing: 0) {
            // 消息列表
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messages) { message in
                            MessageBubble(message: message, hexMode: hexMode)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) {
                    if autoScroll && !messages.isEmpty {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // 底部工具栏和输入区域
            HStack(spacing: 12) {
                // 工具按钮组
                HStack(spacing: 8) {
                    Menu {
                        Toggle("HEX显示", isOn: $hexMode)
                        Toggle("自动滚动", isOn: $autoScroll)
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(.body, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
                    .menuStyle(.button)
                    .buttonStyle(.plain)
                    .help("设置")
                    
                    Button(action: {
                        messages.removeAll()
                    }) {
                        Image(systemName: "trash")
                            .font(.system(.body, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
                    .buttonStyle(.plain)
                    .help("清空消息")
                }
                
                // 输入框
                HStack(spacing: 8) {
                    TextField("输入命令", text: $messageText)
                        .textFieldStyle(.plain)
                        .font(.system(.body, design: .monospaced))
                        .onSubmit {
                            sendMessage()
                        }
                    
                    if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button(action: {
                            sendMessage()
                        }) {
                            Image(systemName: "arrow.up")
                                .font(.system(.caption, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                                .background(isConnected ? Color.blue : Color.gray)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .disabled(!isConnected)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
            }
            .padding()
            .animation(.easeInOut(duration: 0.2), value: messageText.isEmpty)
        }
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty && isConnected else { return }
        
        let newMessage = ChatMessage(content: trimmedText, isReceived: false, timestamp: Date())
        messages.append(newMessage)
        messageText = ""
        
        // 模拟接收响应
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let response = ChatMessage(content: "OK", isReceived: true, timestamp: Date())
            messages.append(response)
        }
    }
} 