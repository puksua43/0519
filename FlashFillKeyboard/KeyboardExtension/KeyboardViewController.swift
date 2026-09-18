import UIKit

/// 自定义输入法扩展：彩色快捷按钮 + 空格/清空/退格/换行
final class KeyboardViewController: UIInputViewController {
    private let store = ShortcutStore.shared

    private let rootStack = UIStackView()
    private let shortcutsRow = UIStackView()
    private let leftColumn = UIStackView()
    private let circlesRow = UIStackView()
    private let controlsRow = UIStackView()
    private let scrollView = UIScrollView()
    private let scrollContent = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.82, green: 0.83, blue: 0.85, alpha: 1)
        configureLayout()
        reloadShortcuts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadShortcuts()
    }

    private func configureLayout() {
        rootStack.axis = .vertical
        rootStack.spacing = 12
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootStack)

        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            rootStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 268)
        ])

        shortcutsRow.axis = .horizontal
        shortcutsRow.spacing = 10
        shortcutsRow.alignment = .fill

        leftColumn.axis = .vertical
        leftColumn.spacing = 8
        leftColumn.distribution = .fillEqually

        circlesRow.axis = .horizontal
        circlesRow.spacing = 10
        circlesRow.distribution = .fillEqually
        circlesRow.alignment = .fill

        scrollContent.axis = .horizontal
        scrollContent.spacing = 10
        scrollContent.alignment = .fill
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.addSubview(scrollContent)
        scrollContent.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollContent.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollContent.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollContent.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollContent.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollContent.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        leftColumn.translatesAutoresizingMaskIntoConstraints = false
        leftColumn.widthAnchor.constraint(equalToConstant: 74).isActive = true

        shortcutsRow.addArrangedSubview(leftColumn)
        shortcutsRow.addArrangedSubview(scrollView)

        controlsRow.axis = .horizontal
        controlsRow.spacing = 8
        controlsRow.distribution = .fill

        rootStack.addArrangedSubview(shortcutsRow)
        rootStack.addArrangedSubview(controlsRow)
        shortcutsRow.heightAnchor.constraint(equalToConstant: 168).isActive = true

        buildControlButtons()
    }

    private func reloadShortcuts() {
        let items = store.load().filter(\.isEnabled)
        leftColumn.arrangedSubviews.forEach {
            leftColumn.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        scrollContent.arrangedSubviews.forEach {
            scrollContent.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        guard !items.isEmpty else {
            leftColumn.isHidden = true
            let hint = UILabel()
            hint.text = "请先在「抢购快捷」App 中添加内容"
            hint.textAlignment = .center
            hint.textColor = .darkGray
            hint.numberOfLines = 0
            hint.font = .systemFont(ofSize: 15, weight: .medium)
            scrollContent.addArrangedSubview(hint)
            return
        }

        // 布局策略：圆角矩形靠左竖排（姓/名），圆形横排（可左右滑动容纳自定义项）
        let rectItems = items.filter { $0.shape == .roundedRect }
        let circleItems = items.filter { $0.shape == .circle }

        let leftItems: [ShortcutItem]
        let rightItems: [ShortcutItem]
        if !rectItems.isEmpty {
            leftItems = Array(rectItems.prefix(3))
            rightItems = circleItems + Array(rectItems.dropFirst(3))
        } else if items.count <= 2 {
            leftItems = items
            rightItems = []
        } else {
            leftItems = Array(items.prefix(2))
            rightItems = Array(items.dropFirst(2))
        }

        leftColumn.isHidden = leftItems.isEmpty
        for item in leftItems {
            leftColumn.addArrangedSubview(ShortcutKeyButton(item: item, forceShape: .roundedRect) { [weak self] in
                self?.insert(text(for: item))
            })
        }

        let circleSide: CGFloat = 148
        for item in rightItems {
            let button = ShortcutKeyButton(item: item, forceShape: .circle) { [weak self] in
                self?.insert(text(for: item))
            }
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: circleSide).isActive = true
            button.heightAnchor.constraint(equalToConstant: circleSide).isActive = true
            scrollContent.addArrangedSubview(button)
        }

        if rightItems.isEmpty && !leftItems.isEmpty {
            // 仅左侧时也给一点提示空间
            scrollView.isHidden = true
        } else {
            scrollView.isHidden = false
        }
    }

    private func text(for item: ShortcutItem) -> String {
        let trimmed = item.value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? item.label : item.value
    }

    private func buildControlButtons() {
        controlsRow.arrangedSubviews.forEach {
            controlsRow.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let space = makeControlButton(title: "空格", bg: .white, fg: .darkText) { [weak self] in
            self?.textDocumentProxy.insertText(" ")
        }
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let clear = makeIconButton(systemName: "trash.fill", bg: UIColor(red: 0.91, green: 0.36, blue: 0.36, alpha: 1)) { [weak self] in
            self?.clearAll()
        }
        let backspace = makeIconButton(systemName: "delete.left.fill", bg: UIColor(white: 0.35, alpha: 1)) { [weak self] in
            self?.textDocumentProxy.deleteBackward()
        }
        let newline = makeControlButton(title: "换行", bg: UIColor(white: 0.35, alpha: 1), fg: .white) { [weak self] in
            self?.textDocumentProxy.insertText("\n")
        }

        [clear, backspace].forEach {
            $0.widthAnchor.constraint(equalToConstant: 48).isActive = true
        }
        newline.widthAnchor.constraint(equalToConstant: 64).isActive = true
        [space, clear, backspace, newline].forEach {
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }

        controlsRow.addArrangedSubview(space)
        controlsRow.addArrangedSubview(clear)
        controlsRow.addArrangedSubview(backspace)
        controlsRow.addArrangedSubview(newline)
    }

    private func makeControlButton(title: String, bg: UIColor, fg: UIColor, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(fg, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = bg
        button.layer.cornerRadius = 8
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    private func makeIconButton(systemName: String, bg: UIColor, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = .white
        button.backgroundColor = bg
        button.layer.cornerRadius = 8
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    private func insert(_ text: String) {
        guard !text.isEmpty else { return }
        textDocumentProxy.insertText(text)
    }

    private func clearAll() {
        if let before = textDocumentProxy.documentContextBeforeInput {
            for _ in before { textDocumentProxy.deleteBackward() }
        }
        if let after = textDocumentProxy.documentContextAfterInput {
            for _ in after {
                textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
                textDocumentProxy.deleteBackward()
            }
        }
    }
}

/// 单个快捷键按钮，自动按圆形/圆角矩形裁剪
final class ShortcutKeyButton: UIButton {
    private let shortcutShape: ShortcutShape

    init(item: ShortcutItem, forceShape: ShortcutShape? = nil, onTap: @escaping () -> Void) {
        self.shortcutShape = forceShape ?? item.shape
        super.init(frame: .zero)
        setTitle(item.label, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
        backgroundColor = Self.color(from: item.colorHex)
        addAction(UIAction { _ in onTap() }, for: .touchUpInside)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        switch shortcutShape {
        case .circle:
            layer.cornerRadius = min(bounds.width, bounds.height) / 2
        case .roundedRect:
            layer.cornerRadius = 12
        }
    }

    private static func color(from hex: String) -> UIColor {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else {
            return .systemGray
        }
        let r = CGFloat((value >> 16) & 0xFF) / 255.0
        let g = CGFloat((value >> 8) & 0xFF) / 255.0
        let b = CGFloat(value & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
