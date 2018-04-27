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
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var token: NotificationToken?
    var array = stride(from: 0, to: 40, by: 1).map{ String($0) }
    var boolArray = [Bool](repeating: false, count: 40)
    var realmForTableView: Realm!
    var lockFlag = true
    var isForMoving = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let realm = try? Realm() {
            realmForTableView = realm
        } else {
            //fatalError
        }
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
            
            array = tags.tags.components(separatedBy: RealmTagsModel.tagSeparator)
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
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsSelection = true
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.setEditing(!isForMoving, animated: false)
        toolBar.isHidden = isForMoving
        if isForMoving {
            navigationController?.navigationBar.items?.first?.rightBarButtonItems?.removeLast()
        }
        
        
        
        if !toolBar.isHidden {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: toolBar.frame.size.height, right: 0)
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: toolBar.frame.size.height, right: 0)
        }
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationController?.title = "카테고리 관리"
    }
    
    func tagsChanged(oldValue: String, newValue: String) {
        var oldArray = oldValue.components(separatedBy: RealmTagsModel.tagSeparator)
        var newArray = newValue.components(separatedBy: RealmTagsModel.tagSeparator)
        
        oldArray.removeFirst()
        newArray.removeFirst()
        
        let additions: [Int] = oldArray.count > newArray.count ? [] : Array<Int>(stride(from: oldArray.count, to: newArray.count, by: 1))
        let deletions: [Int] = oldArray.count > newArray.count ? Array<Int>(stride(from: newArray.count, to: oldArray.count, by: 1)) : []
        let modifications:[Int] = stride(from: 0, to: min(oldArray.count, newArray.count), by: 1)
            .filter{oldArray[$0] != newArray[$0]}
        
        modifications.forEach {
            array[$0] = newArray[$0]
            boolArray[$0] = false
        }
        if additions.count > 0 {
            array.append(contentsOf: newArray[oldArray.count ..< newArray.count])
            boolArray.append(contentsOf: [Bool](repeating: false, count: newArray.count - oldArray.count))
        }
        if deletions.count > 0 {
            array.removeSubrange(newArray.count ..< oldArray.count)
            boolArray.removeSubrange(newArray.count ..< oldArray.count)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.beginUpdates()
            
            self?.tableView.insertRows(at: additions.map{ IndexPath(row: $0, section: 0)}, with: .automatic)
            self?.tableView.deleteRows(at: deletions.map{ IndexPath(row: $0, section: 0)}, with: .automatic)
            self?.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0)}, with: .automatic)
            
            self?.tableView.endUpdates()
        }
    }
    
    @IBAction func addButtonTouched(_ sender: Any) {
        
        self.alertWithOKActionAndAlertHandler(message: "카테고리 제목을 입력해주세요") { alert in
            return { [weak self] action in
                guard let textField = alert.textFields?.first,
                    let strongSelf = self else {return}
                
                let newCategory = textField.text ?? ""
                let specialSet = CharacterSet(charactersIn: "|!~`@#$%^&*-+();:={}[],.<>?\\/\"\' ")
                let tagsArray = strongSelf.array.map{ $0.replacingOccurrences(of: RealmTagsModel.lockSymbol, with: "") }
                
                if !newCategory.isEmpty && !tagsArray.contains(newCategory)
                    && newCategory.count < 11 && newCategory.rangeOfCharacter(from: specialSet) == nil {
                    guard let realm = try? Realm(),
                        let tags = realm.objects(RealmTagsModel.self).first else {fatalError("Something went wrong")}
                    ModelManager.update(id: tags.id, type: RealmTagsModel.self,
                                        kv: [Schema.Tags.tags: tags.tags + "\(RealmTagsModel.tagSeparator)\(newCategory)"])
                } else {
                    let message: String
                    if newCategory.isEmpty {
                        message = "제목을 입력해주세요"
                    } else if tagsArray.contains(newCategory) {
                        message = "이미 존재하는 카테고리 입니다!"
                    } else {
                        message = "제목은 10자이하여야 하며, 특수문자를 사용할 수 없습니다"
                    }
                    self?.alertWithErrorMessage(message: message) { _ in
                        self?.addButtonTouched(sender)
                    }
                }
            }
        }
    }
    
    @IBAction func doneButtonTouched(_ sender: Any) {
        token?.invalidate()
        self.dismiss(animated: true)
    }
    
    @IBAction func lockButtonTouched(_ sender: Any) {
        var tempArray = array
        if lockFlag {
            boolArray.enumerated().filter{$0.element}.forEach {
                if !tempArray[$0.offset].hasPrefix(RealmTagsModel.lockSymbol) {
                    tempArray[$0.offset] = RealmTagsModel.lockSymbol + tempArray[$0.offset]
                }
            }
        } else {
            boolArray.enumerated().filter{$0.element}.forEach {
                tempArray[$0.offset].removeFirst()
            }
        }
        
        let newTags = tempArray.isEmpty ? "" :
        "\(RealmTagsModel.tagSeparator)\(tempArray.joined(separator: RealmTagsModel.tagSeparator))"
        
        guard let realm = try? Realm(),
            let tags = realm.objects(RealmTagsModel.self).first else { return }
        ModelManager.update(id: tags.id, type: RealmTagsModel.self, kv: [Schema.Tags.tags : newTags])
        
        lockBarButton.title = "잠금"
        categorySelectedCountButton.setTitle("", for: .normal)
        categorySelectedCountButton.sizeToFit()
        
        var modifications:[Int] = []
        boolArray.enumerated().filter{$0.element}.forEach {
            boolArray[$0.offset] = false
            modifications.append($0.offset)
        }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: modifications.map{IndexPath(row: $0, section: 0)}, with: .automatic)
        tableView.endUpdates()
    }
    
    @IBAction func trashButtonTouched(_ sender: Any) {
        self.alertWithOKAction(message: "삭제하시겠습니까?") { [weak self] action in
            guard let strongSelf = self else { return }
            var tempArray = strongSelf.array
            var offset = 0
            strongSelf.boolArray.enumerated().filter{$0.element}.forEach {
                tempArray.remove(at: $0.offset + offset)
                offset -= 1
            }
            
            let newTags = tempArray.isEmpty ? "" :
            "\(RealmTagsModel.tagSeparator)\(tempArray.joined(separator: RealmTagsModel.tagSeparator))"
            
            guard let realm = try? Realm(),
                let tags = realm.objects(RealmTagsModel.self).first else { return }
            ModelManager.update(id: tags.id, type: RealmTagsModel.self, kv: [Schema.Tags.tags : newTags])
            
            self?.lockBarButton.title = "잠금"
            self?.categorySelectedCountButton.setTitle("", for: .normal)
            self?.categorySelectedCountButton.sizeToFit()
        }
    }
    
}

extension CategoryManageViewController: CategoryManageCellDelegate {
    func nameTouched(name: String) {
        guard let index = array.index(of: name), !isForMoving else {return}
        self.alertWithOKActionAndAlertHandler(message: "카테고리 제목을 입력해주세요") { alert in
            return { [weak self] action in
                guard let textField = alert.textFields?.first,
                    let strongSelf = self else {return}
                
                let newCategory = textField.text ?? ""
                let specialSet = CharacterSet(charactersIn: "!~`@#$%^&*-+();:={}[],.<>?\\/\"\' ")
                let tagsArray = strongSelf.array.map{ $0.replacingOccurrences(of: RealmTagsModel.lockSymbol, with: "") }
                
                if !newCategory.isEmpty && !tagsArray.contains(newCategory)
                    && newCategory.count < 11 && newCategory.rangeOfCharacter(from: specialSet) == nil {
                    guard let realm = try? Realm(),
                        let tags = realm.objects(RealmTagsModel.self).first else {fatalError("Something went wrong")}
                    var tempArray = strongSelf.array
                    tempArray[index] = newCategory
                    let newTags = "\(RealmTagsModel.tagSeparator)\(tempArray.joined(separator: RealmTagsModel.tagSeparator))"
                    ModelManager.update(id: tags.id, type: RealmTagsModel.self,
                                        kv: [Schema.Tags.tags: newTags])
                } else {
                    let message: String
                    if newCategory.isEmpty {
                        message = "제목을 입력해주세요"
                    } else if tagsArray.contains(newCategory) {
                        message = "이미 존재하는 카테고리 입니다!"
                    } else {
                        message = "제목은 10자이하여야 하며, 특수문자를 사용할 수 없습니다"
                    }
                    self?.alertWithErrorMessage(message: message) { _ in
                        self?.nameTouched(name: name)
                    }
                }
            }
        }
    }
    
    
}

extension CategoryManageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryManageCell
        
        cell.titleLabel?.text = array[indexPath.row].replacingOccurrences(of: RealmTagsModel.lockSymbol, with: "")//remove lock symbol
        cell.checkButton.isSelected = boolArray[indexPath.row]
        cell.delegate = self
        cell.lockImageView.isHidden = !array[indexPath.row].contains(RealmTagsModel.lockSymbol)
        
        let tag = "\(RealmTagsModel.tagSeparator)\(array[indexPath.row])\(RealmTagsModel.tagSeparator)"
        let noteCount = realmForTableView.objects(RealmNoteModel.self).filter("tags CONTAINS[cd] %@", tag).count
        cell.subtitleLabel.text = "\(noteCount)개의 노트"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var tempArray = array
        let movedObject = tempArray[sourceIndexPath.row]
        
        tempArray.remove(at: sourceIndexPath.row)
        tempArray.insert(movedObject, at: destinationIndexPath.row)
        
        let newTags = "\(RealmTagsModel.tagSeparator)\(tempArray.joined(separator: RealmTagsModel.tagSeparator))"
        
        guard let realm = try? Realm(),
            let tags = realm.objects(RealmTagsModel.self).first else { return }
        ModelManager.update(id: tags.id, type: RealmTagsModel.self, kv: [Schema.Tags.tags : newTags])
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryManageCell else {return}
        if isForMoving {
            //move memos to cell
            
        } else {
            cell.checkButton.isSelected = !cell.checkButton.isSelected
            boolArray[indexPath.row] = cell.checkButton.isSelected
            
            let title = boolArray.filter{$0}.count > 0 ? "\(boolArray.filter{$0}.count)개 폴더 선택됨" : ""
            
            var tempLockFlag = false
            boolArray.enumerated().filter{$0.element}.forEach{
                if !array[$0.offset].contains(RealmTagsModel.lockSymbol) { tempLockFlag = true }
            }
            lockFlag = tempLockFlag
            
            lockBarButton.title = lockFlag ? "잠금" : "잠금해제"
            if (boolArray.filter{$0}.count) == 0 {
                lockBarButton.title = "잠금"
            }
            
            categorySelectedCountButton.setTitle(title, for: .normal)
            categorySelectedCountButton.sizeToFit()
        }
    }
}
