//
//  InitialController.swift
//  Portogal
//
//  Created by Сергей Майбродский on 23.06.2023.
//

import SwiftUI

struct OmenTextFieldRep: UIViewRepresentable {
    @Binding var text: String
    var isFocused: Binding<Bool>?
    @Binding var height: CGFloat
    var returnKeyType: OmenTextField.ReturnKeyType
    var onCommit: (() -> Void)?

    // MARK: - Make
    func makeUIView(context: Context) -> UITextView {
        let view = CustomUITextView(rep: self)
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.backgroundColor = .clear
        view.delegate = context.coordinator
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.keyboardDismissMode = .interactive
        view.returnKeyType = returnKeyType.uiReturnKey
        DispatchQueue.main.async {
            view.text = text
            height = view.textHeight()
        }
        return view
    }

    // MARK: - Update
    func updateUIView(_ view: UITextView, context: Context) {
        if view.returnKeyType != returnKeyType.uiReturnKey {
            view.returnKeyType = returnKeyType.uiReturnKey
            view.reloadInputViews()
            return
        }

        if view.text != text {
            view.text = text
            // Update the stated field in main queue.
            DispatchQueue.main.async {
                height = view.textHeight()
            }
        }

        updateFocus(view, context: context)
    }

    private func updateFocus(_ view: UITextView, context: Context) {
        guard let isFocused = isFocused?.wrappedValue else { return }
        if isFocused,
           view.window != nil,
           !view.isFirstResponder,
           view.canBecomeFirstResponder,
           context.environment.isEnabled
        {
            view.becomeFirstResponder()
            view.selectedRange = NSRange(location: view.text.count, length: 0)
        } else if !isFocused, view.isFirstResponder {
            view.resignFirstResponder()
        }
    }

    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(rep: self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        let rep: OmenTextFieldRep

        internal init(rep: OmenTextFieldRep) {
            self.rep = rep
        }

        func textView(_: UITextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
            guard let onCommit = rep.onCommit, text == "\n" else { return true }
            onCommit()
            return false
        }

        func textViewDidChange(_ textView: UITextView) {
            rep.text = textView.text
            rep.height = textView.textHeight()
        }
    }
}

// MARK: - Custom View
class CustomUITextView: UITextView {
    let rep: OmenTextFieldRep

    internal init(rep: OmenTextFieldRep) {
        self.rep = rep
        super.init(frame: .zero, textContainer: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        rep.isFocused?.wrappedValue = true
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        rep.isFocused?.wrappedValue = false
        return super.resignFirstResponder()
    }
}

// MARK: - Useful Extensions
extension UITextView {
    func textHeight() -> CGFloat {
        sizeThatFits(bounds.size).height
    }
}

public struct OmenTextField: View {
    var title: String
    @Binding var text: String
    var isFocused: Binding<Bool>?
    @State var height: CGFloat = 0
    var returnKeyType: ReturnKeyType
    var onCommit: (() -> Void)?
    var onTab: (() -> Void)?
    var onBackTab: (() -> Void)?

    /// Creates a multiline text field with a text label.
    ///
    /// - Parameters:
    ///   - title: The title of the text field.
    ///   - text: The text to display and edit.
    ///   - isFocused: Whether or not the field should be focused.
    ///   - returnKeyType: The type of return key to be used on iOS.
    ///   - onCommit: An action to perform when the user presses the
    ///     Return key) while the text field has focus. If `nil`, a newline
    ///     will be inserted.
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        isFocused: Binding<Bool>? = nil,
        returnKeyType: ReturnKeyType = .default,
        onTab: (() -> Void)? = nil,
        onBackTab: (() -> Void)? = nil,
        onCommit: (() -> Void)? = nil
    ) {
        self.title = String(title)
        _text = text
        self.isFocused = isFocused
        self.returnKeyType = returnKeyType
        self.onCommit = onCommit
        self.onTab = onTab
        self.onBackTab = onBackTab
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            Text(title)
                .foregroundColor(.secondary)
                .opacity(text.isEmpty ? 0.5 : 0)
                .animation(nil)

            #if os(iOS)
                OmenTextFieldRep(
                    text: $text,
                    isFocused: isFocused,
                    height: $height,
                    returnKeyType: returnKeyType,
                    onCommit: onCommit
                )
                .frame(height: height)
            #elseif os(macOS)
                OmenTextFieldRep(
                    text: $text,
                    isFocused: isFocused,
                    height: $height,
                    onCommit: onCommit,
                    onTab: onTab,
                    onBackTab: onBackTab
                )
                .frame(height: height)
            #endif
        }
    }
}

// MARK: - ReturnKeyType
public extension OmenTextField {
    enum ReturnKeyType: String, CaseIterable {
        case done
        case next
        case `default`
        case `continue`
        case go
        case search
        case send

        #if os(iOS)
            var uiReturnKey: UIReturnKeyType {
                switch self {
                case .done:
                    return .done
                case .next:
                    return .next
                case .default:
                    return .default
                case .continue:
                    return .continue
                case .go:
                    return .go
                case .search:
                    return .search
                case .send:
                    return .send
                }
            }
        #endif
    }
}
