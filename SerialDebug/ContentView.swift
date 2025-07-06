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

struct SidebarView: View {
    @State private var selectedPort: String? = nil
    @State private var availablePorts = ["COM1", "COM3", "USB Serial Port"]
    @Binding var isConnected: Bool
    @Binding var connectedPort: String?
    @State private var baudRate = "9600"
    @State private var dataBits = "8"
    @State private var parity = "无"
    @State private var stopBits = "1"
    
    let baudRates = ["9600", "19200", "38400", "57600", "115200"]
    let dataBitOptions = ["5", "6", "7", "8"]
    let parityOptions = ["无", "奇校验", "偶校验"]
    let stopBitOptions = ["1", "1.5", "2"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 连接状态
            VStack(alignment: .leading, spacing: 8) {
                Text("连接状态")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Circle()
                        .fill(isConnected ? .green : .red)
                        .frame(width: 8, height: 8)
                    Text(isConnected ? "已连接" : "未连接")
                        .font(.subheadline)
                }
            }
            
            Divider()
            
            // 串口设置
            VStack(alignment: .leading, spacing: 8) {
                Text("串口设置")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("端口")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $selectedPort) {
                            Text("选择端口").tag(nil as String?)
                            ForEach(availablePorts, id: \.self) { port in
                                Text(port).tag(port as String?)
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                        .labelsHidden()
                        .disabled(isConnected)
                        .opacity(isConnected ? 0.6 : 1.0)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("波特率")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $baudRate) {
                            ForEach(baudRates, id: \.self) { rate in
                                Text(rate).tag(rate)
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                        .labelsHidden()
                        .disabled(isConnected)
                        .opacity(isConnected ? 0.6 : 1.0)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("数据位")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $dataBits) {
                            ForEach(dataBitOptions, id: \.self) { bits in
                                Text(bits).tag(bits)
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                        .labelsHidden()
                        .disabled(isConnected)
                        .opacity(isConnected ? 0.6 : 1.0)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("校验位")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $parity) {
                            ForEach(parityOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                        .labelsHidden()
                        .disabled(isConnected)
                        .opacity(isConnected ? 0.6 : 1.0)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("停止位")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $stopBits) {
                            ForEach(stopBitOptions, id: \.self) { bits in
                                Text(bits).tag(bits)
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                        .labelsHidden()
                        .disabled(isConnected)
                        .opacity(isConnected ? 0.6 : 1.0)
                    }
                }
            }
            
            Divider()
            
            // 连接控制
            VStack(alignment: .leading, spacing: 8) {
                Text("连接控制")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("操作")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            isConnected.toggle()
                            connectedPort = isConnected ? selectedPort : nil
                        }) {
                            HStack {
                                Image(systemName: isConnected ? "stop.circle.fill" : "play.circle.fill")
                                Text(isConnected ? "断开连接" : "连接")
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(selectedPort == nil ? .gray : (isConnected ? .red : .accentColor))
                        .disabled(selectedPort == nil)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("设备")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            // 刷新端口逻辑
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("刷新端口")
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isConnected)
                        .opacity(isConnected ? 0.6 : 1.0)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

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

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isReceived: Bool
    let timestamp: Date
}



#Preview {
    ContentView()
        .frame(width: 1000, height: 700)
}
