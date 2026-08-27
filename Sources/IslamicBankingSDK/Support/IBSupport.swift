import Foundation
import UIKit

// MARK: - Observable

final class Observable<T> {
    var value: T {
        didSet { listener?(value) }
    }

    private var listener: ((T) -> Void)?

    init(_ value: T) {
        self.value = value
    }

    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }
}

// MARK: - Decodable

extension Decodable {
    init<Key: Hashable>(_ dict: [Key: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

// MARK: - Resources

enum IBResource {
    static func image(_ name: String) -> UIImage? {
        UIImage(named: name, in: .module, compatibleWith: nil)
    }

    static func color(_ name: String) -> UIColor? {
        UIColor(named: name, in: .module, compatibleWith: nil)
    }

    static func nib(_ name: String) -> UINib {
        UINib(nibName: name, bundle: .module)
    }

    static func storyboard(_ name: String) -> UIStoryboard {
        UIStoryboard(name: name, bundle: .module)
    }
}

// MARK: - String / Int helpers

extension String {
    func toMurabahaDisplayDate() -> String {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]

        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        for format in formats {
            inputFormatter.dateFormat = format
            if let date = inputFormatter.date(from: self) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "MMMM dd, yyyy"
                outputFormatter.locale = Locale(identifier: "en_US_POSIX")
                return outputFormatter.string(from: date)
            }
        }
        return self
    }

    var toCurrencyFormat: String {
        guard let number = Double(self) else { return self }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? self
    }
}

extension Int {
    var toString: String { String(self) }
}

extension Int64 {
    var toString: String { String(self) }
}

// MARK: - UIColor hex

extension UIColor {
    convenience init?(hexString: String) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.count == 6, let value = UInt64(hex, radix: 16) else { return nil }
        let r = CGFloat((value & 0xFF0000) >> 16) / 255
        let g = CGFloat((value & 0x00FF00) >> 8) / 255
        let b = CGFloat(value & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

// MARK: - UIView helpers

extension UIView {
    var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
    }

    func applyGradient(colours: [UIColor]?, cornerRadius: CGFloat) {
        layer.sublayers?.removeAll(where: { $0.name == "IBGradientLayer" })
        guard let colours, colours.count >= 2 else {
            backgroundColor = colours?.first
            self.cornerRadius = cornerRadius
            return
        }
        let gradient = CAGradientLayer()
        gradient.name = "IBGradientLayer"
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = bounds
        gradient.cornerRadius = cornerRadius
        layer.insertSublayer(gradient, at: 0)
        self.cornerRadius = cornerRadius
    }

    func ib_enableDoneAccessoryForTextInputs() {
        if let textField = self as? UITextField {
            textField.inputAccessoryView = makeDoneToolbar(for: textField)
        } else if let textView = self as? UITextView {
            textView.inputAccessoryView = makeDoneToolbar(for: textView)
        }
        subviews.forEach { $0.ib_enableDoneAccessoryForTextInputs() }
    }

    private func makeDoneToolbar(for responder: UIResponder) -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: responder, action: #selector(UIResponder.resignFirstResponder))
        toolbar.items = [flex, done]
        return toolbar
    }
}

// MARK: - Alerts / image base64

enum IBUI {
    static func showAlert(title: String = "", message: String) {
        if let delegate = IslamicBanking.config.uiDelegate,
           let show = delegate.islamicBankingShowError {
            show(title, message)
            return
        }
        guard let top = topViewController() else { return }
        let alert = UIAlertController(title: title.isEmpty ? nil : title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        top.present(alert, animated: true)
    }

    static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

    static func base64String(from image: UIImage, qualityPercentage: Int) -> String? {
        let quality = max(0, min(100, qualityPercentage))
        let compression = CGFloat(quality) / 100
        guard let data = image.jpegData(compressionQuality: compression) else { return nil }
        return data.base64EncodedString()
    }
}

// MARK: - Keyboard adjuster

final class IBKeyboardBottomConstraintAdjuster {
    private weak var bottomConstraint: NSLayoutConstraint?
    private weak var hostView: UIView?
    private let defaultConstant: CGFloat
    private var observers: [NSObjectProtocol] = []

    init(bottomConstraint: NSLayoutConstraint, hostView: UIView, defaultConstant: CGFloat) {
        self.bottomConstraint = bottomConstraint
        self.hostView = hostView
        self.defaultConstant = defaultConstant
        let center = NotificationCenter.default
        observers.append(center.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { [weak self] note in
            self?.handleKeyboard(note)
        })
        observers.append(center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            self?.bottomConstraint?.constant = defaultConstant
            self?.hostView?.layoutIfNeeded()
        })
    }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    private func handleKeyboard(_ note: Notification) {
        guard
            let hostView,
            let bottomConstraint,
            let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        let converted = hostView.convert(frame, from: nil)
        let overlap = max(0, hostView.bounds.maxY - converted.minY)
        bottomConstraint.constant = defaultConstant + overlap
        hostView.layoutIfNeeded()
    }
}

// MARK: - Lightweight glass stubs (no third-party blur dependency)

@IBDesignable
final class IBGlassEffectView: UIView {
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))

    @IBInspectable var blurDensity: CGFloat = 0.2
    @IBInspectable var glassCornerRadius: CGFloat = 20 {
        didSet { layer.cornerRadius = glassCornerRadius; blurView.layer.cornerRadius = glassCornerRadius }
    }
    @IBInspectable var glassDistance: CGFloat = 20
    @IBInspectable var glassBorderWidth: CGFloat = 0.3 {
        didSet { layer.borderWidth = glassBorderWidth }
    }
    @IBInspectable var isDarkTheme: Bool = false {
        didSet {
            blurView.effect = UIBlurEffect(style: isDarkTheme ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        clipsToBounds = true
        layer.cornerRadius = glassCornerRadius
        layer.borderWidth = glassBorderWidth
        layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = glassCornerRadius
        insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        blurView.isUserInteractionEnabled = false
    }

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if subview !== blurView {
            sendSubviewToBack(blurView)
        }
    }
}

@IBDesignable
final class IBGlassyContainerView: UIView {
    @IBInspectable var glassCornerRadius: CGFloat = 16 {
        didSet { layer.cornerRadius = glassCornerRadius }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.cornerRadius = glassCornerRadius
        clipsToBounds = true
    }
}
