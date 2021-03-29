//
//  NewsViewController.swift
//  newsForQulix
//
//  Created by Hellizar on 29.03.21.
//

import UIKit
import SnapKit
import SDWebImage

class NewsViewController: UIViewController {

    //MARK: - Properties
    var parsedModel: [myModel] = []
    var filteredModel: [myModel] = []

    //MARK: - GUI Variables
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchTextField.textColor = .white
        return searchBar
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()

        tableView.register(CustomTableViewCell.self,
                           forCellReuseIdentifier: CustomTableViewCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()

    private let myRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(refresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = .black
        return refreshControl
    }()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearhBar()
        sendRequest()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    //MARK: - Network
    private func sendRequest() {
        NetworkManager.shared.request(pagination: true, successHandler: {
            [weak self] (model: Welcome) in
            guard let self = self else { return }

            self.tableView.tableFooterView = self.createSpinnerFooter()

            if model.articles.count == 0 {
                let alert = UIAlertController(title: "Attention",
                                              message: """
                                                       Unfortunately there was no news today,
                                                       but you can check news for the previous day.
                                                       """,
                                              preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                    self?.tableView.tableFooterView = nil
                }))
            }
            for element in 0..<model.articles.count {
                self.parsedModel.append(myModel(urlToImage: model.articles[element].urlToImage,
                                                title: model.articles[element].title ?? "",
                                                articleDescription: model.articles[element].articleDescription ?? ""))
            }
            self.tableView.reloadData()
        },
        errorHandler: { (error: NetworkError) in
            fatalError(error.localizedDescription)
        })
    }

    //MARK: - Methods
    @objc func refresh(_ sender: AnyObject) {
        NetworkManager.shared.dayCounter = Date()
        NetworkManager.shared.simpleCounter = 0
        parsedModel.removeAll()
        filteredModel.removeAll()
        tableView.reloadData()
        sendRequest()
        sender.endRefreshing()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        tableView.refreshControl = myRefreshControl
        tableView.addSubview(myRefreshControl)
    }

    private func configureSearhBar() {
        view.backgroundColor = .white

        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.view.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Search News"
        showSearchBarButton(shouldShow: true)
    }

    private func showSearchBarButton(shouldShow: Bool) {
        if shouldShow {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                                target: self,
                                                                action: #selector(handleShowSearchBar))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    private func search(shouldShow: Bool) {
        showSearchBarButton(shouldShow: !shouldShow)
        searchBar.showsCancelButton = shouldShow
        navigationItem.titleView = shouldShow ? searchBar : nil
    }

    @objc func handleShowSearchBar() {
        searchBar.becomeFirstResponder()
        search(shouldShow: true)
    }
}

//MARK: - UITableViewDelegate and UITableViewDataSource
extension NewsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredModel.isEmpty {
            return filteredModel.count
        }
        return parsedModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell  = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as? CustomTableViewCell else { fatalError() }

        if !filteredModel.isEmpty {
            cell.configureCell(filteredModel[indexPath.row].urlToImage,
                               filteredModel[indexPath.row].title,
                               filteredModel[indexPath.row].articleDescription)
        } else {
            cell.configureCell(parsedModel[indexPath.row].urlToImage,
                               parsedModel[indexPath.row].title,
                               parsedModel[indexPath.row].articleDescription)
        }
        self.tableView.tableFooterView = nil
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y < 0.0 {
            return
        }

        self.tableView.tableFooterView = createSpinnerFooter()


        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height

        if bottomEdge > view.frame.origin.y {

            guard !NetworkManager.shared.isPaginating else {
                return
            }

            self.sendRequest()
            tableView.reloadData()
            print("Получили инфу за день номер \(NetworkManager.shared.dayCounter)")
        }
    }

    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0,
                                              width: view.frame.size.width,
                                              height: 400))
        let spinner = UIActivityIndicatorView()
        spinner.center = view.center
        spinner.color = .black
        spinner.style = .large
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
}

//MARK: - UISearchBarDelegate
extension NewsViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search(shouldShow: false)
        filteredModel.removeAll()
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let info = searchBar.searchTextField.text else {
            filteredModel.removeAll()
            tableView.reloadData()
            return
        }

        parsedModel.forEach { result in
            if result.title.lowercased().contains(info.lowercased()) {
                filteredModel.append(result)
            }
        }
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}
