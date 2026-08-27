//
//  FPInvoiceUploadPopupVC.swift
//  Finca
//
//  Created by FINCA User on 01/07/2026.
//  Copyright © 2026 Finja. All rights reserved.
//

import UIKit

@objc(FPInvoiceUploadPopupVC) class FPInvoiceUploadPopupVC: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var dimmedBackgroundView: UIView!
    @IBOutlet weak var popupCardView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var contentContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var uploadStateView: UIView!
    @IBOutlet weak var imgUploadIcon: UIImageView!
    @IBOutlet weak var btnUploadInvoice: UIButton!
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var btnOpenCamera: UIButton!
    @IBOutlet weak var uploadedStateView: UIView!
    @IBOutlet weak var lblUploadedFileTitle: UILabel!
    @IBOutlet weak var fileRowView: UIView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var lblFileName: UILabel!
    @IBOutlet weak var lblFileSize: UILabel!
    @IBOutlet weak var btnRemoveFile: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnGoBack: UIButton!

    // MARK: - Callbacks

    @objc var onDone: ((UIImage) -> Void)?
    @objc var onGoBack: (() -> Void)?
    var onUploadSuccess: ((FPMurabahaInvoiceUploadDataModel) -> Void)?

    // MARK: - Properties

    var applicationId: Int?
    private let viewModel = FPMurabahaFinancingViewModel()
    private var isSubmitting = false
    private var selectedFileName = "invoice.jpg"
    private var uploadedInvoiceData: FPMurabahaInvoiceUploadDataModel?

    private var selectedImage: UIImage?
    private var imagePicker: UIImagePickerController?

    private let uploadStateHeight: CGFloat = 210
    private let uploadedStateHeight: CGFloat = 174
    private let goBackButtonHeight: CGFloat = 48

    // MARK: - Initialization

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
        lblFileName.lineBreakMode = .byTruncatingMiddle
        fileRowView.clipsToBounds = true
        contentContainerView.clipsToBounds = true
        imgThumbnail.layer.cornerRadius = 6
        imgThumbnail.clipsToBounds = true
        imgThumbnail.contentMode = .scaleAspectFill
        showUploadState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fileRowView.layer.cornerRadius = 10
    }

    // MARK: - State

    private func showUploadState() {
        selectedImage = nil
        selectedFileName = "invoice.jpg"
        uploadStateView.isHidden = false
        uploadedStateView.isHidden = true
        setGoBackVisible(true)
        contentContainerHeightConstraint.constant = uploadStateHeight
        view.layoutIfNeeded()
    }

    private func showUploadedState(image: UIImage, fileName: String, fileSizeText: String) {
        selectedImage = image
        selectedFileName = fileName
        imgThumbnail.image = image
        lblFileName.text = fileName
        lblFileSize.text = fileSizeText
        uploadStateView.isHidden = true
        uploadedStateView.isHidden = false
        setGoBackVisible(false)
        contentContainerHeightConstraint.constant = uploadedStateHeight
        view.layoutIfNeeded()
    }

    private func setGoBackVisible(_ visible: Bool) {
        btnGoBack.isHidden = !visible
        btnGoBack.constraints.filter { $0.firstAttribute == .height }.forEach {
            $0.constant = visible ? goBackButtonHeight : 0
        }
        // Collapse spacing above Go Back when hidden (content-box -> go back).
        popupCardView.constraints
            .filter { $0.firstItem as? UIView == btnGoBack && $0.firstAttribute == .top }
            .forEach { $0.constant = visible ? 20 : 0 }
    }

    // MARK: - Image Picker

    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }

        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = false
        imagePicker = picker
        present(picker, animated: true)
    }

    private func handleSelectedImage(_ image: UIImage, url: URL?) {
        let fileName = displayFileName(from: url)
        let sizeText = formattedFileSize(for: image)
        showUploadedState(image: image, fileName: fileName, fileSizeText: sizeText)
    }

    private func displayFileName(from url: URL?) -> String {
        guard let name = url?.lastPathComponent, !name.isEmpty else {
            return "img.jpg"
        }
        return name
    }

    private func formattedFileSize(for image: UIImage) -> String {
        let data = image.jpegData(compressionQuality: 0.9) ?? image.pngData()
        guard let data else { return "" }

        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(data.count))
    }

    // MARK: - IBActions

    @IBAction func btnUploadInvoiceTapped(_ sender: UIButton) {
        openImagePicker(sourceType: .photoLibrary)
    }

    @IBAction func btnOpenCameraTapped(_ sender: UIButton) {
        openImagePicker(sourceType: .camera)
    }

    @IBAction func btnRemoveFileTapped(_ sender: UIButton) {
        showUploadState()
    }

    @IBAction func btnDoneTapped(_ sender: UIButton) {
        guard let selectedImage, !isSubmitting else { return }

        guard let applicationId else {
            IBUI.showAlert(title: "", message: "Application ID is missing.")
            dismissPopup(shouldNotifyDone: false)
            return
        }

        isSubmitting = true
        btnDone.isEnabled = false

        viewModel.uploadMurabahaInvoice(
            applicationId: applicationId,
            invoiceImage: selectedImage,
            fileName: selectedFileName
        ) { [weak self] isSuccessful, response, message in
            guard let self else { return }

            self.isSubmitting = false
            self.btnDone.isEnabled = true

            if isSuccessful {
                self.uploadedInvoiceData = response?.data
            } else if let message, !message.isEmpty {
                IBUI.showAlert(title: "", message: message)
            }

            self.dismissPopup(shouldNotifyDone: isSuccessful)
        }
    }

    private func dismissPopup(shouldNotifyDone: Bool) {
        dismiss(animated: true) { [weak self] in
            guard let self, shouldNotifyDone else { return }

            if let uploadedInvoiceData = self.uploadedInvoiceData {
                self.onUploadSuccess?(uploadedInvoiceData)
            }

            if let selectedImage = self.selectedImage {
                self.onDone?(selectedImage)
            }
        }
    }

    @IBAction func btnGoBackTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.onGoBack?()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension FPInvoiceUploadPopupVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        imagePicker = nil
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self,
                  let image = info[.originalImage] as? UIImage else { return }
            let imageURL = info[.imageURL] as? URL
            self.handleSelectedImage(image, url: imageURL)
            self.imagePicker = nil
        }
    }
}
