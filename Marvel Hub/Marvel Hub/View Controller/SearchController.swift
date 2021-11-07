//
//  SearchController.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 02/11/2021.
//

import UIKit

class SearchController: UIViewController {
    
    var passedResults = [Character]()
    
    var filteredResults = [Character]()
    
    var substringToPass = ""
    
    let cellIdentifier = "ResultCell"
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var resultsTableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Total Passed: ",passedResults.count)
        self.view.backgroundColor = .clear
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "searchPlaceholder".localizableString
        
        searchController.searchBar.tintColor = UIColor(named: "SubtextColor")
//        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.showsCancelButton = true
        
        searchController.searchBar.setValue("cancel".localizableString, forKey: "cancelButtonText")
        

        searchController.searchBar.returnKeyType = .done
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        resultsTableView.register(UINib(nibName: "SearchResultCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
    }
    
}
extension SearchController:UISearchResultsUpdating,UISearchBarDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text
        filterResults(searchText ?? "")
    }
    func filterResults(_ searchText:String){
        filteredResults = passedResults.filter({ character in
            if searchController.searchBar.text != ""{
                let searchTextMatch = character.name!.contains(searchText)
                substringToPass = String(searchText)
                return searchTextMatch
            }
            return false
        })
        resultsTableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("EMPTY ? ",searchBar.text!.isEmpty)
        if searchBar.text == "" && !searchBar.isFirstResponder{
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllCharacterScreen") as? AllCharactersController
                viewController?.allFetchedcharacters = passedResults
                //            let transition = CATransition()
                //            transition.type = CATransitionType.fade
                //            transition.subtype = CATransitionSubtype.fromRight
                //            //        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeOut)
                //            view.window!.layer.add(transition, forKey: kCATransition)
                let navigtionController = UINavigationController(rootViewController:viewController ?? UIViewController())
                navigtionController.modalPresentationStyle = .fullScreen
                navigationController?.modalTransitionStyle = .crossDissolve
                present(navigtionController, animated: true, completion: nil)
        }
        else{
            searchBar.text = ""
            searchBar.resignFirstResponder()
        }
        
    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if ((searchBar.text?.isEmpty) != nil) {
//            searchBar.resignFirstResponder()
//        }
//    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text == "") {
            filteredResults = passedResults
            resultsTableView.reloadData()
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if (searchBar.text == "") {
            filteredResults = passedResults
            resultsTableView.reloadData()
        }
    }
}
extension SearchController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredResults.count
        }
        return passedResults.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultsTableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SearchResultCell
        
        let characterName = searchController.isActive ? filteredResults[indexPath.row].name : passedResults[indexPath.row].name
        cell.characterNameLabel.text = characterName
        
        let attributedString = NSMutableAttributedString(string:characterName ?? characterName ?? "MARVEL CHARACTER")
        if searchController.isActive {
            let inputLength = attributedString.string.count
            let searchString = substringToPass
            let searchLength = searchString.count
            var range = NSRange(location: 0, length: attributedString.length)
            while (range.location != NSNotFound) {
                range = (attributedString.string as NSString).range(of: searchString, options: [], range: range)
                if (range.location != NSNotFound) {
                    attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor(named: "SearchTintColor") ?? .label, range: NSRange(location: range.location, length: searchLength))
                    range = NSRange(location: range.location + range.length, length: inputLength - (range.location + range.length))
                }
            }
        }
        cell.characterNameLabel.attributedText = attributedString
        
        let imageVariation = "standard_large"
        let path = ( searchController.isActive ? filteredResults[indexPath.row].thumbnail!.path : passedResults[indexPath.row].thumbnail!.path) ?? "http://i.annihil.us/u/prod/marvel/i/mg/3/40/4bb4680432f73"
        if path.contains("image_not_available"){
                cell.characterImage.image = UIImage(named: "image-placeholder")
        }
        else{
            let imageExtension = (searchController.isActive ? filteredResults[indexPath.row].thumbnail!.imageExtension : passedResults[indexPath.row].thumbnail!.imageExtension) ?? ".jpg"
            let imageUrl = URL(string:"\(path)/\(imageVariation).\(imageExtension)")!
            do {
                let imageData = try Data(contentsOf: imageUrl)
                cell.characterImage.image = UIImage(data: imageData)
            } catch{
                print(error.localizedDescription)
                cell.characterImage.image = UIImage(named: "image-placeholder")
            }
        }
        
        cell.contentView.layer.cornerRadius = 20
        cell.clipsToBounds = true
        cell.backgroundColor = .clear
        return cell
    }
    
}
