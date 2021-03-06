/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Combine
import ENFoundation
import Foundation
import UserNotifications

final class ExpiredLabConfirmationNotificationDataOperation: ExposureDataOperation, Logging {

    init(storageController: StorageControlling,
         userNotificationCenter: UserNotificationCenter) {
        self.storageController = storageController
        self.userNotificationCenter = userNotificationCenter
    }

    // MARK: - ExposureDataOperation

    func execute() -> AnyPublisher<(), ExposureDataError> {
        let expiredRequests = getPendingRequests()
            .filter { $0.isExpired }

        if !expiredRequests.isEmpty {
            notifyUser()
        }

        logDebug("Expired requests: \(expiredRequests)")

        return removeExpiredRequestsFromStorage(expiredRequests: expiredRequests)
            .setFailureType(to: ExposureDataError.self)
            .share()
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func getPendingRequests() -> [PendingLabConfirmationUploadRequest] {
        return storageController.retrieveObject(identifiedBy: ExposureDataStorageKey.pendingLabUploadRequests) ?? []
    }

    private func removeExpiredRequestsFromStorage(expiredRequests: [PendingLabConfirmationUploadRequest]) -> AnyPublisher<(), Never> {
        return Deferred {
            Future { promise in
                self.storageController.requestExclusiveAccess { storageController in

                    // get stored pending requests
                    let previousRequests = storageController
                        .retrieveObject(identifiedBy: ExposureDataStorageKey.pendingLabUploadRequests) ?? []

                    let requestsToStore = previousRequests.filter { request in
                        expiredRequests.contains(request) == false
                    }

                    self.logDebug("Storing new pending requests: \(requestsToStore)")

                    // store back
                    storageController.store(object: requestsToStore, identifiedBy: ExposureDataStorageKey.pendingLabUploadRequests) { _ in
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func notifyUser() {
        func notify() {
            let content = UNMutableNotificationContent()
            content.sound = UNNotificationSound.default
            content.body = .notificationUploadFailedNotification
            content.badge = 0

            let request = UNNotificationRequest(identifier: PushNotificationIdentifier.uploadFailed.rawValue,
                                                content: content,
                                                trigger: getCalendarTriggerForGGDOpeningHourIfNeeded())

            userNotificationCenter.add(request) { error in
                if let error = error {
                    self.logError("\(error.localizedDescription)")
                }
            }
        }

        userNotificationCenter.getAuthorizationStatus { status in
            guard status == .authorized else {
                self.logError("Cannot notify user `authorizationStatus`: \(status)")
                return
            }
            notify()
        }
    }

    /// Generates a UNCalendarNotificationTrigger if the current time is outside the GGD working hours
    func getCalendarTriggerForGGDOpeningHourIfNeeded() -> UNCalendarNotificationTrigger? {

        let date = currentDate()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)

        if hour > 20 || hour < 8 {

            var dateComponents = DateComponents()
            dateComponents.hour = 8
            dateComponents.minute = 0
            dateComponents.timeZone = TimeZone(identifier: "Europe/Amsterdam")
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        }

        return nil
    }

    private let storageController: StorageControlling
    private let userNotificationCenter: UserNotificationCenter
}

extension PendingLabConfirmationUploadRequest {
    var isExpired: Bool {
        return expiryDate < Date()
    }
}
