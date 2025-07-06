//
//  SerialManager.swift
//  SerialDebug
//
//  Created by 何秋洋 on 2025/7/6.
//

import Foundation
import IOKit
import IOKit.serial

class SerialManager: ObservableObject {
    @Published var availablePorts: [String] = []
    @Published var isConnected = false
    @Published var connectedPort: String?
    @Published var connectionError: String?
    
    private var fileDescriptor: Int32 = -1
    private var readDispatchSource: DispatchSourceRead?
    private var queue = DispatchQueue(label: "serial.communication", qos: .userInteractive)
    
    // 串口配置
    struct SerialConfig {
        let baudRate: Int
        let dataBits: Int
        let parity: Parity
        let stopBits: StopBits
        
        enum Parity {
            case none, odd, even
        }
        
        enum StopBits {
            case one, oneAndHalf, two
        }
    }
    
    // 数据接收回调
    var onDataReceived: ((Data) -> Void)?
    
    init() {
        refreshAvailablePorts()
    }
    
    deinit {
        disconnect()
    }
    
    // MARK: - 端口发现
    func refreshAvailablePorts() {
        queue.async { [weak self] in
            let ports = self?.findSerialPorts() ?? []
            DispatchQueue.main.async {
                self?.availablePorts = ports
            }
        }
    }
    
    private func findSerialPorts() -> [String] {
        var ports: [String] = []
        
        // 获取所有串口设备
        let matchingDict = IOServiceMatching(kIOSerialBSDServiceValue)
        var serialPortIterator: io_iterator_t = 0
        
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &serialPortIterator)
        
        if result == KERN_SUCCESS {
            var serialService: io_object_t = 0
            
            repeat {
                serialService = IOIteratorNext(serialPortIterator)
                if serialService != 0 {
                    let key = kIODialinDeviceKey as CFString
                    let bsdPathAsCFString = IORegistryEntryCreateCFProperty(serialService, key, kCFAllocatorDefault, 0)
                    
                    if let bsdPath = bsdPathAsCFString?.takeUnretainedValue() as? String {
                        let portName = bsdPath.components(separatedBy: "/").last ?? bsdPath
                        // 过滤掉蓝牙端口
                        if !isBluetoothPort(portName) {
                            ports.append(portName)
                        }
                    }
                    
                    IOObjectRelease(serialService)
                }
            } while serialService != 0
        }
        
        IOObjectRelease(serialPortIterator)
        
        // 也尝试扫描常见的串口设备路径（排除蓝牙端口）
        let commonPorts = [
            "cu.usbserial-0001",
            "cu.usbserial-14410",
            "cu.usbmodem14101",
            "cu.usbmodem14201",
            "cu.wchusbserial14410",
            "cu.wchusbserial14420",
            "cu.SLAB_USBtoUART"
        ]
        
        for port in commonPorts {
            let devicePath = "/dev/\(port)"
            if FileManager.default.fileExists(atPath: devicePath) && !ports.contains(port) {
                ports.append(port)
            }
        }
        
        // 如果还是没有找到端口，添加一些用于演示的端口（排除蓝牙）
        if ports.isEmpty {
            ports = ["cu.usbserial-0001", "cu.usbmodem14101"]
        }
        
        return ports.sorted()
    }
    
    // 判断是否为蓝牙端口
    private func isBluetoothPort(_ portName: String) -> Bool {
        let bluetoothKeywords = ["bluetooth", "Bluetooth", "BLUETOOTH"]
        
        for keyword in bluetoothKeywords {
            if portName.lowercased().contains(keyword.lowercased()) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - 连接管理
    func connect(to port: String, config: SerialConfig) {
        guard !isConnected else { return }
        
        queue.async { [weak self] in
            self?.performConnect(to: port, config: config)
        }
    }
    
    private func performConnect(to port: String, config: SerialConfig) {
        let devicePath = "/dev/\(port)"
        
        // 检查设备是否存在
        guard FileManager.default.fileExists(atPath: devicePath) else {
            DispatchQueue.main.async { [weak self] in
                self?.connectionError = "设备不存在: \(port)"
            }
            return
        }
        
        // 打开串口
        fileDescriptor = open(devicePath, O_RDWR | O_NOCTTY | O_NONBLOCK)
        
        if fileDescriptor == -1 {
            let errorMsg = String(cString: strerror(errno))
            DispatchQueue.main.async { [weak self] in
                self?.connectionError = "无法打开串口 \(port): \(errorMsg)"
            }
            return
        }
        
        // 配置串口参数
        var options = termios()
        
        if tcgetattr(fileDescriptor, &options) != 0 {
            let errorMsg = String(cString: strerror(errno))
            close(fileDescriptor)
            fileDescriptor = -1
            DispatchQueue.main.async { [weak self] in
                self?.connectionError = "无法获取串口配置: \(errorMsg)"
            }
            return
        }
        
        // 保存原始配置
        _ = options
        
        // 配置波特率
        let baudRateConstant = getBaudRateConstant(config.baudRate)
        cfsetispeed(&options, baudRateConstant)
        cfsetospeed(&options, baudRateConstant)
        
        // 配置数据位
        options.c_cflag &= ~UInt(CSIZE)
        switch config.dataBits {
        case 5: options.c_cflag |= UInt(CS5)
        case 6: options.c_cflag |= UInt(CS6)
        case 7: options.c_cflag |= UInt(CS7)
        case 8: options.c_cflag |= UInt(CS8)
        default: options.c_cflag |= UInt(CS8)
        }
        
        // 配置校验位
        switch config.parity {
        case .none:
            options.c_cflag &= ~UInt(PARENB)
        case .odd:
            options.c_cflag |= UInt(PARENB | PARODD)
        case .even:
            options.c_cflag |= UInt(PARENB)
            options.c_cflag &= ~UInt(PARODD)
        }
        
        // 配置停止位
        switch config.stopBits {
        case .one:
            options.c_cflag &= ~UInt(CSTOPB)
        case .two:
            options.c_cflag |= UInt(CSTOPB)
        case .oneAndHalf:
            options.c_cflag |= UInt(CSTOPB) // 近似处理
        }
        
        // 其他配置
        options.c_cflag |= UInt(CREAD | CLOCAL)
        options.c_iflag &= ~UInt(IXON | IXOFF | IXANY)
        options.c_lflag &= ~UInt(ICANON | ECHO | ECHOE | ISIG)
        options.c_oflag &= ~UInt(OPOST)
        
        // 设置超时
        options.c_cc.16 = 0 // VMIN
        options.c_cc.17 = 1 // VTIME
        
        // 应用配置
        if tcsetattr(fileDescriptor, TCSANOW, &options) != 0 {
            let errorMsg = String(cString: strerror(errno))
            close(fileDescriptor)
            fileDescriptor = -1
            DispatchQueue.main.async { [weak self] in
                self?.connectionError = "无法配置串口参数: \(errorMsg)"
            }
            return
        }
        
        // 清空缓冲区
        tcflush(fileDescriptor, TCIOFLUSH)
        
        // 启动读取
        startReading()
        
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = true
            self?.connectedPort = port
            self?.connectionError = nil
        }
    }
    
    func disconnect() {
        queue.async { [weak self] in
            self?.performDisconnect()
        }
    }
    
    private func performDisconnect() {
        // 停止读取
        readDispatchSource?.cancel()
        readDispatchSource = nil
        
        // 关闭文件描述符
        if fileDescriptor != -1 {
            close(fileDescriptor)
            fileDescriptor = -1
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = false
            self?.connectedPort = nil
            self?.connectionError = nil
        }
    }
    
    // MARK: - 数据收发
    func sendData(_ data: Data) {
        guard isConnected, fileDescriptor != -1 else { return }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let bytesWritten = write(self.fileDescriptor, data.withUnsafeBytes { $0.baseAddress }, data.count)
            
            if bytesWritten == -1 {
                let errorMsg = String(cString: strerror(errno))
                DispatchQueue.main.async {
                    self.connectionError = "发送数据失败: \(errorMsg)"
                }
            }
        }
    }
    
    func sendString(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        sendData(data)
    }
    
    private func startReading() {
        guard fileDescriptor != -1 else { return }
        
        readDispatchSource = DispatchSource.makeReadSource(fileDescriptor: fileDescriptor, queue: queue)
        
        readDispatchSource?.setEventHandler { [weak self] in
            self?.readData()
        }
        
        readDispatchSource?.setCancelHandler { [weak self] in
            // 清理资源
            self?.readDispatchSource = nil
        }
        
        readDispatchSource?.resume()
    }
    
    private func readData() {
        guard fileDescriptor != -1 else { return }
        
        var buffer = [UInt8](repeating: 0, count: 1024)
        let bytesRead = read(fileDescriptor, &buffer, buffer.count)
        
        if bytesRead > 0 {
            let data = Data(buffer[0..<bytesRead])
            DispatchQueue.main.async { [weak self] in
                self?.onDataReceived?(data)
            }
        } else if bytesRead == -1 {
            // 读取错误
            let errorMsg = String(cString: strerror(errno))
            DispatchQueue.main.async { [weak self] in
                self?.connectionError = "读取数据失败: \(errorMsg)"
                self?.disconnect()
            }
        }
    }
    
    // MARK: - 辅助方法
    private func getBaudRateConstant(_ baudRate: Int) -> speed_t {
        switch baudRate {
        case 9600: return speed_t(B9600)
        case 19200: return speed_t(B19200)
        case 38400: return speed_t(B38400)
        case 57600: return speed_t(B57600)
        case 115200: return speed_t(B115200)
        case 230400: return speed_t(B230400)
        default: return speed_t(B9600)
        }
    }
} 