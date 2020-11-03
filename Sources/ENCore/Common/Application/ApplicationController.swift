/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

/// @mockable
protocol ApplicationControlling {
    var isInBackground: Bool { get }
}

class ApplicationController: ApplicationControlling {
    var isInBackground: Bool {
        return UIApplication.shared.applicationState == .background
    }
}
