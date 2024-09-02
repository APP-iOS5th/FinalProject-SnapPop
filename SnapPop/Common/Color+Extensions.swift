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
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0)
            : (UIColor(named: "customBackground") ?? .white)
    }
    static let customToggleColor = UIColor(named: "customToggle")
    static let dynamicTextColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
    static let dynamicBackgroundInsideColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0) : .white
    }
    static let dynamicTextHolderColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) : .gray
    }
    
    
    
    
}
