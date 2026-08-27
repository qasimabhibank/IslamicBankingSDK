//
//  FPIslamicBankingCNICVC.swift
//  Finca
//

import UIKit

@objc
class FPIslamicBankingCNICVC: FPIslamicBankingBaseVC {

    @IBOutlet weak var navBarStackView: UIStackView!
    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var lblScreenTitle: UILabel!
    @IBOutlet weak var lblFieldTitle: UILabel!
    @IBOutlet weak var txtCNIC: UITextField!
    @IBOutlet weak var lblHint: UILabel!
    @IBOutlet weak var noteContainerView: UIView!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnContinueBottomConstraint: NSLayoutConstraint!

    private var keyboardAdjuster: IBKeyboardBottomConstraintAdjuster?
    private let secondaryTextColor = UIColor(red: 0.722, green: 0.761, blue: 0.780, alpha: 1)
    private let fieldBackgroundColor = UIColor(red: 0.071, green: 0.133, blue: 0.176, alpha: 1)
    private let fieldBorderColor = UIColor(red: 0.353, green: 0.420, blue: 0.459, alpha: 0.55)
    private let noteBackgroundColor = UIColor(red: 0.078, green: 0.157, blue: 0.200, alpha: 1)
    private let notePrefixColor = UIColor(red: 0.957, green: 0.620, blue: 0.043, alpha: 1)
    private let noteBodyColor = UIColor(red: 0.780, green: 0.800, blue: 0.820, alpha: 1)
    private let continueEnabledColor = UIColor(red: 0.141, green: 0.671, blue: 0.510, alpha: 1)
    private let continueDisabledColor = UIColor(red: 0.239, green: 0.420, blue: 0.400, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupContent()
        setupCNICField()
        setupNoteSection()
        setupContinueButton()

        if let btnContinueBottomConstraint {
            keyboardAdjuster = IBKeyboardBottomConstraintAdjuster(
                bottomConstraint: btnContinueBottomConstraint,
                hostView: view,
                defaultConstant: 26
            )
        }
    }

    @IBAction func btnContinueTapped(_ sender: UIButton) {
        let cnic = txtCNIC.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard cnic.count == 13 else {
            showAlert(title: "CNIC Required", message: "Please enter a valid 13-digit CNIC number.")
            return
        }
        pushIslamicBankingScreen(withIdentifier: "FPIslamicBankingMyProposalsVC")
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        lblNavTitle.text = "CNIC"
        lblNavTitle.font = UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .semibold)
        lblNavTitle.textColor = .white

        navBarStackView.constraints.filter { $0.firstAttribute == .height }.forEach {
            $0.constant = 56
        }
    }

    private func setupContent() {
        lblScreenTitle.font = UIFont(name: "Inter-SemiBold", size: 18) ?? .systemFont(ofSize: 18, weight: .semibold)
        lblScreenTitle.textColor = .white
        lblScreenTitle.text = "Enter Your CNIC"

        lblFieldTitle.font = UIFont(name: "Inter-Medium", size: 12) ?? .systemFont(ofSize: 12, weight: .medium)
        lblFieldTitle.textColor = secondaryTextColor
        lblFieldTitle.text = "CNIC NUMBER"

        lblHint.font = UIFont.systemFont(ofSize: 11)
        lblHint.textColor = secondaryTextColor
        lblHint.text = "Enter 13-digit CNIC without dashes"
    }

    private func setupCNICField() {
        txtCNIC.delegate = self
        txtCNIC.keyboardType = .numberPad
        txtCNIC.borderStyle = .none
        txtCNIC.placeholder = ""
        txtCNIC.font = UIFont(name: "Inter-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium)
        txtCNIC.textColor = .white
        txtCNIC.tintColor = .white
        txtCNIC.backgroundColor = fieldBackgroundColor
        txtCNIC.layer.cornerRadius = 10
        txtCNIC.layer.borderWidth = 1
        txtCNIC.layer.borderColor = fieldBorderColor.cgColor
        txtCNIC.clipsToBounds = true

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        txtCNIC.leftView = paddingView
        txtCNIC.leftViewMode = .always

        txtCNIC.constraints.filter { $0.firstAttribute == .height }.forEach {
            $0.constant = 48
        }

        txtCNIC.addTarget(self, action: #selector(cnicTextDidChange), for: .editingChanged)
        updateContinueButtonState()
    }

    private func setupNoteSection() {
        noteContainerView.backgroundColor = noteBackgroundColor
        noteContainerView.layer.cornerRadius = 10
        noteContainerView.layer.borderWidth = 0
        noteContainerView.clipsToBounds = true

        let notePrefix = "Note:"
        let noteBody = " Only proposals associated with this CNIC will be displayed"
        let attributed = NSMutableAttributedString(
            string: notePrefix,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: notePrefixColor
            ]
        )
        attributed.append(NSAttributedString(
            string: noteBody,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: noteBodyColor
            ]
        ))
        lblNote.attributedText = attributed
        lblNote.numberOfLines = 0
    }

    private func setupContinueButton() {
        btnContinue.setTitle("Continue", for: .normal)
        btnContinue.setTitleColor(.white, for: .normal)
        btnContinue.setTitleColor(.white, for: .disabled)
        btnContinue.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        btnContinue.constraints.filter { $0.firstAttribute == .height }.forEach {
            $0.constant = 48
        }
        btnContinue.layer.cornerRadius = 24
        btnContinue.clipsToBounds = true
        updateContinueButtonState()
    }

    @objc private func cnicTextDidChange() {
        updateContinueButtonState()
    }

    private func updateContinueButtonState() {
        let digits = txtCNIC.text?.filter(\.isNumber) ?? ""
        let isValid = digits.count == 13
        btnContinue.isEnabled = isValid
        btnContinue.backgroundColor = isValid ? continueEnabledColor : continueDisabledColor
        btnContinue.alpha = 1
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension FPIslamicBankingCNICVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowed = CharacterSet.decimalDigits
        guard string.unicodeScalars.allSatisfy({ allowed.contains($0) }) || string.isEmpty else { return false }

        let current = textField.text ?? ""
        guard let textRange = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: textRange, with: string)
        return updated.filter(\.isNumber).count <= 13
    }
}
