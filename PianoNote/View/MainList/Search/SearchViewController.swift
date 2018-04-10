//
//  SearchViewController.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 6..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var noteFilteredResults: Results<RealmNoteModel>?
    var notificationToken: NotificationToken?
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTableView()
        setObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 93
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func setObserver() {
        notificationToken?.invalidate()
        
        notificationToken = noteFilteredResults?.observe { [weak self] change in
            guard let tableView = self?.tableView else {return}
            switch change {
            case .initial(_): tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map{IndexPath(row: $0, section: 0)}, with: .automatic)
                tableView.deleteRows(at: deletions.map{IndexPath(row: $0, section: 0)}, with: .automatic)
                tableView.reloadRows(at: modifications.map{IndexPath(row: $0, section: 0)}, with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                fatalError(error.localizedDescription)
            }
        }
        
    }
}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        guard let realm = try? Realm() else { fatalError("Something went wrong!") }
        
        noteFilteredResults = realm.objects(RealmNoteModel.self)
            .filter("title CONTAINS[cd] %@ OR content CONTAINS[cd] %@", searchText, searchText)
        
        setObserver()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteFilteredResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        guard let note = noteFilteredResults?[indexPath.row],
            let searchCell = cell as? SearchCell,
            let creationDate = note.getRecord().creationDate else {return cell}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        searchCell.titleLabel.text = note.title
        searchCell.contentLabel.text = nil
        searchCell.dateLabel.text = dateFormatter.string(from: creationDate)
        
        guard let range = note.content.lowercased().range(of: searchText.lowercased()) else {return cell}
        let startIndex = note.content.index(range.lowerBound, offsetBy: -10, limitedBy: note.content.startIndex) ?? note.content.startIndex
        let endIndex = note.content.index(range.upperBound, offsetBy: 10, limitedBy: note.content.endIndex) ?? note.content.endIndex
        
        let searchedContentString = String(describing: note.content[startIndex..<endIndex]).replacingOccurrences(of: "\n", with: " ")
        let highlightRange = searchedContentString.lowercased().range(of: searchText.lowercased())!
        let searchedContentAttributedString = NSMutableAttributedString(string: searchedContentString)
        searchedContentAttributedString
            .addAttributes([.font: FontManager.shared.getFont(for: .callout)], range: NSMakeRange(0, searchedContentString.count))
        searchedContentAttributedString.addAttributes([.foregroundColor: UIColor(hex6: "157EFB")], range: highlightRange.toNSRange())
        
        searchCell.contentLabel?.attributedText = searchedContentAttributedString
        
        
        return searchCell
    }
}
