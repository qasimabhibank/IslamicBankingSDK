//
//  FPIslamicBankingProposalDetailsVC.swift
//  Finca
//

import UIKit

@objc
class FPIslamicBankingProposalDetailsVC: FPIslamicBankingBaseVC {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var navBarStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var reuploadBannerView: UIView!
    @IBOutlet weak var proposalInfoCardView: UIView!
    @IBOutlet weak var btnDeclarationContinue: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnInvoiceContinue: UIButton!
    @IBOutlet weak var btnOfferContinue: UIButton!
    @IBOutlet weak var declarationCardView: UIView!
    @IBOutlet weak var invoiceCardView: UIView!
    @IBOutlet weak var offerCardView: UIView!
    @IBOutlet weak var declarationDimOverlayView: UIView!
    @IBOutlet weak var invoiceDimOverlayView: UIView!
    @IBOutlet weak var offerDimOverlayView: UIView!
    @IBOutlet weak var continueDimOverlayView: UIView!

    @IBOutlet weak var lblReuploadTitle: UILabel!
    @IBOutlet weak var lblReuploadMessage: UILabel!
    @IBOutlet weak var lblProposalId: UILabel!
    @IBOutlet weak var lblProposalType: UILabel!
    @IBOutlet weak var lblPurpose: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblCreationDate: UILabel!
    @IBOutlet weak var imgDeclarationStatus: UIImageView!
    @IBOutlet weak var imgInvoiceStatus: UIImageView!
    @IBOutlet weak var imgOfferStatus: UIImageView!

    var proposal: FPMurabahaApplicationModel?
    private let viewModel = FPMurabahaFinancingViewModel()
    private var repaymentPlanResponse: FPMurabahaRepaymentPlanResponse?
    private var isDeclarationSubmitted = false
    private var isInvoiceUploaded = false
    private var isOfferAccepted = false
    private var uploadedInvoiceData: FPMurabahaInvoiceUploadDataModel?

    private let abhiGreen = IBResource.color("ABHIGreenColor")
        ?? UIColor(red: 0.141, green: 0.671, blue: 0.510, alpha: 1)

    func configure(with proposal: FPMurabahaApplicationModel) {
        self.proposal = proposal
        if isViewLoaded {
            applyProposalContent()
            setupContinueButton()
            fetchMurabahaRepaymentPlan()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = "Proposal Details"
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        setupCardAppearance()
        setupContentStackViewIfNeeded()
        setupContinueButton()
        applyProposalContent()
        fetchMurabahaRepaymentPlan()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyProposalContent()
    }

    private func setupCardAppearance() {
        let cardColor = UIColor(red: 0.071, green: 0.133, blue: 0.176, alpha: 1)
        let nestedColor = UIColor(red: 0.051, green: 0.098, blue: 0.133, alpha: 1)
        let borderColor = UIColor.white.withAlphaComponent(0.12)

        proposalInfoCardView?.backgroundColor = cardColor
        proposalInfoCardView?.layer.cornerRadius = 16
        proposalInfoCardView?.layer.borderWidth = 1
        proposalInfoCardView?.layer.borderColor = borderColor.cgColor
        proposalInfoCardView?.clipsToBounds = true

        [declarationCardView, invoiceCardView, offerCardView].forEach { card in
            card?.backgroundColor = nestedColor
            card?.layer.cornerRadius = 12
            card?.layer.borderWidth = 1
            card?.layer.borderColor = borderColor.cgColor
            card?.clipsToBounds = true
        }

        [
            (declarationCardView, declarationDimOverlayView),
            (invoiceCardView, invoiceDimOverlayView),
            (offerCardView, offerDimOverlayView)
        ].forEach { card, overlay in
            guard let card, let overlay else { return }
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
            overlay.isUserInteractionEnabled = true
            card.bringSubviewToFront(overlay)
        }

        continueDimOverlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        continueDimOverlayView?.layer.cornerRadius = 24
        continueDimOverlayView?.clipsToBounds = true
        continueDimOverlayView?.isUserInteractionEnabled = true
        if let continueDimOverlayView, let btnContinue {
            btnContinue.superview?.bringSubviewToFront(continueDimOverlayView)
        }

        if let uploadDocumentsCard = invoiceCardView?.superview?.superview {
            uploadDocumentsCard.backgroundColor = cardColor
            uploadDocumentsCard.layer.cornerRadius = 16
            uploadDocumentsCard.layer.borderWidth = 1
            uploadDocumentsCard.layer.borderColor = borderColor.cgColor
            uploadDocumentsCard.clipsToBounds = true
        }
    }

    private func setupContentStackViewIfNeeded() {
        guard let contentStackView,
              let proposalInfoCardView else { return }

        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.setCustomSpacing(40, after: proposalInfoCardView)
    }

    private func fetchMurabahaRepaymentPlan() {
        guard let applicationId = proposal?.applicationId else { return }

        viewModel.fetchMurabahaRepaymentPlan(applicationId: applicationId) { [weak self] isSuccessful, response, message in
            guard let self else { return }

            if isSuccessful {
                self.repaymentPlanResponse = response
            } else if let message, !message.isEmpty {
                IBUI.showAlert(title: "", message: message)
            }
        }
    }

    private func applyProposalContent() {
        guard let reuploadBannerView else { return }

        mapProposalData()

        let canUploadInvoice = proposal?.canUploadInvoice == true
        let needsInvoiceAction = canUploadInvoice && !isInvoiceUploaded
        let isReuploadRequired = proposal?.needsDocumentReupload == true && !isInvoiceUploaded
        let isDeclarationDoneOnServer = proposal?.declaration ?? false
        let isOfferDoneOnServer = proposal?.offerToPurchase ?? false

        reuploadBannerView.isHidden = !isReuploadRequired

        // Keep all cards visible; dim + block interaction when not actionable.
        declarationCardView.isHidden = false
        invoiceCardView.isHidden = false
        offerCardView.isHidden = false
        btnDeclarationContinue.isHidden = false
        btnInvoiceContinue.isHidden = false
        btnOfferContinue.isHidden = false

        // Dim only when already completed on server and not completed in this session.
        // After a successful in-session action, keep overlay hidden so the completed button style is visible.
        declarationDimOverlayView.isHidden = !isDeclarationDoneOnServer || isDeclarationSubmitted
        // status 0 → enable invoice (no dim); status 1 → disable (dim). Hide dim after successful upload.
        invoiceDimOverlayView.isHidden = needsInvoiceAction || isInvoiceUploaded
        offerDimOverlayView.isHidden = !isOfferDoneOnServer || isOfferAccepted

        declarationDimOverlayView.isUserInteractionEnabled = true
        invoiceDimOverlayView.isUserInteractionEnabled = true
        offerDimOverlayView.isUserInteractionEnabled = true

        updateDocumentButtonsAppearance()
        updateContinueButtonAvailability()

        contentStackView?.layoutIfNeeded()
    }

    private var isDeclarationComplete: Bool {
        (proposal?.declaration ?? false) || isDeclarationSubmitted
    }

    private var isInvoiceComplete: Bool {
        (proposal?.isInvoiceUploadedOnServer == true) || isInvoiceUploaded
    }

    private var isOfferComplete: Bool {
        (proposal?.offerToPurchase ?? false) || isOfferAccepted
    }

    private var areAllDocumentsComplete: Bool {
        isDeclarationComplete && isInvoiceComplete && isOfferComplete
    }

    private func updateDocumentButtonsAppearance() {
        if isDeclarationSubmitted {
            applyCompletedDocumentButtonStyle(to: btnDeclarationContinue, title: "Signed")
        } else {
            applyActiveDocumentButtonStyle(to: btnDeclarationContinue, title: "Sign Declaration")
        }
        forceDocumentButtonTitleWhite(btnDeclarationContinue)

        if isInvoiceUploaded {
            applyCompletedDocumentButtonStyle(to: btnInvoiceContinue, title: "Uploaded")
        } else {
            // Keep ABHI green under dim when invoice is already uploaded on server (e.g. from My Proposals).
            applyActiveDocumentButtonStyle(to: btnInvoiceContinue, title: "Upload File")
        }
        forceDocumentButtonTitleWhite(btnInvoiceContinue)

        if isOfferAccepted {
            applyCompletedDocumentButtonStyle(to: btnOfferContinue, title: "Accepted")
        } else {
            applyActiveDocumentButtonStyle(to: btnOfferContinue, title: "Make an Offer")
        }
        forceDocumentButtonTitleWhite(btnOfferContinue)
    }

    private func forceDocumentButtonTitleWhite(_ button: UIButton?) {
        guard let button else { return }

        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.setTitleColor(.white, for: .disabled)
        button.setTitleColor(.white, for: .selected)
        button.tintColor = .white

        if #available(iOS 15.0, *) {
            if var config = button.configuration {
                config.baseForegroundColor = .white
                config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.foregroundColor = .white
                    return outgoing
                }
                button.configuration = config
            }

            button.configurationUpdateHandler = { btn in
                guard var config = btn.configuration else { return }
                config.baseForegroundColor = .white
                config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.foregroundColor = .white
                    return outgoing
                }
                btn.configuration = config
            }
        }
    }

    private func applyActiveDocumentButtonStyle(to button: UIButton?, title: String) {
        guard let button else { return }

        button.isEnabled = true

        if #available(iOS 15.0, *) {
            var config = button.configuration ?? UIButton.Configuration.plain()
            config.title = title
            config.background.image = nil
            config.background.backgroundColor = abhiGreen
            config.baseForegroundColor = .white
            config.background.cornerRadius = 12
            button.configuration = config
        } else {
            button.setTitle(title, for: .normal)
            button.setBackgroundImage(nil, for: .normal)
            button.backgroundColor = abhiGreen
            button.setTitleColor(.white, for: .normal)
        }

        button.layer.cornerRadius = 12
        button.clipsToBounds = true
    }

    private func applyCompletedDocumentButtonStyle(to button: UIButton?, title: String) {
        guard let button else { return }

        let completedBackground = UIColor.white.withAlphaComponent(0.10)
        let completedTextColor = UIColor.white

        button.isEnabled = false

        if #available(iOS 15.0, *) {
            var config = button.configuration ?? UIButton.Configuration.plain()
            config.title = title
            config.background.image = nil
            config.background.backgroundColor = completedBackground
            config.baseForegroundColor = completedTextColor
            config.background.cornerRadius = 12
            button.configuration = config
        } else {
            button.setTitle(title, for: .normal)
            button.setBackgroundImage(nil, for: .normal)
            button.backgroundColor = completedBackground
            button.setTitleColor(completedTextColor, for: .normal)
        }

        button.layer.cornerRadius = 12
        button.clipsToBounds = true
    }

    private func mapProposalData() {
        guard let proposal else { return }

        lblReuploadTitle.text = uploadedInvoiceData?.statusLabel
            ?? proposal.resolvedDocumentStatusLabel

        let uploadedRemarks = uploadedInvoiceData?.remarks?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        lblReuploadMessage.text = uploadedRemarks.isEmpty
            ? (proposal.documentStatus?.label ?? "Invoice date mismatch. Please upload correct invoice matching the offer date.")
            : uploadedRemarks

        lblProposalId.text = proposal.resolvedProposalId
        lblProposalType.text = "Murabaha Financing"
        lblPurpose.text = proposal.resolvedTitle
        lblAmount.text = proposal.resolvedAmount
        lblCreationDate.text = proposal.resolvedDate

        imgDeclarationStatus.image = IBResource.image("decleration-icon")
        imgInvoiceStatus.image = IBResource.image("invoice-icon")
        imgOfferStatus.image = IBResource.image("offer-purchase-icon")
    }

    private func stepStatusImage(isComplete: Bool) -> UIImage? {
        isComplete
            ? FPIslamicBankingProposalStatus.complete.iconImage
            : FPIslamicBankingProposalStatus.inProgress.iconImage
    }
    
    private func setupContinueButton() {
        if #available(iOS 15.0, *) {
            var config = btnContinue.configuration ?? .plain()
            config.title = "Continue"
            config.baseForegroundColor = .white
            config.background.image = nil
            config.background.backgroundColor = abhiGreen
            config.background.cornerRadius = 24
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
                return outgoing
            }
            btnContinue.configuration = config
        } else {
            btnContinue.setTitle("Continue", for: .normal)
            btnContinue.setTitleColor(.white, for: .normal)
            btnContinue.backgroundColor = abhiGreen
            btnContinue.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        }

        btnContinue.constraints.filter { $0.firstAttribute == .height }.forEach { $0.constant = 48 }
        btnContinue.layer.cornerRadius = 24
        btnContinue.clipsToBounds = true
        updateContinueButtonAvailability()
    }

    private func updateContinueButtonAvailability() {
        let isEnabled = areAllDocumentsComplete
        btnContinue.isEnabled = isEnabled
        continueDimOverlayView?.isHidden = isEnabled
        continueDimOverlayView?.isUserInteractionEnabled = !isEnabled
        if let continueDimOverlayView, let btnContinue {
            btnContinue.superview?.bringSubviewToFront(continueDimOverlayView)
        }
    }

    @IBAction func btnDeclarationContinueTapped(_ sender: UIButton) {
        guard !isDeclarationComplete else { return }
        presentDeclarationPopup()
    }

    @IBAction func btnInvoiceContinueTapped(_ sender: UIButton) {
        guard !isInvoiceComplete else { return }
        guard proposal?.canUploadInvoice == true else { return }
        presentInvoicePopup()
    }

    @IBAction func btnOfferContinueTapped(_ sender: UIButton) {
        guard !isOfferComplete else { return }
        presentOfferPopup()
    }
    
    @IBAction func btnContinueTapped(_ sender: UIButton) {
        guard areAllDocumentsComplete else { return }

        guard let repaymentPlanResponse else {
            IBUI.showAlert(title: "", message: "Repayment plan is not available.")
            return
        }

        pushIslamicBankingSuccessScreen(
            repaymentPlanResponse: repaymentPlanResponse,
            proposal: proposal
        )
    }

    private func presentDeclarationPopup() {
        guard let proposal else { return }

        let popup = FPDeclarationOfPurchasePopupVC(nibName: "FPDeclarationOfPurchasePopupVC", bundle: .module)
        popup.applicationId = proposal.applicationId
        
        var offerval = false
        if isOfferAccepted == false {
            offerval = proposal.offerToPurchase ?? false
        }
        popup.isOfferToPurchaseAlreadyDone = offerval
        
        popup.dateText = proposal.resolvedDate
        popup.natureOfGoods = proposal.resolvedTitle
        popup.purchasePrice = proposal.resolvedAmount
        popup.totalPrice = proposal.resolvedAmount
        popup.confirmeeName = proposal.applicantName ?? "-"
        if let fatherName = proposal.applicantFatherName, !fatherName.isEmpty {
            popup.confirmeeRelation = "S/o \(fatherName)"
        } else {
            popup.confirmeeRelation = "-"
        }
        popup.onSubmit = { [weak self] in
            self?.isDeclarationSubmitted = true
            self?.applyProposalContent()
        }
        popup.onGoBack = nil
        present(popup, animated: true)
    }

    private func presentInvoicePopup() {
        guard let proposal else { return }

        let popup = FPInvoiceUploadPopupVC(nibName: "FPInvoiceUploadPopupVC", bundle: .module)
        popup.applicationId = proposal.applicationId
        popup.onUploadSuccess = { [weak self] uploadData in
            self?.uploadedInvoiceData = uploadData
            self?.isInvoiceUploaded = true
            self?.applyProposalContent()
        }
        popup.onDone = nil
        popup.onGoBack = nil
        present(popup, animated: true)
    }

    private func presentOfferPopup() {
        let popup = FPOfferToPurchasePopupVC(nibName: "FPOfferToPurchasePopupVC", bundle: .module)
        popup.applicationId = proposal?.applicationId
        
        var delceration = false
        if isDeclarationSubmitted == false {
            delceration = proposal?.declaration ?? false
        }
        popup.isDeclarationAlreadyDone = delceration

        if let proposal {
            popup.nameText = proposal.applicantName ?? "-"
            if let fatherName = proposal.applicantFatherName, !fatherName.isEmpty {
                popup.relationText = "S/o \(fatherName)"
            } else {
                popup.relationText = "-"
            }
            popup.goodsText = proposal.resolvedTitle
            popup.dateText = proposal.resolvedDate
        }

        if let repaymentPlan = repaymentPlanResponse?.primaryPlan {
            if popup.nameText == "-" || popup.nameText.isEmpty {
                popup.nameText = repaymentPlan.resolvedName
            }
            popup.dateText = repaymentPlan.resolvedRepaymentDateText
            popup.goodsText = proposal?.resolvedTitle ?? "As per invoice"
            popup.costText = repaymentPlan.resolvedCostText
            popup.profitText = repaymentPlan.resolvedProfitText
            popup.totalText = repaymentPlan.resolvedTotalText
        }

        popup.onAccept = { [weak self] in
            guard let self else { return }
            self.isOfferAccepted = true
            self.applyProposalContent()
        }
        popup.onGoBack = nil
        present(popup, animated: true)
    }
}
