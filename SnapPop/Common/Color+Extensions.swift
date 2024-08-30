//
//  Color+Extensions.swift
//  SnapPop
//
//  Created by 정종원 on 8/13/24.
//

import UIKit

extension UIColor {
    static let customMainColor = UIColor(named: "customMain")
    static let customButtonColor = UIColor(named: "customButton")
    static let customBackgroundColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? .black : (UIColor(named: "customBackground") ?? .white)
    }
    static let customToggleColor = UIColor(named: "customToggle")
    static let dynamicTextColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
}
