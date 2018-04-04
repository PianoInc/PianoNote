//
//  CategoryManageViewController.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 4..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryManageViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var lockBarButton: UIBarButtonItem!
    @IBOutlet weak var categorySelectedCountButton: UIButton!

    var token: NotificationToken?
    var array = stride(from: 0, to: 40, by: 1).map{ String($0) }
    var boolArray = [Bool](repeating: false, count: 40)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setObserver()
        setUIConfigs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func setObserver() {
        do {
            let realm = try Realm()
            guard let tags = realm.objects(RealmTagsModel.self).first else { return }

            array = tags.tags == "!" ? [""]: tags.tags.components(separatedBy: "!")
            array.remove(at: 0)
            boolArray = [Bool](repeating: false, count: array.count)

            token = tags.observe { [weak self] change in
                switch change {
                    case .change(let changes):changes.forEach { change in
                        guard let newValue = change.newValue as? String,
                                let oldValue = change.oldValue as? String,
                                newValue != oldValue,
                                change.name == Schema.Tags.tags else {return}
                        self?.tagsChanged(oldValue: oldValue, newValue: newValue)
                    }
                    default: return
                }
            }
        } catch { print(error)}

    }
    
    func setUIConfigs() {
        categorySelectedCountButton.isUserInteractionEnabled = false
        categorySelectedCountButton.titleLabel?.adjustsFontSizeToFitWidth = true
        categorySelectedCountButton.titleLabel?.lineBreakMode = .byWordWrapping
        categorySelectedCountButton.titleLabel?.numberOfLines = 1

        if !toolBar.isHidden {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: toolBar.frame.size.height, right: 0)
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: toolBar.frame.size.height, right: 0)
        }
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsSelection = false
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.setEditing(true, animated: false)
    }

    func tagsChanged(oldValue: String, newValue: String) {

        //TODO: empty cases!!!!
        let diffMaker = DiffMaker(aString: oldValue, bString: newValue, separator: "!")
        let diffChunks = diffMaker.parseTwoStrings()


        var additions: [Int] = []
        var deletions: [Int] = []
        var modifications: [Int] = []

        var offset = 0
        diffChunks.forEach {
            switch $0 {
                case .add(let index, let range):
                    let addChunks = Array<String>(diffMaker.bChunks[range.lowerBound ..< range.upperBound]).map{$0.replacingOccurrences(of: "!", with: "")}
                    let boolSubArray = [Bool](repeating: false, count: addChunks.count)
                    
                    array.insert(contentsOf: addChunks, at: index+offset-1)
                    boolArray.insert(contentsOf: boolSubArray, at: index+offset-1)

                    offset += range.length
                    additions.append(contentsOf: range.lowerBound-1 ..< range.upperBound-1 )

                case .delete(let range, _):
                    array.removeSubrange(range.lowerBound+offset-1 ..< range.upperBound+offset-1)
                    boolArray.removeSubrange(range.lowerBound+offset-1 ..< range.upperBound+offset-1)

                    offset -= range.length
                    deletions.append(contentsOf: range.lowerBound-1 ..< range.upperBound-1)

                case .change(let myRange, let newRange):
                    let addChunks = Array<String>(diffMaker.bChunks[newRange.lowerBound ..< newRange.upperBound]).map{$0.replacingOccurrences(of: "!", with: "")}.map{$0.replacingOccurrences(of: "!", with: "")}
                    let boolSubArray = [Bool](repeating: false, count: addChunks.count)
                    
                    array.replaceSubrange(myRange.lowerBound+offset-1 ..< myRange.upperBound+offset-1,
                            with: addChunks)
                    boolArray.replaceSubrange(myRange.lowerBound+offset-1 ..< myRange.upperBound+offset-1,
                                              with: boolSubArray)

                    offset += newRange.length - myRange.length
                    
                    if myRange.length > newRange.length {
                        modifications.append(contentsOf: myRange.lowerBound-1 ..< myRange.lowerBound-1+newRange.length)
                        deletions.append(contentsOf: myRange.lowerBound-1+newRange.length ..< myRange.upperBound-1)
                    } else if myRange.length < newRange.length {
                        modifications.append(contentsOf: myRange.lowerBound-1 ..< myRange.upperBound-1)
                        additions.append(contentsOf: myRange.upperBound-1 ..< myRange.upperBound-1+newRange.length-myRange.length)
                    } else {
                        modifications.append(contentsOf: myRange.lowerBound-1 ..< myRange.upperBound-1)
                    }

                default: return
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.tableView.beginUpdates()

            self?.tableView.insertRows(at: additions.map{ IndexPath(row: $0, section: 0)}, with: .automatic)
            self?.tableView.deleteRows(at: deletions.map{ IndexPath(row: $0, section: 0)}, with: .automatic)

            self?.tableView.endUpdates()
        }
    }

    @IBAction func addButtonTouched(_ sender: Any) {

        self.alertWithOKAction(message: "카테고리 제목을 입력해주세요") { alert in
            return { [weak self] action in
                guard let textField = alert.textFields?.first else {return}

                let newCategory = textField.text ?? ""

                if !newCategory.isEmpty && newCategory.count < 11 && !newCategory.contains("!") {
                    guard let realm = try? Realm(),
                            let tags = realm.objects(RealmTagsModel.self).first else {fatalError("Something went wrong")}
                    ModelManager.update(id: tags.id, type: RealmTagsModel.self,
                            kv: [Schema.Tags.tags: tags.tags + "!\(newCategory)"])
                } else {
                    let message = newCategory.isEmpty ? "제목을 입력해주세요": "제목은 10지이하여야 하며, !를 사용할 수 없습니다"
                    self?.alertWithErrorMessage(message: message) { _ in
                        self?.addButtonTouched(sender)
                    }
                }
            }
        }
    }
    
    @IBAction func doneButtonTouched(_ sender: Any) {
//        token?.invalidate()
//        self.dismiss(animated: true)
    }
    
    @IBAction func lockButtonTouched(_ sender: Any) {
    }
    
    @IBAction func trashButtonTouched(_ sender: Any) {
        self.alertWithOKAction(message: "삭제하시겠습니까?") { action in
            //
            print("deleteeeeeeeeeeeeeeeeeeeee")
        }
    }
    
}

extension CategoryManageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryManageCell
        
        cell.titleLabel?.text = array[indexPath.row]
        cell.checkButton.isSelected = boolArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = array[sourceIndexPath.row]
        let movedBool = boolArray[sourceIndexPath.row]
        
        array.remove(at: sourceIndexPath.row)
        boolArray.remove(at: sourceIndexPath.row)
        array.insert(movedObject, at: destinationIndexPath.row)
        boolArray.insert(movedBool, at: destinationIndexPath.row)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryManageCell else {return}
        cell.checkButton.isSelected = !cell.checkButton.isSelected
        boolArray[indexPath.row] = cell.checkButton.isSelected
        
        let title = boolArray.filter{$0}.count > 0 ? "\(boolArray.filter{$0}.count)개 폴더 선택됨" : ""
        
        categorySelectedCountButton.setTitle(title, for: .normal)
        categorySelectedCountButton.sizeToFit()
    }
}
