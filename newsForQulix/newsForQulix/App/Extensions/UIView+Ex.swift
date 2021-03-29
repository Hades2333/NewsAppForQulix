//
//  UIView+Ex.swift
//  newsForQulix
//
//  Created by Hellizar on 29.03.21.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
}
