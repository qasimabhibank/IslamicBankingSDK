//
//  FPIslamicBankingAllSetPopupVC.swift
//  Finca
//

import UIKit

@objc(FPIslamicBankingAllSetPopupVC) class FPIslamicBankingAllSetPopupVC: FPIslamicBankingBaseVC {

    @IBOutlet weak var dimmedBackgroundView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var imgHero: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var btnBackToHome: UIButton!

    private let abhiGreen = IBResource.color("ABHIGreenColor")
        ?? UIColor(red: 0.141, green: 0.671, blue: 0.510, alpha: 1)
    private let cardColor = UIColor(red: 0.071, green: 0.133, blue: 0.176, alpha: 1)

    var onBackToHome: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }

    private func setupAppearance() {
        view.backgroundColor = .clear
        dimmedBackgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        cardView?.backgroundColor = cardColor
        cardView?.layer.cornerRadius = 24
        cardView?.clipsToBounds = true
        cardView?.layer.borderWidth = 1
        cardView?.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor

        imgHero?.image = IBResource.image("emoji-success-financing")
        imgHero?.contentMode = .scaleAspectFit

        lblTitle?.text = "All Set!"
        lblTitle?.font = UIFont(name: "Inter-Bold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold)
        lblTitle?.textColor = .white
        lblTitle?.textAlignment = .center

        lblSubtitle?.text = "You'll receive notifications for upcoming payments."
        lblSubtitle?.font = UIFont(name: "Inter-Regular", size: 14) ?? .systemFont(ofSize: 14)
        lblSubtitle?.textColor = UIColor(red: 0.722, green: 0.761, blue: 0.780, alpha: 1)
        lblSubtitle?.textAlignment = .center
        lblSubtitle?.numberOfLines = 0

        btnClose?.setImage(IBResource.image("crossIconWhite"), for: .normal)
        btnClose?.tintColor = .white

        setupBackToHomeButton()
    }

    private func setupBackToHomeButton() {
        btnBackToHome.setTitle("Back to Home", for: .normal)
        btnBackToHome.setTitleColor(.white, for: .normal)
        btnBackToHome.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        btnBackToHome.backgroundColor = abhiGreen
        btnBackToHome.layer.cornerRadius = 24
        btnBackToHome.clipsToBounds = true

        if #available(iOS 15.0, *) {
            var config = btnBackToHome.configuration ?? .plain()
            config.title = "Back to Home"
            config.baseForegroundColor = .white
            config.background.image = nil
            config.background.backgroundColor = abhiGreen
            config.background.cornerRadius = 24
            btnBackToHome.configuration = config
        }
    }

    @IBAction func btnCloseTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func btnBackToHomeTapped(_ sender: UIButton) {
        let completion = onBackToHome
        dismiss(animated: true) {
            completion?()
        }
    }
}
