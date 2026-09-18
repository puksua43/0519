import SwiftUI

struct EnableGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    step(1, title: "添加键盘", detail: "打开「设置 → 通用 → 键盘 → 键盘 → 添加新键盘」，选择「抢购快捷」。")
                    step(2, title: "允许完全访问", detail: "点进「抢购快捷」键盘，打开「允许完全访问」。这样才能读取你在本 App 里保存的快捷内容。")
                    step(3, title: "切换使用", detail: "在任意输入框弹出键盘后，长按地球图标，选中「抢购快捷」。点按钮即可插入对应文字。")
                    step(4, title: "自定义内容", detail: "回到本 App，点「添加自定义内容」，例如收货地址、身份证号、常用验证码等，保存后键盘会自动出现新按钮。")

                    Text("隐私说明：快捷内容仅保存在本机 App Group 中，不会上传到任何服务器。开启「完全访问」是 iOS 对第三方键盘读取共享数据的系统要求。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("启用指南")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }

    private func step(_ number: Int, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline.bold())
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.accentColor))

            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
