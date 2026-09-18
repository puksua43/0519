import SwiftUI

struct ShortcutEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State var item: ShortcutItem
    let isNew: Bool
    let onSave: (ShortcutItem) -> Void
    var onDelete: (() -> Void)?

    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                Section("显示") {
                    TextField("按钮名称（如：地址、验证码）", text: $item.label)
                    TextField("点击后插入的内容", text: $item.value, axis: .vertical)
                        .lineLimit(3...6)

                    Toggle("在键盘上显示", isOn: $item.isEnabled)
                }

                Section("外观") {
                    Picker("形状", selection: $item.shape) {
                        ForEach(ShortcutShape.allCases) { shape in
                            Text(shape.displayName).tag(shape)
                        }
                    }
                    .pickerStyle(.segmented)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(ShortcutPalette.presets, id: \.hex) { preset in
                            Button {
                                item.colorHex = preset.hex
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(ShortcutPalette.color(from: preset.hex))
                                        .frame(width: 40, height: 40)
                                    if item.colorHex.uppercased() == preset.hex.uppercased() {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(preset.name)
                        }
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Text("预览")
                        Spacer()
                        ShortcutPreviewBadge(item: item)
                    }
                }

                if !isNew, onDelete != nil {
                    Section {
                        Button("删除此项", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "添加内容" : "编辑内容")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(item)
                        dismiss()
                    }
                    .disabled(item.label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .confirmationDialog("确认删除？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("删除", role: .destructive) {
                    onDelete?()
                    dismiss()
                }
                Button("取消", role: .cancel) {}
            }
        }
    }
}

struct ShortcutPreviewBadge: View {
    let item: ShortcutItem

    var body: some View {
        ZStack {
            Group {
                if item.shape == .circle {
                    Circle()
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                }
            }
            .fill(ShortcutPalette.color(from: item.colorHex))
            .frame(width: 64, height: 64)

            Text(item.label.isEmpty ? "预览" : item.label)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(6)
        }
    }
}
