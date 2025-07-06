//
//  SidebarView.swift
//  SerialDebug
//
//  Created by 何秋洋 on 2025/7/6.
//

import SwiftUI

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