//
//  UIStackView+Ex.swift
//  newsForQulix
//
//  Created by Hellizar on 29.03.21.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
}
