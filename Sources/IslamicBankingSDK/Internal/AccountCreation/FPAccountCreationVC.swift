//
//  FPAccountCreationVC.swift
//  Finca
//
//  Created by FINCA User on 01/07/2026.
//  Copyright © 2026 Finja. All rights reserved.
//

import UIKit

@objc
enum FPBankingModel: Int {
    case conventional = 0
    case islamic = 1
}

@objc
class FPAccountCreationVC: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var lblBankingModelTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var conventionalCardView: UIView!
    @IBOutlet weak var islamicCardView: UIView!
    @IBOutlet weak var conventionalRadioImageView: UIImageView!
    @IBOutlet weak var islamicRadioImageView: UIImageView!
    @IBOutlet weak var conventionalIconContainerView: UIView!
    @IBOutlet weak var islamicIconContainerView: UIView!
    @IBOutlet weak var conventionalTagsStackView: UIStackView!
    @IBOutlet weak var islamicTagsStackView: UIStackView!
    @IBOutlet weak var btnContinue: UIButton!

    // MARK: - Callbacks

    @objc var onContinue: ((FPBankingModel) -> Void)?
    @objc var onBack: (() -> Void)?

    // MARK: - Properties

    private var selectedModel: FPBankingModel = .conventional
    private let unselectedBorderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
    private let selectedBorderColor = IBResource.color("IslamicTeal") ?? UIColor(red: 0.263, green: 0.541, blue: 0.478, alpha: 1)

    // MARK: - Initialization

    convenience init() {
        self.init(nibName: "FPAccountCreationVC", bundle: .module)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCards()
        updateSelectionUI()
        updateContinueButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        // tab bar visibility handled by host
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnContinue.cornerRadius = 24
        
        //applyContinueButtonGradient()
    }

    // MARK: - Setup

    private func setupCards() {
        [conventionalCardView, islamicCardView].forEach { card in
            card?.layer.cornerRadius = 16
            card?.clipsToBounds = false
        }

        [conventionalIconContainerView, islamicIconContainerView].forEach { container in
            //container?.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
            container?.layer.cornerRadius = 12
            container?.clipsToBounds = true
        }

        [conventionalTagsStackView, islamicTagsStackView].forEach { stack in
            stack?.arrangedSubviews.forEach { pill in
                pill.layer.cornerRadius = 12
                pill.clipsToBounds = true
            }
        }

        [conventionalRadioImageView, islamicRadioImageView].forEach { radio in
            radio?.contentMode = .scaleAspectFit
        }
    }

    private func updateSelectionUI() {
        updateCard(conventionalCardView, radioImageView: conventionalRadioImageView, isSelected: selectedModel == .conventional)
        updateCard(islamicCardView, radioImageView: islamicRadioImageView, isSelected: selectedModel == .islamic)
    }

    private func updateCard(_ card: UIView?, radioImageView: UIImageView?, isSelected: Bool) {
        guard let card, let radioImageView else { return }

        if isSelected {
            card.layer.borderWidth = 2
            card.layer.borderColor = selectedBorderColor.cgColor
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.08
            card.layer.shadowOffset = CGSize(width: 0, height: 4)
            card.layer.shadowRadius = 12
            //card.backgroundColor = .white
            radioImageView.image = IBResource.image("checked-circle-big")
        } else {
            card.layer.borderWidth = 1
            card.layer.borderColor = unselectedBorderColor.cgColor
            card.layer.shadowOpacity = 0
            //card.backgroundColor = .white
            radioImageView.image = IBResource.image("unchecked-circle-big")
        }
    }

    private func updateContinueButtonState() {
        let isEnabled = selectedModel != nil
        btnContinue.isEnabled = isEnabled
        btnContinue.alpha = isEnabled ? 1.0 : 0.85
        //applyContinueButtonGradient()
    }

    private func applyContinueButtonGradient() {
        let enabledStart = IBResource.color("SecondaryBlue") ?? UIColor(red: 0.09, green: 0.165, blue: 0.275, alpha: 1)
        let enabledEnd = IBResource.color("PrimaryGreen") ?? UIColor(red: 0.369, green: 0.863, blue: 0.71, alpha: 1)
        let disabledStart = UIColor(red: 0.72, green: 0.76, blue: 0.76, alpha: 1)
        let disabledEnd = UIColor(red: 0.62, green: 0.74, blue: 0.72, alpha: 1)

        let colours = selectedModel != nil ? [enabledStart, enabledEnd] : [disabledStart, disabledEnd]
        btnContinue.applyGradient(colours: colours, cornerRadius: 24)
    }

    // MARK: - IBActions

    @IBAction func btnBackTapped(_ sender: UIButton) {
        if presentingViewController != nil {
            dismiss(animated: true) { [weak self] in
                self?.onBack?()
            }
        } else if let onBack {
            onBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func conventionalCardTapped(_ sender: UIButton) {
        selectedModel = .conventional
        updateSelectionUI()
        updateContinueButtonState()
    }

    @IBAction func islamicCardTapped(_ sender: UIButton) {
        selectedModel = .islamic
        updateSelectionUI()
        updateContinueButtonState()
    }

    @IBAction func btnContinueTapped(_ sender: UIButton) {
        //guard let selectedModel else { return }
        if presentingViewController != nil {
            dismiss(animated: true) {
//                self.onContinue?(self?.selectedModel)
                self.onContinue?(self.selectedModel)
            }
        } else {
            onContinue?(selectedModel)
        }
    }
}
