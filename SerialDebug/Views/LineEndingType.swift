//
//  LineEndingType.swift
//  SerialDebug
//
//  Created by 何秋洋 on 2025/7/6.
//

import Foundation

enum LineEndingType: String, CaseIterable, Identifiable {
    case none = "不添加"
    case cr = "\\r"
    case lf = "\\n"
    case crlf = "\\r\\n"
    
    var id: String { rawValue }
    
    var suffix: String {
        switch self {
        case .none: return ""
        case .cr: return "\r"
        case .lf: return "\n"
        case .crlf: return "\r\n"
        }
    }
    
    var displayName: String {
        switch self {
        case .none: return "不添加回车符"
        case .cr: return "CR (\\r)"
        case .lf: return "LF (\\n)"
        case .crlf: return "CRLF (\\r\\n)"
        }
    }
} 