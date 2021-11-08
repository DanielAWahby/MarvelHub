//
//  SearchController.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 02/11/2021.
//

import UIKit
import NVActivityIndicatorView

class SearchController: UIViewController {
    
    var characters = [Character]()
        
    var substringToPass = ""
    
    let cellIdentifier = "searchResultIdentifier".localizableString
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var isCoolTransition = true
    @IBOutlet weak var resultsTableView:UITableView!
    @IBOutlet weak var activityView:UIView!
    @IBOutlet weak var activityIndicatorView:NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isCoolTransition {
            let transition = CATransition()
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeOut)
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        }
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
        getCharacterByName(name:"")
    }
    
}
extension SearchController:UISearchResultsUpdating,UISearchBarDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text
        substringToPass = String(searchText ?? "")
        getCharacterByName(name: searchText ?? "")
        //        filterResults(searchText ?? "")
    }
    func getCharacterByName(name:String){
        activityView.isHidden = false
        activityIndicatorView.startAnimating()
        let privateApiKey = "5551a75410d177e04fe11fb84e178a2e7eb1ac18"
        let publicApiKey = "23d9195168af096b4b2c6de3cfa59d06"
        let ts = String(Date().toMillis())
        let apiHash = "\(ts)\(privateApiKey)\(publicApiKey)".md5
        var charactersEndpoint = "https://gateway.marvel.com:443/v1/public/characters?orderBy=name&ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        print("Name: \(name)")
        if name.count == 0 {
            charactersEndpoint = "https://gateway.marvel.com:443/v1/public/characters?orderBy=name&ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        }
        else{
            charactersEndpoint = "https://gateway.marvel.com:443/v1/public/characters?orderBy=name&nameStartsWith=\(name)&limit=100&ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        }
        characters.removeAll()
        var request = URLRequest(url: URL(string: charactersEndpoint)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let charactersList = try JSONDecoder().decode(ResponseModelCharacter.self, from: data)
                charactersList.data?.results?.forEach({ (fetchedcharacter) in
                    let character = fetchedcharacter
                    print(character.name)
                    let newCharacter = Character(id: character.id, name: character.name, description: character.description, thumbnail:character.thumbnail)
                    self.characters.append(newCharacter)
                })
                DispatchQueue.main.async {
                    if !self.characters.isEmpty{
                        self.activityView.isHidden = true
                        self.activityIndicatorView.stopAnimating()
                        self.resultsTableView.reloadData()
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
        
    }
    //    func filterResults(_ searchText:String){
    //        filteredResults = characters.filter({ character in
    //            if searchController.searchBar.text != ""{
    //                let searchTextMatch = character.name!.contains(searchText)
    //                substringToPass = String(searchText)
    //                return searchTextMatch
    //            }
    //            return false
    //        })
    //        resultsTableView.reloadData()
    //    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" && !searchBar.isFirstResponder{
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllCharacterScreen") as? AllCharactersController
            viewController?.isCoolTransition = true
            let navigtionController = UINavigationController(rootViewController:viewController ?? UIViewController())
            navigtionController.modalPresentationStyle = .fullScreen
            navigationController?.modalTransitionStyle = .crossDissolve
            present(navigtionController, animated: true, completion: nil)
        }
        else{
            searchBar.text = ""
            getCharacterByName(name:"")
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
            getCharacterByName(name: "")
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if (searchBar.text != "") {
            getCharacterByName(name:"")
        }
    }
}
extension SearchController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultsTableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SearchResultCell
        
        let characterName = characters[indexPath.row].name
        cell.characterNameLabel.text = characterName
        
        let attributedString = NSMutableAttributedString(string:characterName ?? characterName ?? "defaultCharacterName".localizableString)
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
        let path = (characters[indexPath.row].thumbnail!.path) ?? "defaultImagePath".localizableString
        if path.contains("image_not_available"){
            cell.characterImage.image = UIImage(named: "image-placeholder")
        }
        else{
            let imageExtension = (characters[indexPath.row].thumbnail!.imageExtension) ?? "defaultImageExtension".localizableString
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
