//
//  CustomTableViewCell.swift
//  newsForQulix
//
//  Created by Hellizar on 29.03.21.
//

import UIKit
import SnapKit
import SDWebImage

final class CustomTableViewCell: UITableViewCell {

    //MARK: - Properties
    static let identifier = "CustomTableViewCell"

    //MARK: - GUI variables
    private let newsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .green
        return imageView
    }()

    private let newsTitle: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.text = "Заголовок новости"
        label.numberOfLines = 0
        return label
    }()

    private let newsDescription: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = "описание новости"
        label.numberOfLines = 3
        return label
    }()

    private let moreButton: UIButton = {
        let button = UIButton()
        button.setTitle("Show more", for: .normal)
        button.tintColor = .systemBlue
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()

    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .top
        stack.distribution = .fill
        stack.spacing = 10
        return stack
    }()

    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews([newsImage, verticalStack])
        verticalStack.addArrangedSubviews([newsTitle, newsDescription, moreButton])
        clipsToBounds = true
        selectionStyle = .none
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Methods
    func makeConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        let space = 10
        newsImage.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(space)
            make.width.equalTo(contentView.snp.width).multipliedBy(0.3)
            make.height.equalTo(newsImage.snp.width)
        }

        verticalStack.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(newsImage.snp.height)
            make.left.equalTo(newsImage.snp.right).offset(space)
            make.right.equalToSuperview().inset(space)
            make.top.bottom.equalToSuperview().inset(space)
        }
    }

    func configureCell(_ stringURL: String?,
                       _ title: String,
                       _ description: String) {
        let defaultURL = "https://via.placeholder.com/150/000000/FFFFFF/?text=IPaddress.net"

        guard let url = URL(string: stringURL ?? defaultURL) else {
            fatalError("Could not get image")
        }
        self.newsImage.sd_setImage(with: url, completed: nil)
        self.newsTitle.text = title
        self.newsDescription.text = description

        if newsDescription.isTruncated {
            moreButton.isHidden = false
        } else {
            moreButton.isHidden = true
        }
    }
}


