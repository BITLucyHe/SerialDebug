//
//  SidebarView.swift
//  SerialDebug
//
//  Created by 何秋洋 on 2025/7/6.
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var serialManager: SerialManager
    @Binding var isAutoSendEnabled: Bool
    @Binding var autoSendInterval: String
    
    @State private var selectedPort: String? = nil
    @State private var baudRate = "9600"
    @State private var dataBits = "8"
    @State private var parity = "无"
    @State private var stopBits = "1"
    
    let baudRates = ["9600", "19200", "38400", "57600", "115200", "230400"]
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
                        .fill(serialManager.isConnected ? .green : .red)
                        .frame(width: 8, height: 8)
                    Text(serialManager.isConnected ? "已连接" : "未连接")
                        .font(.subheadline)
                    
                    if let port = serialManager.connectedPort {
                        Text("(\(port))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 显示连接错误
                if let error = serialManager.connectionError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                        .textSelection(.enabled)
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
                            ForEach(serialManager.availablePorts, id: \.self) { port in
                                Text(port).tag(port as String?)
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                        .labelsHidden()
                        .disabled(serialManager.isConnected)
                        .opacity(serialManager.isConnected ? 0.6 : 1.0)
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
                        .disabled(serialManager.isConnected)
                        .opacity(serialManager.isConnected ? 0.6 : 1.0)
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
                        .disabled(serialManager.isConnected)
                        .opacity(serialManager.isConnected ? 0.6 : 1.0)
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
                        .disabled(serialManager.isConnected)
                        .opacity(serialManager.isConnected ? 0.6 : 1.0)
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
                        .disabled(serialManager.isConnected)
                        .opacity(serialManager.isConnected ? 0.6 : 1.0)
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
                            if serialManager.isConnected {
                                serialManager.disconnect()
                            } else {
                                connectToSerial()
                            }
                        }) {
                            HStack {
                                Image(systemName: serialManager.isConnected ? "stop.circle.fill" : "play.circle.fill")
                                Text(serialManager.isConnected ? "断开连接" : "连接")
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(selectedPort == nil ? .gray : (serialManager.isConnected ? .red : .accentColor))
                        .disabled(selectedPort == nil && !serialManager.isConnected)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("设备")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            serialManager.refreshAvailablePorts()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("刷新端口")
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(serialManager.isConnected)
                        .opacity(serialManager.isConnected ? 0.6 : 1.0)
                    }
                }
            }
            
            Divider()
            
            // 自动发送控制
            VStack(alignment: .leading, spacing: 8) {
                Text("自动发送")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("启用", isOn: $isAutoSendEnabled)
                        .disabled(!serialManager.isConnected)
                        .opacity(!serialManager.isConnected ? 0.6 : 1.0)

                    HStack {
                        Text("间隔 (ms)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("", text: $autoSendInterval)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            // 自动选择第一个可用端口
            if selectedPort == nil && !serialManager.availablePorts.isEmpty {
                selectedPort = serialManager.availablePorts.first
            }
        }
        .onChange(of: serialManager.availablePorts) { oldPorts, newPorts in
            // 如果当前选择的端口不在新的端口列表中，自动选择第一个
            if let current = selectedPort, !newPorts.contains(current) {
                selectedPort = newPorts.first
            } else if selectedPort == nil && !newPorts.isEmpty {
                selectedPort = newPorts.first
            }
        }
    }
    
    private func connectToSerial() {
        guard let port = selectedPort else { return }
        
        // 构建串口配置
        let config = SerialManager.SerialConfig(
            baudRate: Int(baudRate) ?? 9600,
            dataBits: Int(dataBits) ?? 8,
            parity: getParityType(parity),
            stopBits: getStopBitsType(stopBits)
        )
        
        // 连接到串口
        serialManager.connect(to: port, config: config)
    }
    
    private func getParityType(_ parity: String) -> SerialManager.SerialConfig.Parity {
        switch parity {
        case "奇校验": return .odd
        case "偶校验": return .even
        default: return .none
        }
    }
    
    private func getStopBitsType(_ stopBits: String) -> SerialManager.SerialConfig.StopBits {
        switch stopBits {
        case "1": return .one
        case "1.5": return .oneAndHalf
        case "2": return .two
        default: return .one
        }
    }
} 
