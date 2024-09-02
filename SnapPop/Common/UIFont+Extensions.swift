//
//  UIFont+Extensions.swift
//  SnapPop
//
//  Created by 장예진 on 9/2/24.
//
// -MARK: Launch Screen, SigninView 에서는 ExtraBold 사용함
import UIKit

extension UIFont {
    
    static func balooChettanRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "BalooChettan2-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func balooChettanMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "BalooChettan2-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    static func balooChettanSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "BalooChettan2-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    static func balooChettanBold(size: CGFloat) -> UIFont {
        return UIFont(name: "BalooChettan2-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    static func balooChettanExtraBold(size: CGFloat) -> UIFont {
        return UIFont(name: "BalooChettan2-ExtraBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
    }
}


