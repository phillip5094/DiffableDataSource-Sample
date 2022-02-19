//
//  ViewController.swift
//  DiffableDataSource-Sample
//
//  Created by NHN on 2022/02/18.
//

import UIKit

class ViewController: UIViewController {
    enum Section: CaseIterable {
        case main
    }
    
    let peopleController = PeopleController()
    let searchBar = UISearchBar(frame: .zero)
    var peopleCollectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, PeopleController.Person>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "People Search"
        configureHierarchy()
        configureDataSource()
        performQuery(with: nil)
    }
}

extension ViewController {
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<LabelCell, PeopleController.Person> { (cell, indexPath, person) in
            cell.label.text = person.name
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, PeopleController.Person>(collectionView: peopleCollectionView, cellProvider: { (collectionView, indexPath, identifier) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        })
    }
    
    func performQuery(with filter: String?) {
        let people = peopleController.filteredPeople(with: filter).sorted { $0.name < $1.name }
        var snapshot = NSDiffableDataSourceSnapshot<Section, PeopleController.Person>()
        snapshot.appendSections([.main])
        snapshot.appendItems(people)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ViewController {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let columns = contentSize.width > 800 ? 3 : 2
            let spacing = CGFloat(10)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(32))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            return section
        }
        return layout
    }
    
    func configureHierarchy() {
        view.backgroundColor = .systemBackground
        let layout = createLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        
        let views = ["cv": collectionView, "searchBar": searchBar]
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
                            withVisualFormat: "H:|[cv]|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
                            withVisualFormat: "H:|[searchBar]|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
                            withVisualFormat: "V:[searchBar]-20-[cv]|", options: [], metrics: nil, views: views))
        constraints.append(searchBar.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0))
        NSLayoutConstraint.activate(constraints)
        peopleCollectionView = collectionView
        
        searchBar.delegate = self
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performQuery(with: searchText)
    }
}
