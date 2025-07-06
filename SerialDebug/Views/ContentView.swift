//
//  ContentView.swift
//  SerialDebug
//
//  Created by 何秋洋 on 2025/7/6.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var serialManager = SerialManager()
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @State private var isAutoSendEnabled = false
    @State private var autoSendInterval = "1000" // ms
    @State private var autoSendCancellable: AnyCancellable?
    
    var body: some View {
        NavigationSplitView(sidebar: {
            SidebarView(
                serialManager: serialManager,
                isAutoSendEnabled: $isAutoSendEnabled,
                autoSendInterval: $autoSendInterval
            )
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        }, detail: {
            ChatView(
                messages: $messages,
                messageText: $messageText,
                isConnected: serialManager.isConnected,
                onSendMessage: sendMessage
            )
        })
        .navigationTitle(serialManager.isConnected && serialManager.connectedPort != nil ? serialManager.connectedPort! : "串口调试工具")
        .frame(minWidth: 900, minHeight: 620)
        .onAppear {
            setupSerialManager()
        }
        .alert("连接错误", isPresented: $showingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: serialManager.connectionError) { oldValue, newValue in
            if let error = newValue {
                alertMessage = error
                showingAlert = true
            }
        }
        .onChange(of: serialManager.isConnected) { oldValue, newValue in
            if newValue {
                // 连接成功后添加提示消息
                let message = ChatMessage(
                    content: "串口 \(serialManager.connectedPort ?? "未知") 已连接",
                    isReceived: true,
                    timestamp: Date()
                )
                messages.append(message)
            } else if oldValue {
                // 断开连接时添加提示消息
                let message = ChatMessage(
                    content: "串口已断开连接",
                    isReceived: true,
                    timestamp: Date()
                )
                messages.append(message)
            }
            setupAutoSendTimer()
        }
        .onChange(of: isAutoSendEnabled) { _, _ in setupAutoSendTimer() }
        .onChange(of: messageText) { _, _ in setupAutoSendTimer() }
        .onChange(of: autoSendInterval) { _, _ in setupAutoSendTimer() }
    }
    
    private func setupSerialManager() {
        // 设置数据接收回调
        serialManager.onDataReceived = { data in
            if let string = String(data: data, encoding: .utf8) {
                let message = ChatMessage(
                    content: string,
                    isReceived: true,
                    timestamp: Date()
                )
                messages.append(message)
            } else {
                // 如果不能解码为字符串，显示十六进制
                let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
                let message = ChatMessage(
                    content: "HEX: \(hexString)",
                    isReceived: true,
                    timestamp: Date()
                )
                messages.append(message)
            }
        }
    }
    
    private func sendMessage(_ text: String) {
        guard !text.isEmpty && serialManager.isConnected else { return }
        
        // 添加发送的消息到界面
        let message = ChatMessage(
            content: text,
            isReceived: false,
            timestamp: Date()
        )
        messages.append(message)
        
        // 发送数据到串口
        serialManager.sendString(text + "\r\n")
    }
    
    private func setupAutoSendTimer() {
        autoSendCancellable?.cancel()

        guard isAutoSendEnabled,
              serialManager.isConnected,
              !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let interval = Double(autoSendInterval),
              interval > 0 else {
            return
        }

        autoSendCancellable = Timer.publish(every: interval / 1000.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                sendMessage(messageText)
            }
    }
}

#Preview {
    ContentView()
        .frame(width: 1000, height: 700)
}
