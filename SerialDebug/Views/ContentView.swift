//
//  ContentView.swift
//  SerialDebug
//
//  Created by 何秋洋 on 2025/7/6.
//

import SwiftUI

struct ContentView: View {
    @State private var sidebarVisible = true
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(content: "串口已连接", isReceived: true, timestamp: Date()),
        ChatMessage(content: "AT", isReceived: false, timestamp: Date().addingTimeInterval(-60)),
        ChatMessage(content: "OK", isReceived: true, timestamp: Date().addingTimeInterval(-50))
    ]
    @State private var connectedPort: String? = nil
    @State private var isConnected = false
    
    var body: some View {
        NavigationSplitView(sidebar: {
            SidebarView(isConnected: $isConnected, connectedPort: $connectedPort)
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        }, detail: {
            ChatView(messages: $messages, messageText: $messageText, isConnected: isConnected)
        })
        .navigationTitle(isConnected && connectedPort != nil ? connectedPort! : "串口调试工具")
        .frame(minWidth: 900, minHeight: 550)
    }
}

#Preview {
    ContentView()
        .frame(width: 1000, height: 700)
}
