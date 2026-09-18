import SwiftUI

struct ContentView: View {
    @State private var items: [ShortcutItem] = []
    @State private var editingItem: ShortcutItem?
    @State private var isAdding = false
    @State private var showEnableGuide = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("抢购快捷键盘")
                            .font(.title2.bold())
                        Text("预先填好姓名、邮箱、电话等信息，抢购时在任意输入框切换到本键盘，一键填入。也可自行添加地址、验证码等自定义内容。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("快捷内容") {
                    ForEach(items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            ShortcutRow(item: item)
                        }
                        .tint(.primary)
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: move)

                    Button {
                        isAdding = true
                    } label: {
                        Label("添加自定义内容", systemImage: "plus.circle.fill")
                    }
                }

                Section("启用键盘") {
                    Button("如何开启「完全访问」与本键盘") {
                        showEnableGuide = true
                    }
                    Text("设置 → 通用 → 键盘 → 键盘 → 添加新键盘 → 选择「抢购快捷」→ 打开「允许完全访问」。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Flash Fill")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .sheet(item: $editingItem) { item in
                ShortcutEditorView(item: item, isNew: false) { saved in
                    ShortcutStore.shared.upsert(saved)
                    reload()
                } onDelete: {
                    ShortcutStore.shared.delete(id: item.id)
                    reload()
                }
            }
            .sheet(isPresented: $isAdding) {
                ShortcutEditorView(
                    item: ShortcutItem(
                        label: "",
                        value: "",
                        colorHex: ShortcutPalette.presets.randomElement()?.hex ?? "#4A90E2",
                        shape: .circle,
                        sortOrder: items.count
                    ),
                    isNew: true
                ) { saved in
                    ShortcutStore.shared.upsert(saved)
                    reload()
                }
            }
            .sheet(isPresented: $showEnableGuide) {
                EnableGuideView()
            }
            .onAppear(perform: reload)
        }
    }

    private func reload() {
        items = ShortcutStore.shared.load()
    }

    private func delete(at offsets: IndexSet) {
        let targets = offsets.map { items[$0].id }
        targets.forEach { ShortcutStore.shared.delete(id: $0) }
        reload()
    }

    private func move(from source: IndexSet, to destination: Int) {
        ShortcutStore.shared.move(from: source, to: destination)
        reload()
    }
}

struct ShortcutRow: View {
    let item: ShortcutItem

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Group {
                    if item.shape == .circle {
                        Circle()
                    } else {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                    }
                }
                .fill(ShortcutPalette.color(from: item.colorHex))
                .frame(width: 44, height: 44)

                Text(item.label.isEmpty ? "?" : String(item.label.prefix(2)))
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.label.isEmpty ? "未命名" : item.label)
                    .font(.headline)
                Text(item.value.isEmpty ? "尚未填写内容（点进编辑）" : item.value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if !item.isEnabled {
                Text("已关闭")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ContentView()
}
