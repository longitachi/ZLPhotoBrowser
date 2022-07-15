//
//  CustomAlertController.swift
//  Example
//
//  Created by long on 2022/7/1.
//

import UIKit
import ZLPhotoBrowser

class CustomAlertController: UIViewController {
    private let cornerRadiu: CGFloat = 12
    
    private let separatorHeight: CGFloat = 1 / UIScreen.main.scale
    
    private let separatorColor = UIColor.color(hexRGB: 0xEEEEEE)
    
    private let actionHeight: CGFloat = 50
    
    private let alertTitle: String?
    
    private let message: String
    
    private let preferredStyle: ZLCustomAlertStyle
    
    private lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = cornerRadiu
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.color(hexRGB: 0x171717)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private lazy var actionStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.alignment = .fill
        view.spacing = separatorHeight
        view.axis = .horizontal
        view.backgroundColor = separatorColor
        return view
    }()
    
    private var cancelButton: UIButton?
    
    private(set) lazy var actions: [ZLCustomAlertAction] = []
    
    /// 通过按钮获取对应的action
    private lazy var btnToActionMap: [UIButton: ZLCustomAlertAction] = [:]
    
    var alertFrame: CGRect { container.frame }
    
    init(title: String?, message: String, preferredStyle: ZLCustomAlertStyle) {
        alertTitle = title
        self.message = message
        self.preferredStyle = preferredStyle
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        view.addSubview(container)
        if preferredStyle == .alert {
            container.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.8)
            }
        } else {
            container.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(cornerRadiu)
            }
        }
        
        let padding: CGFloat = 25
        var hasTitle = false
        if let alertTitle = alertTitle, !alertTitle.isEmpty {
            hasTitle = true
            titleLabel.text = alertTitle
            container.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(container.snp.top).offset(28)
                make.left.equalToSuperview().offset(padding)
                make.right.equalToSuperview().offset(-padding)
            }
        }
        
        var hasMessage = false
        if !message.isEmpty {
            hasMessage = true
            
            let attriMessageStyle = NSMutableParagraphStyle()
            attriMessageStyle.lineSpacing = 5
            attriMessageStyle.alignment = .center
            attriMessageStyle.lineBreakMode = .byCharWrapping
            let attriMessage = NSAttributedString(
                string: message,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.color(hexRGB: 0x787878),
                    .paragraphStyle: attriMessageStyle
                ]
            )
            messageLabel.attributedText = attriMessage
            container.addSubview(messageLabel)
            messageLabel.snp.makeConstraints { make in
                if hasTitle {
                    make.top.equalTo(titleLabel.snp.bottom).offset(16)
                } else {
                    make.top.equalTo(container.snp.top).offset(28)
                }
                make.left.equalToSuperview().offset(padding)
                make.right.equalToSuperview().offset(-padding)
            }
        }
        
        let separator = UIView()
        separator.backgroundColor = separatorColor
        container.addSubview(separator)
        separator.snp.makeConstraints { make in
            if hasMessage {
                make.top.equalTo(messageLabel.snp.bottom).offset(28)
            } else if hasTitle {
                make.top.equalTo(titleLabel.snp.bottom).offset(28)
            } else {
                make.top.equalTo(container.snp.top)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo((hasTitle || hasMessage) ? separatorHeight : 0)
        }
        
        // action 按钮
        container.addSubview(actionStackView)
        let actionStackViewHeight = calculateActionStackViewHeight()
        actionStackView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(actionStackViewHeight)
            if cancelButton == nil {
                if preferredStyle == .alert {
                    make.bottom.equalToSuperview()
                } else {
                    make.bottom.equalTo(container.snp.bottomMargin).offset(-cornerRadiu)
                }
            }
        }
        
        guard let cancelButton = cancelButton else {
            return
        }
        // actionSheet最下方取消按钮
        let marginLine = UIView()
        marginLine.backgroundColor = UIColor.color(hexRGB: 0xF0F0F0)
        container.addSubview(marginLine)
        marginLine.snp.makeConstraints { make in
            make.top.equalTo(actionStackView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(10)
        }
        
        container.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(marginLine.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(actionHeight)
            make.bottom.equalTo(container.snp.bottomMargin).offset(-cornerRadiu)
        }
    }
    
    private func calculateActionStackViewHeight() -> CGFloat {
        let actionCountWithoutCancel = CGFloat(actions.count - (cancelButton != nil ? 1 : 0))
        guard actionCountWithoutCancel > 0 else {
            return 0
        }
        
        if preferredStyle == .actionSheet {
            actionStackView.axis = .vertical
            return actionCountWithoutCancel * actionHeight + (actionCountWithoutCancel - 1) * separatorHeight
        }
        
        // style 为 alert
        let actionStackViewHeight: CGFloat
        if actionCountWithoutCancel <= 2 {
            actionStackViewHeight = actionHeight
            actionStackView.axis = .horizontal
        } else {
            actionStackView.axis = .vertical
            actionStackViewHeight = actionCountWithoutCancel * actionHeight + (actionCountWithoutCancel - 1) * separatorHeight
        }
        return actionStackViewHeight
    }
    
    @objc private func tapToDismiss(_ tap: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @objc private func btnClickAction(_ btn: UIButton) {
        guard let action = btnToActionMap[btn] else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        dismiss(animated: true) {
            action.handler?(action)
        }
    }
}

extension CustomAlertController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return preferredStyle == .actionSheet
    }
}

extension CustomAlertController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAlertControllerTransitionAnimation(preferredStyle: preferredStyle)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAlertControllerTransitionAnimation(preferredStyle: preferredStyle)
    }
}

extension CustomAlertController: ZLCustomAlertProtocol {
    static func alert(title: String?, message: String, style: ZLCustomAlertStyle) -> ZLCustomAlertProtocol {
        return CustomAlertController(title: title, message: message, preferredStyle: style)
    }
    
    func addAction(_ action: ZLCustomAlertAction) {
        actions.append(action)
        
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .white
        btn.setTitle(action.title, for: .normal)
        btn.setTitleColor(action.style.color, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(btnClickAction(_:)), for: .touchUpInside)

        if action.style == .cancel, preferredStyle == .actionSheet {
            cancelButton = btn
        } else {
            actionStackView.addArrangedSubview(btn)
        }
        btnToActionMap[btn] = action
    }
    
    func show(with parentVC: UIViewController?) {
        parentVC?.showDetailViewController(self, sender: nil)
    }
}
