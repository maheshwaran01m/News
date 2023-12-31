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
  private var loaderView: UIAlertController?
  
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
    searchVC.searchBar.placeholder = "Search"
    searchVC.searchBar.returnKeyType = .search
    if #available(iOS 16.0, *) {
      navigationItem.preferredSearchBarPlacement = .stacked
    }
  }
  
  private func startLoaderView() {
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.style = .medium
    loadingIndicator.startAnimating()
    self.loaderView = alert
    alert.view.addSubview(loadingIndicator)
    present(alert, animated: true, completion: nil)
  }
  
  @objc func endRefreshing() {
    DispatchQueue.main.async {
      self.loaderView?.dismiss(animated: false)
    }
  }
  
  @objc private func fetchTopStories() {
    startLoaderView()
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
          self?.endRefreshing()
          self?.tableView.reloadData()
        }
        
      case .failure(let error):
        self?.endRefreshing()
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
    APICaller.shared.search(with: text,isFromNews: true) { [weak self] result in
      switch result {
      case.success(let articles):
        self?.articles = articles
        self?.viewModels = articles.compactMap({
          NewsTableViewCellViewModel(title: $0.title,
                                     subtitle: $0.description ?? "No Description",
                                     imageURL: URL(string: $0.urlToImage ?? ""))
        })
        DispatchQueue.main.async {
          self?.endRefreshing()
          self?.tableView.reloadData()
          self?.searchVC.dismiss(animated: true, completion: nil)
        }
      case .failure(let error):
        print(error)
        self?.endRefreshing()
      }
    }
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
    fetchTopStories()
  }
}
