import Foundation
import UIKit

final class FPMurabahaFinancingViewModel {

    private(set) var applicationsError: Observable<String?> = Observable(nil)
    private(set) var applicationsResponse: Observable<FPMurabahaApplicationsResponse?> = Observable(nil)

    private var networking: IslamicBankingNetworking { IslamicBanking.config.networking }
    private var auth: IslamicBankingAuthProviding { IslamicBanking.config.auth }
    private var noInternetMessage: String { IslamicBanking.config.noInternetMessage }

    func fetchMurabahaApplications(additionalParams: [String: Any] = [:]) {
        networking.performRequest(
            endpoint: .fetchApplications,
            parameters: additionalParams,
            headers: auth.islamicBankingHeaders(),
            showLoading: true
        ) { [weak self] json, message, isSuccessful in
            guard let self else { return }
            if isSuccessful {
                do {
                    guard let dict = json else {
                        self.applicationsError.value = "Invalid response format."
                        return
                    }
                    let response = try FPMurabahaApplicationsResponse(dict)
                    if response.code != 200 {
                        self.applicationsError.value = response.msg ?? "Something went wrong."
                        return
                    }
                    self.applicationsResponse.value = response
                } catch {
                    self.applicationsError.value = error.localizedDescription
                }
            } else {
                self.applicationsError.value = message ?? self.noInternetMessage
            }
        }
    }

    func updateMurabahaDeclaration(
        applicationId: Int,
        offerToPurchase: Bool,
        declaration: Bool,
        completion: @escaping (_ isSuccessful: Bool, _ message: String?) -> Void
    ) {
        let params: [String: Any] = [
            "applicationId": applicationId,
            "offerToPurchase": offerToPurchase,
            "declaration": declaration
        ]
        networking.performRequest(
            endpoint: .storeDeclaration,
            parameters: params,
            headers: auth.islamicBankingHeaders(),
            showLoading: true
        ) { json, message, isSuccessful in
            if isSuccessful {
                do {
                    guard let dict = json else {
                        completion(false, "Invalid response format.")
                        return
                    }
                    let response = try FPMurabahaDeclarationResponse(dict)
                    if response.code != 200 {
                        completion(false, response.msg ?? "Something went wrong.")
                        return
                    }
                    completion(true, response.msg)
                } catch {
                    completion(false, error.localizedDescription)
                }
            } else {
                completion(false, message)
            }
        }
    }

    func uploadMurabahaInvoice(
        applicationId: Int,
        invoiceImage: UIImage,
        fileName: String,
        completion: @escaping (_ isSuccessful: Bool, _ response: FPMurabahaInvoiceUploadResponse?, _ message: String?) -> Void
    ) {
        guard let imageBase64 = IBUI.base64String(from: invoiceImage, qualityPercentage: 50),
              !imageBase64.isEmpty else {
            completion(false, nil, "Unable to process the selected image.")
            return
        }

        let imageExtension = (fileName as NSString).pathExtension.lowercased()
        let params: [String: Any] = [
            "applicationId": applicationId,
            "imageName": (fileName as NSString).deletingPathExtension,
            "imageExt": imageExtension.isEmpty ? "jpg" : imageExtension,
            "invoice": imageBase64
        ]

        networking.performRequest(
            endpoint: .uploadInvoice,
            parameters: params,
            headers: auth.islamicBankingHeaders(),
            showLoading: true
        ) { json, message, isSuccessful in
            if isSuccessful {
                do {
                    guard let dict = json else {
                        completion(false, nil, "Invalid response format.")
                        return
                    }
                    let response = try FPMurabahaInvoiceUploadResponse(dict)
                    if response.code != 200 {
                        completion(false, response, response.msg ?? "Something went wrong.")
                        return
                    }
                    completion(true, response, response.msg)
                } catch {
                    completion(false, nil, error.localizedDescription)
                }
            } else {
                completion(false, nil, message)
            }
        }
    }

    func fetchMurabahaRepaymentPlan(
        applicationId: Int,
        completion: @escaping (_ isSuccessful: Bool, _ response: FPMurabahaRepaymentPlanResponse?, _ message: String?) -> Void
    ) {
        networking.performRequest(
            endpoint: .fetchRepaymentPlan,
            parameters: ["applicationId": applicationId],
            headers: auth.islamicBankingHeaders(),
            showLoading: true
        ) { json, message, isSuccessful in
            if isSuccessful {
                do {
                    guard let dict = json else {
                        completion(false, nil, "Invalid response format.")
                        return
                    }
                    let response = try FPMurabahaRepaymentPlanResponse(dict)
                    if response.code != 200 {
                        completion(false, response, response.msg ?? "Something went wrong.")
                        return
                    }
                    completion(true, response, response.msg)
                } catch {
                    completion(false, nil, error.localizedDescription)
                }
            } else {
                completion(false, nil, message)
            }
        }
    }
}
