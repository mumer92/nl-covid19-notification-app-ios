/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import ENCore
import Foundation
import XCTest

final class InfectedInfoViewControllerTests: XCTestCase {
    private var viewController: InfectedInfoViewController!
    private let router = InfectedInfoRoutingMock()

    override func setUp() {
        super.setUp()

        let theme = ENTheme()

        viewController = InfectedInfoViewController(theme: theme)
        viewController.router = router
    }

    // TODO: Add tests
}
