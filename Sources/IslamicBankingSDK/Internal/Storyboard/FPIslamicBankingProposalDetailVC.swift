//
//  FPIslamicBankingProposalDetailVC.swift
//  Finca
//

import UIKit

@objc(FPIslamicBankingProposalDetailVC) class FPIslamicBankingProposalDetailVC: FPIslamicBankingBaseVC {

    @IBOutlet weak var navBarStackView: UIStackView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var disbursedCardView: UIView!
    @IBOutlet weak var additionalInfoCardView: UIView!
    @IBOutlet weak var lblDisbursedAmount: UILabel!
    @IBOutlet weak var lblMonthlyInstallmentValue: UILabel!
    @IBOutlet weak var lblTenureValue: UILabel!
    @IBOutlet weak var lblProfitRateValue: UILabel!
    @IBOutlet weak var lblAssetPurchaseDateValue: UILabel!
    @IBOutlet weak var lblFirstDueValue: UILabel!
    @IBOutlet weak var lblMaturityValue: UILabel!
    @IBOutlet weak var lblPurposeValue: UILabel!
    @IBOutlet weak var paymentsTableView: UITableView!
    @IBOutlet weak var paymentsTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnCheckbox: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var acceptDimOverlayView: UIView!

    private let abhiGreen = IBResource.color("ABHIGreenColor")
        ?? UIColor(red: 0.141, green: 0.671, blue: 0.510, alpha: 1)
    private let cardColor = UIColor(red: 0.071, green: 0.133, blue: 0.176, alpha: 1)
    private let borderColor = UIColor.white.withAlphaComponent(0.12)

    private var repaymentPlanResponse: FPMurabahaRepaymentPlanResponse?
    private var proposal: FPMurabahaApplicationModel?
    private var paymentItems: [FPMurabahaRepaymentPlanItemModel] = []
    private var isCheckboxSelected = false
    private let viewModel = FPMurabahaFinancingViewModel()

    func configure(
        with repaymentPlanResponse: FPMurabahaRepaymentPlanResponse?,
        proposal: FPMurabahaApplicationModel? = nil
    ) {
        self.repaymentPlanResponse = repaymentPlanResponse
        self.proposal = proposal
        self.paymentItems = repaymentPlanResponse?.data ?? []

        if isViewLoaded {
            applyRepaymentPlanContent()
            reloadPaymentsTable()
            fetchRepaymentPlanIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupAppearance()
        setupPaymentsTable()
        setupAcceptButton()
        updateCheckboxAppearance()
        updateAcceptButtonState()
        applyRepaymentPlanContent()
        reloadPaymentsTable()
        fetchRepaymentPlanIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePaymentsTableHeight()
    }

    private func setupNavigationBar() {
        lblTitle.text = "Repayment Schedule"
        navBarStackView.constraints.filter { $0.firstAttribute == .height }.forEach {
            $0.constant = 56
        }
    }

    private func setupAppearance() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        disbursedCardView.layer.cornerRadius = 16
        disbursedCardView.clipsToBounds = true
        disbursedCardView.subviews
            .compactMap { $0 as? UIStackView }
            .filter { $0.axis == .horizontal }
            .forEach { stack in
                stack.arrangedSubviews.forEach { box in
                    box.layer.cornerRadius = 8
                    box.clipsToBounds = true
                }
            }

        additionalInfoCardView.backgroundColor = cardColor
        additionalInfoCardView.layer.cornerRadius = 16
        additionalInfoCardView.layer.borderWidth = 1
        additionalInfoCardView.layer.borderColor = borderColor.cgColor
        additionalInfoCardView.clipsToBounds = true

        acceptDimOverlayView?.layer.cornerRadius = 24
        acceptDimOverlayView?.clipsToBounds = true
        acceptDimOverlayView?.isUserInteractionEnabled = true
    }

    private func setupPaymentsTable() {
        let nib = UINib(nibName: FPIslamicBankingPaymentCell.nibName, bundle: .module)
        paymentsTableView.register(nib, forCellReuseIdentifier: FPIslamicBankingPaymentCell.reuseIdentifier)
        paymentsTableView.dataSource = self
        paymentsTableView.delegate = self
        paymentsTableView.backgroundColor = .clear
        paymentsTableView.separatorStyle = .none
        paymentsTableView.isScrollEnabled = false
        paymentsTableView.rowHeight = UITableView.automaticDimension
        paymentsTableView.estimatedRowHeight = 140
    }

    private func setupAcceptButton() {
        btnAccept.setTitle("Accept Repayment Schedule", for: .normal)
        btnAccept.setTitleColor(.white, for: .normal)
        btnAccept.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        btnAccept.backgroundColor = abhiGreen
        btnAccept.layer.cornerRadius = 24
        btnAccept.clipsToBounds = true

        if #available(iOS 15.0, *) {
            var config = btnAccept.configuration ?? .plain()
            config.title = "Accept Repayment Schedule"
            config.baseForegroundColor = .white
            config.background.image = nil
            config.background.backgroundColor = abhiGreen
            config.background.cornerRadius = 24
            btnAccept.configuration = config
        }
    }

    private func applyRepaymentPlanContent() {
        guard let plan = repaymentPlanResponse?.primaryPlan else {
            lblPurposeValue.text = proposal?.resolvedTitle ?? "-"
            lblDisbursedAmount.text = proposal?.resolvedAmount ?? "-"
            return
        }

        lblDisbursedAmount.text = plan.resolvedFinancedAmountNumberText
        lblMonthlyInstallmentValue.text = plan.resolvedRepaymentAmountNumberText
        lblTenureValue.text = plan.resolvedTenureText
        lblProfitRateValue.text = "\(plan.resolvedProfitRateText) p.a."
        lblAssetPurchaseDateValue.text = plan.resolvedAssetPurchaseDateText
        lblFirstDueValue.text = plan.resolvedRepaymentDateText
        lblMaturityValue.text = plan.resolvedMaturityDateText
        lblPurposeValue.text = proposal?.resolvedTitle ?? "-"
    }

    private func fetchRepaymentPlanIfNeeded() {
        guard repaymentPlanResponse == nil,
              let applicationId = proposal?.applicationId else { return }

        viewModel.fetchMurabahaRepaymentPlan(applicationId: applicationId) { [weak self] isSuccessful, response, message in
            guard let self else { return }

            if isSuccessful, let response {
                self.repaymentPlanResponse = response
                self.paymentItems = response.data ?? []
                self.applyRepaymentPlanContent()
                self.reloadPaymentsTable()
            } else if let message, !message.isEmpty {
                IBUI.showAlert(title: "", message: message)
            }
        }
    }

    private func reloadPaymentsTable() {
        if paymentItems.isEmpty, let primary = repaymentPlanResponse?.primaryPlan {
            paymentItems = [primary]
        }
        paymentsTableView.reloadData()
        view.layoutIfNeeded()
        updatePaymentsTableHeight()
    }

    private func updatePaymentsTableHeight() {
        paymentsTableView.layoutIfNeeded()
        let height = max(paymentsTableView.contentSize.height, 0)
        if paymentsTableHeightConstraint.constant != height {
            paymentsTableHeightConstraint.constant = height
        }
    }

    private func updateCheckboxAppearance() {
        let imageName = isCheckboxSelected ? "checkbox-checked-squre" : "checkbox-unchecked-squre"
        btnCheckbox.setImage(IBResource.image(imageName), for: .normal)
    }

    private func updateAcceptButtonState() {
        btnAccept.alpha = 1.0
        acceptDimOverlayView?.isHidden = isCheckboxSelected
        acceptDimOverlayView?.isUserInteractionEnabled = true
    }

    @IBAction func btnCheckboxTapped(_ sender: UIButton) {
        isCheckboxSelected.toggle()
        updateCheckboxAppearance()
        updateAcceptButtonState()
    }

    @IBAction func btnAcceptTapped(_ sender: UIButton) {
        guard isCheckboxSelected else { return }
        presentAllSetPopup { [weak self] in
            // Islamic Banking is presented modally from DashboardVC — dismiss to return home.
            self?.navigationController?.dismiss(animated: true)
        }
    }
}

extension FPIslamicBankingProposalDetailVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        paymentItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FPIslamicBankingPaymentCell.reuseIdentifier,
            for: indexPath
        ) as? FPIslamicBankingPaymentCell else {
            return UITableViewCell()
        }
        cell.configure(with: paymentItems[indexPath.row], index: indexPath.row)
        return cell
    }
}
