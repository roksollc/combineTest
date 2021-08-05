//
//  UIView+safeArea.swift
//  HarryPotterProducts
//

import UIKit
import SnapKit

enum SafeAreaEdge {
    case top, bottom, left, right
}

extension UIView {
    func safeArea(_ edge: SafeAreaEdge) -> ConstraintItem {
        switch edge {
        case .bottom:   return safeAreaLayoutGuide.snp.bottom
        case .top:      return safeAreaLayoutGuide.snp.top
        case .left:     return safeAreaLayoutGuide.snp.left
        case .right:    return safeAreaLayoutGuide.snp.right
        }
    }
}
