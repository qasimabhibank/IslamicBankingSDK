//
//  FPIslamicBankingMyProposalsVC.swift
//  Finca
//

import UIKit

@objc
class FPIslamicBankingMyProposalsVC: FPIslamicBankingBaseVC {

    @IBOutlet weak var navBarStackView: UIStackView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var proposalsTableView: UITableView!
    @IBOutlet weak var btnBack: UIButton!

    var proposals: [FPMurabahaApplicationModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        configureTableView()
    }

    private func setupNavigationBar() {
        lblTitle.text = "My Proposals"
        navBarStackView.constraints.filter { $0.firstAttribute == .height }.forEach {
            $0.constant = 56
        }
    }

    func updateProposals(_ items: [FPMurabahaApplicationModel]) {
        proposals = items
        proposalsTableView.reloadData()
    }

    private func configureTableView() {
        proposalsTableView.dataSource = self
        proposalsTableView.delegate = self
        proposalsTableView.separatorStyle = .none
        proposalsTableView.backgroundColor = .clear
        proposalsTableView.showsVerticalScrollIndicator = false
        proposalsTableView.rowHeight = UITableView.automaticDimension
        proposalsTableView.estimatedRowHeight = 240
        proposalsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        proposalsTableView.register(
            FPIslamicBankingProposalCell.self,
            forCellReuseIdentifier: FPIslamicBankingProposalCell.reuseIdentifier
        )
    }

    private func openProposalDetails(for item: FPMurabahaApplicationModel) {
        let identifier = item.proposalStatus.detailsStoryboardIdentifier
        pushProposalDetailScreen(withIdentifier: identifier, proposal: item)
    }
}

extension FPIslamicBankingMyProposalsVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        proposals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FPIslamicBankingProposalCell.reuseIdentifier,
            for: indexPath
        ) as? FPIslamicBankingProposalCell else {
            return UITableViewCell()
        }

        let item = proposals[indexPath.row]
        cell.configure(with: item) { [weak self] in
            self?.openProposalDetails(for: item)
        }
        return cell
    }
}

extension FPIslamicBankingMyProposalsVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openProposalDetails(for: proposals[indexPath.row])
    }
}
