//
//  Color+Extensions.swift
//  SnapPop
//
//  Created by 정종원 on 8/13/24.
//

import UIKit

extension UIColor {
    static let customMainColor = UIColor(red: 0.367, green: 0.312, blue: 1, alpha: 1)
    static let customButtonColor = UIColor(red: 0.367, green: 0.312, blue: 1, alpha: 1)
    static let customBackgroundColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0)
            : (UIColor(named: "customBackground") ?? .white)
    }
    static let customToggleColor = UIColor(red: 0.367, green: 0.312, blue: 1, alpha: 1)
    static let dynamicTextColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
    static let dynamicBackgroundInsideColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0) : .white
    }
    static let dynamicTextHolderColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) : .gray
    }
    static let segment = UIColor(red: 0.367, green: 0.312, blue: 1.1, alpha: 2)
    static let segmentColor: UIColor = {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            
            segment.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            let newSaturation = max(saturation - 0.01, 0)
            let newBrightness = min(brightness + 0.05, 1.0)
            
            return UIColor(hue: hue, saturation: newSaturation, brightness: newBrightness, alpha: 1.0)
        }()
    static let segmentSelected = UIColor(red: 0.367, green: 0.312, blue: 1.4, alpha: 1)

        // 세그먼트 컨트롤의 선택된 색상
        static let segmentSelectedColor: UIColor = {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            
            segmentSelected.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            let newSaturation = max(saturation - 0.18, 0)
            let newBrightness = min(brightness + 0.15, 1.0)
            
            return UIColor(hue: hue, saturation: newSaturation, brightness: newBrightness, alpha: 1.0)
        }()
}
