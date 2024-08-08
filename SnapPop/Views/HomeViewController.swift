//
//  HomeViewController.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/8/24.
//

import UIKit
import SwiftUI

extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let vc: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return vc
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
    
    func toPreview() -> some View {
        Preview(vc: self)
    }
}

class HomeViewController: NavigationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 250/255, green: 251/255, blue: 253/255, alpha: 1.0)
    }
}

#if DEBUG
struct HomeViewControllerPreview: PreviewProvider {
    static var previews: some View {
        UINavigationController(rootViewController: HomeViewController())
            .toPreview()
    }
}
#endif
