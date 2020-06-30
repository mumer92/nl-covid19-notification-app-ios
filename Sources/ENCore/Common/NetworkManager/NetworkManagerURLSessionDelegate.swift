/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Security

final class NetworkManagerURLSessionDelegate: NSObject, URLSessionDelegate {
    /// Initialise session delegate with certificate used for SSL pinning
    init(configurationProvider: NetworkConfigurationProvider) {
        self.configurationProvider = configurationProvider
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> ()) {

        guard
            let localSignature = configurationProvider.configuration.sslSignature(forHost: challenge.protectionSpace.host),
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust else {
            // no pinning
            completionHandler(.performDefaultHandling, nil)
            return
        }

        guard
            SecTrustEvaluateWithError(serverTrust, nil),
            SecTrustGetCertificateCount(serverTrust) > 0,
            let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
            let signature = Certificate(certificate: serverCertificate).signature else {
            // invalid server trust
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard localSignature == signature else {
            // signatures don't match
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // all good
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }

    // MARK: - Private

    private let configurationProvider: NetworkConfigurationProvider
}