import Foundation
import SwiftUI

/// 快捷输入项：点一下键盘按钮就会插入对应文本
struct ShortcutItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var label: String
    var value: String
    var colorHex: String
    var shape: ShortcutShape
    var isEnabled: Bool
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        label: String,
        value: String,
        colorHex: String,
        shape: ShortcutShape = .circle,
        isEnabled: Bool = true,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.colorHex = colorHex
        self.shape = shape
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
    }

    static let defaults: [ShortcutItem] = [
        ShortcutItem(label: "姓", value: "", colorHex: "#4A90E2", shape: .roundedRect, sortOrder: 0),
        ShortcutItem(label: "名", value: "", colorHex: "#4A90E2", shape: .roundedRect, sortOrder: 1),
        ShortcutItem(label: "邮箱", value: "", colorHex: "#7B68C7", shape: .circle, sortOrder: 2),
        ShortcutItem(label: "电话", value: "", colorHex: "#F0C040", shape: .circle, sortOrder: 3),
        ShortcutItem(label: "后四位", value: "", colorHex: "#E85D5D", shape: .circle, sortOrder: 4)
    ]
}

enum ShortcutShape: String, Codable, CaseIterable, Identifiable {
    case circle
    case roundedRect

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .circle: return "圆形"
        case .roundedRect: return "圆角矩形"
        }
    }
}

enum ShortcutPalette {
    static let presets: [(name: String, hex: String)] = [
        ("蓝", "#4A90E2"),
        ("紫", "#7B68C7"),
        ("黄", "#F0C040"),
        ("红", "#E85D5D"),
        ("绿", "#3CB371"),
        ("橙", "#F4A261"),
        ("青", "#2A9D8F"),
        ("灰", "#6B7280")
    ]

    static func color(from hex: String) -> Color {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6,
              let value = UInt64(cleaned, radix: 16) else {
            return Color.gray
        }
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}
