//
//  ViewController.swift
//  News
//
//  Created by MAHESHWARAN on 27/05/23.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
  
  // MARK: - Outlets
  
  private lazy var tableView: UITableView = {
    $0.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
    return $0
  }(UITableView())
  
  private let searchVC = UISearchController(searchResultsController: nil)
  
  // MARK: - Private Property
  
  private var articles = [Article]()
  private var viewModels = [NewsTableViewCellViewModel]()
  
  // MARK: - Override
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
  }
  
  private func configureView() {
    title = "News"
    view.backgroundColor = .systemBackground
    configureTableView()
    createSearchBar()
    fetchTopStories()
  }
  
  private func configureTableView() {
    view.addSubview(tableView)
    tableView.tableFooterView = UIView()
    tableView.estimatedRowHeight = UITableView.automaticDimension
    tableView.delegate = self
    tableView.dataSource = self
    tableViewConstraint()
  }
  
  private func tableViewConstraint() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func createSearchBar() {
    navigationItem.searchController = searchVC
    searchVC.searchBar.delegate = self
    searchVC.searchBar.placeholder = "Search Trending"
    searchVC.searchBar.returnKeyType = .search
    if #available(iOS 16.0, *) {
      navigationItem.preferredSearchBarPlacement = .stacked
    }
  }
  
  private func fetchTopStories() {
    APICaller.shared.getTopStories{ [weak self] result in
      
      switch result {
      case.success(let articles):
        self?.articles = articles
        self?.viewModels = articles.compactMap({
          NewsTableViewCellViewModel(
            title: $0.title,
            subtitle: $0.description ?? "No Description",
            imageURL: URL(string: $0.urlToImage ?? ""))
        })
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
        
      case .failure(let error):
        print(error)
      }
    }
  }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModels.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier,
                                                   for: indexPath) as? NewsTableViewCell else {
      return UITableViewCell()
    }
    cell.configure(with: viewModels[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let article = articles[indexPath.row]
    guard let url = URL(string: article.url ?? "") else { return }
    
    let vc = SFSafariViewController(url: url)
    present(vc, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 150
  }
}

// MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let text = searchBar.text, !text.isEmpty  else { return }
    
    APICaller.shared.search(with: text){ [weak self] result in
      switch result {
      case.success(let articles):
        self?.articles = articles
        self?.viewModels = articles.compactMap({
          NewsTableViewCellViewModel(title: $0.title,
                                     subtitle: $0.description ?? "No Description",
                                     imageURL: URL(string: $0.urlToImage ?? ""))
        })
        DispatchQueue.main.async {
          self?.tableView.reloadData()
          self?.searchVC.dismiss(animated: true, completion: nil )
        }
      case .failure(let error):
        print(error)
      }
    }
  }
}
