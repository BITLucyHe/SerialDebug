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
    @Binding var lineEndingType: LineEndingType
    let onSendMessage: (String) -> Void
    @State private var hexMode = false
    @State private var autoScroll = true
    @State private var showingClearAlert = false
    
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
                .onChange(of: messages) { _, _ in
                    // 当消息数组发生变化时，自动滚动到底部
                    if autoScroll && !messages.isEmpty {
                        // 添加小延迟确保视图已经更新
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .onAppear {
                    // 初始加载时滚动到底部
                    if autoScroll && !messages.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                        
                        Divider()
                        
                        Picker("回车符设置", selection: $lineEndingType) {
                            ForEach(LineEndingType.allCases) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
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
                        showingClearAlert = true
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
                    .disabled(messages.isEmpty)
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
        .alert("确认清空", isPresented: $showingClearAlert) {
            Button("取消", role: .cancel) { }
            Button("确定", role: .destructive) {
                messages.removeAll()
            }
        } message: {
            Text("确定要清空所有消息吗？此操作不可撤销。")
        }
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty && isConnected else { return }
        
        onSendMessage(trimmedText)
        messageText = ""
    }
} 