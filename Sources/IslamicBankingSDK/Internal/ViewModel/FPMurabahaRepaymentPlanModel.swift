//
//  FPMurabahaRepaymentPlanModel.swift
//  Finca
//
//  Created by Ahmad Nawaz on 03/07/2026.
//  Copyright © 2026 Finja. All rights reserved.
//

import Foundation

struct FPMurabahaRepaymentPlanResponse: Codable {
    let code: Int?
    let msg: String?
    let data: [FPMurabahaRepaymentPlanItemModel]?
    let logType: String?
    let refId: String?

    var primaryPlan: FPMurabahaRepaymentPlanItemModel? {
        data?.first
    }
}

struct FPMurabahaRepaymentPlanItemModel: Codable {
    let upfrontInsurance: Double?
    let osInstallFlag: String?
    let financeChgs: Double?
    let installmentChgs: Double?
    let tenor: Int?
    let markupAmt: Double?
    let businessProposalNo: String?
    let processingFee: Double?
    let insuranceRate: Double?
    let address: String?
    let startDate: String?
    let sessionId: String?
    let documentationCharges: Double?
    let clientAccountNo: String?
    let irrRate: String?
    let branch: String?
    let mobileNumber: String?
    let trackerChgs: Double?
    let financedAmount: Double?
    let frozenMarkup: Double?
    let name: String?
    let fed: Double?
    let principalAmt: Double?
    let status: String?
    let repayAccount: String?
    let installDueDate: String?
    let unitId: String?
    let principalRecv: Double?
    let installNo: Int?
    let insuranceRecv: Double?
    let financeChgsRecv: Double?
    let subProposalNo: Int?
    let installmentChgsRecv: Double?
    let osPrincipal: Double?
    let settlementDate: String?
    let insuranceAmt: Double?
    let trackerChgsRecv: Double?
    let relationID: String?
    let disbursementDate: String?
    let insuranceChgs: Double?
    let markupRecv: Double?
    let noOfReceipts: Int?
    let osMarkup: Double?
    let emiAmount: Double?

    enum CodingKeys: String, CodingKey {
        case upfrontInsurance = "upfront_Insurance"
        case osInstallFlag = "os_Install_Flag"
        case financeChgs = "finance_Chgs"
        case installmentChgs = "installment_Chgs"
        case tenor
        case markupAmt = "markup_Amt"
        case businessProposalNo = "business_Proposal_No"
        case processingFee = "processing_Fee"
        case insuranceRate = "insurance_Rate"
        case address
        case startDate = "start_Date"
        case sessionId = "session_Id"
        case documentationCharges = "documentation_Charges"
        case clientAccountNo = "client_Account_No"
        case irrRate = "irr_Rate"
        case branch
        case mobileNumber = "mobile_Number"
        case trackerChgs = "tracker_Chgs"
        case financedAmount = "financed_Amount"
        case frozenMarkup = "frozen_Markup"
        case name
        case fed
        case principalAmt = "principal_Amt"
        case status
        case repayAccount = "repay_Account"
        case installDueDate = "install_Due_Date"
        case unitId = "unit_Id"
        case principalRecv = "principal_Recv"
        case installNo = "install_No"
        case insuranceRecv = "insurance_Recv"
        case financeChgsRecv = "finance_Chgs_Recv"
        case subProposalNo = "sub_Proposal_No"
        case installmentChgsRecv = "installment_Chgs_Recv"
        case osPrincipal = "os_Principal"
        case settlementDate = "settlement_Date"
        case insuranceAmt = "insurance_Amt"
        case trackerChgsRecv = "tracker_Chgs_Recv"
        case relationID = "relation_ID"
        case disbursementDate = "disbursement_Date"
        case insuranceChgs = "insurance_Chgs"
        case markupRecv = "markup_Recv"
        case noOfReceipts = "no_Of_Receipts"
        case osMarkup = "os_Markup"
        case emiAmount = "emi_Amount"
    }
}

extension FPMurabahaRepaymentPlanItemModel {

    private func formattedAmount(_ value: Double?) -> String {
        guard let value else { return "-" }
        return String(value).toCurrencyFormat
    }

    var resolvedName: String {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "-" : trimmed
    }

    var resolvedCostText: String {
        formattedAmount(principalAmt ?? financedAmount)
    }

    var resolvedProfitText: String {
        formattedAmount(markupAmt)
    }

    var resolvedTotalText: String {
        formattedAmount(emiAmount)
    }

    var resolvedDisbursedAmountText: String {
        "PKR \(formattedAmount(financedAmount))"
    }

    var resolvedPrincipleText: String {
        formattedAmount(principalAmt)
    }

    var resolvedBankChargesText: String {
        formattedAmount(markupAmt)
    }

    var resolvedRepaymentAmountText: String {
        "PKR \(formattedAmount(emiAmount))"
    }

    var resolvedRepaymentAmountNumberText: String {
        formattedAmount(emiAmount)
    }
    
    var paymentplainAmount: String {
        formattedAmount(financedAmount)
    }

    var resolvedRepaymentDateText: String {
        guard let installDueDate, !installDueDate.isEmpty else { return "-" }
        return installDueDate.toMurabahaDisplayDate()
    }

    var resolvedFinancedAmountNumberText: String {
        formattedAmount(financedAmount)
    }

    var resolvedProfitRateText: String {
        let trimmed = irrRate?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "-" : trimmed
    }

    var resolvedAssetPurchaseDateText: String {
        guard let disbursementDate, !disbursementDate.isEmpty else { return "-" }
        return disbursementDate.toMurabahaDisplayDate()
    }

    var resolvedMaturityDateText: String {
        resolvedRepaymentDateText
    }

    var resolvedTenureText: String {
        guard let tenor, tenor > 0 else { return "-" }
        if tenor % 365 == 0 {
            let years = tenor / 365
            return years == 1 ? "1 Year" : "\(years) Years"
        }
        if tenor % 30 == 0 {
            let months = tenor / 30
            return months == 1 ? "1 Month" : "\(months) Months"
        }
        if tenor >= 28 {
            let months = max(1, Int((Double(tenor) / 30.0).rounded()))
            return months == 1 ? "1 Month" : "\(months) Months"
        }
        return "\(tenor) Days"
    }
}
