# 在 Xcode 中手动创建工程（无 XcodeGen 时）

1. File → New → Project → App（SwiftUI，iOS 16+），Product Name：`FlashFillApp`
2. File → New → Target → Custom Keyboard Extension，Product Name：`KeyboardExtension`
3. 删除 Xcode 自动生成的占位文件，改为加入本仓库源码：
   - App：`FlashFillApp/*` + `Shared/*`
   - Extension：`KeyboardExtension/*` + `Shared/*`
4. 两个 Target → Signing & Capabilities → App Groups → 添加同一组，例如 `group.com.你的id.flashfill`
5. 修改：
   - `Shared/ShortcutStore.swift` 里的 `appGroupID`
   - `FlashFillApp.entitlements` / `KeyboardExtension.entitlements`
6. Extension 的 Info 中确认 `RequestsOpenAccess = YES`，Principal Class 为 `KeyboardViewController`
7. 主 App Embed Foundation Extensions 中勾选 Keyboard Extension
