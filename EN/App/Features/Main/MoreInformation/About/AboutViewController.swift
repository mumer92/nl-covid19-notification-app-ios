/*
* Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// @mockable
protocol AboutViewControllable: ViewControllable {
    
}

final class AboutViewController: ViewController, AboutViewControllable {
    
    init(listener: AboutListener) {
        self.listener = listener
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Lifecycle
    
    override func loadView() {
        self.view = internalView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Implement or delete
    }
    
    // MARK: - Private
    
    private weak var listener: AboutListener?
    private lazy var internalView: AboutView = AboutView()
}

private final class AboutView: View {
    override func build() {
        super.build()
        
        // TODO: Construct View here or delete this function
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // TODO: Setup constraints here or delete this function
    }
}
