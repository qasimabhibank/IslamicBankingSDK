//
//  FPIslamicBankingPaymentCell.swift
//  Finca
//

import UIKit

@objc(FPIslamicBankingPaymentCell) class FPIslamicBankingPaymentCell: UITableViewCell {

    static let reuseIdentifier = "FPIslamicBankingPaymentCell"
    static let nibName = "FPIslamicBankingPaymentCell"

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var indexBadgeView: UIView!
    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var principalBoxView: UIView!
    @IBOutlet weak var lblPrincipalValue: UILabel!
    @IBOutlet weak var bankChargesBoxView: UIView!
    @IBOutlet weak var lblBankChargesValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView?.backgroundColor = UIColor(red: 0.071, green: 0.133, blue: 0.176, alpha: 1)
        cardView?.layer.cornerRadius = 12
        cardView?.layer.borderWidth = 1
        cardView?.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        cardView?.clipsToBounds = true

        indexBadgeView?.backgroundColor = IBResource.color("ABHIGreenColor")
            ?? UIColor(red: 0.141, green: 0.671, blue: 0.510, alpha: 1)
        indexBadgeView?.layer.cornerRadius = 8
        indexBadgeView?.clipsToBounds = true

        [principalBoxView, bankChargesBoxView].forEach { box in
            box?.backgroundColor = UIColor.white.withAlphaComponent(0.10)
            box?.layer.cornerRadius = 8
            box?.clipsToBounds = true
        }
    }

    func configure(with plan: FPMurabahaRepaymentPlanItemModel, index: Int) {
        lblIndex.text = "\(plan.installNo ?? (index + 1))"
        lblDate.text = plan.resolvedRepaymentDateText
        //lblAmount.text = plan.resolvedRepaymentAmountNumberText
        lblAmount.text = plan.paymentplainAmount
        lblPrincipalValue.text = plan.resolvedPrincipleText
        lblBankChargesValue.text = plan.resolvedBankChargesText
    }
}
