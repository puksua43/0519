# 抢购快捷键盘（Flash Fill）

类似截图里的「彩色大按钮键盘」：把姓名、邮箱、电话、身份证后四位等预先填好，抢购苹果等场景下在任意输入框一键填入。

**支持用户自定义添加**任意其它需输入内容（地址、验证码、优惠码等）。

---

## 仓库结构

| 目录 | 说明 |
|------|------|
| `FlashFillKeyboard/` | **iOS 真机方案**：主 App（管理快捷内容）+ 自定义键盘扩展 |
| `web-demo/` | **浏览器可交互预览**（布局与自定义逻辑演示，非系统键盘） |

---

## 功能

- 预设按钮：姓 / 名 / 邮箱 / 电话 / 后四位（可改文案与内容）
- 自定义添加：名称 + 插入文本 + 颜色 + 形状（圆形 / 圆角矩形）
- 编辑、删除、拖拽排序、开关显示
- 键盘底部：空格、清空、退格、换行
- 自定义项多时，圆形按钮区域可左右滑动

---

## iOS 真机使用（推荐）

### 环境

- macOS + Xcode 15+
- 免费或付费 Apple Developer 账号（真机调试键盘扩展建议使用开发者账号）
- 可选：[XcodeGen](https://github.com/yonaskolb/XcodeGen)（用 `project.yml` 生成工程）

### 生成并打开工程

```bash
cd FlashFillKeyboard
# 若已安装 xcodegen：
xcodegen generate
open FlashFillKeyboard.xcodeproj
```

若没有 XcodeGen，也可在 Xcode 中手动新建：

1. **App** target：`FlashFillApp`，把 `FlashFillApp/` 与 `Shared/` 加进去  
2. **Custom Keyboard Extension** target：`KeyboardExtension`，把 `KeyboardExtension/` 与 `Shared/` 加进去  
3. 两个 target 都开启同一个 **App Group**，ID 与代码中一致：  
   `group.com.example.flashfill`  
   （请改成你自己的 Team 前缀，并同步修改 `ShortcutStore.appGroupID` 与两个 `.entitlements`）

### 签名与运行

1. 在 Signing & Capabilities 里选中你的 Team  
2. 把 Bundle ID 改成唯一值（如 `com.你的名字.flashfill`）  
3. Run 主 App 到 iPhone  
4. 系统设置 → 通用 → 键盘 → 键盘 → 添加新键盘 → **抢购快捷**  
5. 点进该键盘，打开 **允许完全访问**（才能读到 App 里保存的内容）  
6. 任意输入框弹出键盘 → 长按 🌐 → 选「抢购快捷」

### 使用流程

1. 打开 App，把「姓 / 名 / 邮箱…」填成你的真实信息  
2. 点「添加自定义内容」增加地址等字段  
3. 抢购页面切换到本键盘，点按钮即可插入

---

## 网页预览

```bash
cd web-demo
npm install
npm run dev
```

浏览器打开提示的本地地址，可试点键盘、添加/编辑自定义内容。  
这是 UI/交互预览，**不能**当作系统输入法安装到 iPhone。

---

## 隐私说明

- 快捷内容只存在本机（iOS：App Group `UserDefaults`；网页：`localStorage`）
- 不包含上传、账号或服务器逻辑
- iOS 要求第三方键盘读取共享数据时开启「完全访问」

---

## 说明

本项目是个人效率工具（快速填表），请遵守各电商/官方活动的服务条款。自动化抢购、绕过风控等不在本仓库范围内。
