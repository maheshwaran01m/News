//
//  NewsTableViewCell.swift
//  News
//
//  Created by MAHESHWARAN on 27/05/23.
//

import Foundation
import UIKit

class NewsTableViewCellViewModel {
  let title: String
  let subtitle: String
  let imageURL: URL?
  var imageData: Data? = nil
  
  init(title: String, subtitle: String, imageURL: URL?) {
    self.title = title
    self.subtitle = subtitle
    self.imageURL = imageURL
  }
}

class NewsTableViewCell: UITableViewCell {
  
  static let identifier = "NewsTableViewCell"
  
  private let newsTitleLabel: UILabel = {
    $0.numberOfLines = 3
    $0.font = .systemFont(ofSize: 20, weight: .semibold)
    return $0
  }(UILabel())
  
  private let subtitleLabel: UILabel = {
    $0.numberOfLines = 3
    $0.font = .systemFont(ofSize: 14, weight: .light)
    return $0
  }(UILabel())
  
  private let newsImageView: UIImageView = {
    $0.backgroundColor = .secondarySystemBackground
    $0.clipsToBounds = true
    $0.layer.masksToBounds = true
    $0.contentMode = .scaleAspectFill
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.cornerRadius = 15
    return $0
  }(UIImageView())
  
  // MARK: - Override Methods
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureView()
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureView()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    newsTitleLabel.frame = CGRect(x: 10, y: 0, width: contentView.frame.size.width - 200, height: 70)
    subtitleLabel.frame = CGRect(x: 10, y: 70, width: contentView.frame.size.width - 200, height: contentView.frame.size.height/2)
    newsImageView.frame = CGRect(x: contentView.frame.size.width-170, y: 3, width: 150, height: contentView.frame.size.height-10)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    newsTitleLabel.text = nil
    subtitleLabel.text = nil
    newsImageView.image = nil
  }
  
  private func configureView() {
    contentView.addSubview(newsTitleLabel)
    contentView.addSubview(subtitleLabel)
    contentView.addSubview(newsImageView)
  }
  
  // MARK: - Configue View
  
  func configure(with viewModel: NewsTableViewCellViewModel) {
    newsTitleLabel.text = viewModel.title
    subtitleLabel.text = viewModel.subtitle
    
    if let data = viewModel.imageData {
      newsImageView.image = UIImage(data: data)
    } else if let url = viewModel.imageURL {
      
      URLSession.shared.dataTask(with: url){ [weak self] data, _ ,error in
        guard let data, error == nil else { return }
        viewModel.imageData = data
        DispatchQueue.main.async {
          self?.newsImageView.image = UIImage(data: data)
        }
      }.resume()
    }
  }
}
