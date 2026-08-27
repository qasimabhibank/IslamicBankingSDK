//
//  FPMurabahaApplicationModel.swift
//  Finca
//

import Foundation

struct FPMurabahaApplicationsResponse: Codable {
    let code: Int?
    let msg: String?
    let data: [FPMurabahaApplicationModel]?
    let logType: String?
    let refId: String?
}

struct FPMurabahaDeclarationResponse: Codable {
    let code: Int?
    let msg: String?
    let data: FPMurabahaDeclarationDataModel?
    let logType: String?
    let refId: String?
}

struct FPMurabahaDeclarationDataModel: Codable {
    let offerToPurchase: Bool?
    let applicationId: Int?
    let declaration: Bool?
    let updatedAt: String?
    let origin: String?
}

struct FPMurabahaApplicationModel: Codable {
    let applicantFatherName: String?
    let applicantName: String?
    let loanAmount: Int?
    let offerToPurchase: Bool?
    let purpose: FPMurabahaPurposeModel?
    let applicationId: Int?
    let cnicNumber: Int64?
    let createdAt: String?
    let documentStatus: FPMurabahaDocumentStatusModel?
    let declaration: Bool?

    enum CodingKeys: String, CodingKey {
        case applicantFatherName
        case applicantName
        case loanAmount
        case offerToPurchase
        case purpose
        case applicationId
        case cnicNumber
        case createdAt
        case documentStatus
        case declaration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        applicantFatherName = try container.decodeIfPresent(String.self, forKey: .applicantFatherName)
        applicantName = try container.decodeIfPresent(String.self, forKey: .applicantName)
        loanAmount = try container.decodeIfPresent(Int.self, forKey: .loanAmount)
        offerToPurchase = try container.decodeIfPresent(Bool.self, forKey: .offerToPurchase)
        applicationId = try container.decodeIfPresent(Int.self, forKey: .applicationId)
        cnicNumber = try container.decodeIfPresent(Int64.self, forKey: .cnicNumber)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        documentStatus = try container.decodeIfPresent(FPMurabahaDocumentStatusModel.self, forKey: .documentStatus)
        declaration = try container.decodeIfPresent(Bool.self, forKey: .declaration)

        // API may return purpose as an object, empty string, or plain string.
        if let purposeModel = try? container.decode(FPMurabahaPurposeModel.self, forKey: .purpose) {
            purpose = purposeModel
        } else if let purposeString = try? container.decode(String.self, forKey: .purpose),
                  !purposeString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            purpose = FPMurabahaPurposeModel(id: nil, name: purposeString)
        } else {
            purpose = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(applicantFatherName, forKey: .applicantFatherName)
        try container.encodeIfPresent(applicantName, forKey: .applicantName)
        try container.encodeIfPresent(loanAmount, forKey: .loanAmount)
        try container.encodeIfPresent(offerToPurchase, forKey: .offerToPurchase)
        try container.encodeIfPresent(purpose, forKey: .purpose)
        try container.encodeIfPresent(applicationId, forKey: .applicationId)
        try container.encodeIfPresent(cnicNumber, forKey: .cnicNumber)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(documentStatus, forKey: .documentStatus)
        try container.encodeIfPresent(declaration, forKey: .declaration)
    }
}

struct FPMurabahaPurposeModel: Codable {
    let id: Int?
    let name: String?
}

struct FPMurabahaDocumentStatusModel: Codable {
    let status: FPIslamicBankingProposalStatus?
    let label: String?
}

struct FPMurabahaInvoiceUploadResponse: Codable {
    let code: Int?
    let msg: String?
    let data: FPMurabahaInvoiceUploadDataModel?
    let logType: String?
    let refId: String?
}

struct FPMurabahaInvoiceUploadDataModel: Codable {
    let origin: String?
    let status: Int?
    let statusLabel: String?
    let id: Int?
    let remarks: String?
    let filePath: String?
    let applicationId: String?
    let name: String?
    let url: String?
}

extension FPMurabahaApplicationModel {

    var resolvedProposalId: String {
        guard let applicationId else { return "-" }
        return String(applicationId)
    }

    var resolvedTitle: String {
        let name = purpose?.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? "Murabaha Application" : name
    }

    var resolvedDate: String {
        guard let createdAt, !createdAt.isEmpty else { return "-" }
        return createdAt.toMurabahaDisplayDate()
    }

    var resolvedAmount: String {
        guard let loanAmount else { return "-" }
        return "PKR \(loanAmount.toString.toCurrencyFormat)"
    }

    var resolvedDocumentStatusLabel: String {
        let label = documentStatus?.label?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !label.isEmpty {
            return label
        }
        return proposalStatus.badgeTitle
    }

    /// Prefer API label when mapping UI/status behavior; keep raw enum for decoding.
    var proposalStatus: FPIslamicBankingProposalStatus {
        let label = documentStatus?.label?.lowercased() ?? ""

        if label.contains("reupload") || label.contains("re-upload") || label.contains("documents not uploaded") {
            return .reuploadRequired
        }
        if label.contains("complete") || label.contains("approved") {
            return .complete
        }
        if label.contains("not uploaded")
            || label.contains("documents uploaded")
            || label.contains("uploaded")
            || label.contains("in process")
            || label.contains("in progress") {
            return .inProgress
        }

        return documentStatus?.status ?? .inProgress
    }

    var needsDocumentReupload: Bool {
        let label = documentStatus?.label?.lowercased() ?? ""
        return label.contains("reupload") || label.contains("re-upload") || label.contains("documents not uploaded")
    }

    /// status 0 (Documents not uploaded) → allow invoice upload.
    /// status 1 (Documents uploaded) → disable invoice upload (dim).
    var canUploadInvoice: Bool {
        if let status = documentStatus?.status {
            switch status {
            case .reuploadRequired: // 0
                return true
            case .inProgress, .complete: // 1, 2
                return false
            }
        }

        let label = documentStatus?.label?.lowercased() ?? ""
        return label.contains("not uploaded")
            || label.contains("reupload")
            || label.contains("re-upload")
    }

    var isInvoiceUploadedOnServer: Bool {
        !canUploadInvoice
    }

    func toProposalItem() -> FPIslamicBankingProposalItem {
        FPIslamicBankingProposalItem(
            proposalId: resolvedProposalId,
            status: proposalStatus,
            title: resolvedTitle,
            date: resolvedDate,
            amount: resolvedAmount
        )
    }
}
