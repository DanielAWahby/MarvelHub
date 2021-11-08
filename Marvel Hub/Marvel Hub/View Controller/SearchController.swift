//
//  SearchController.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 02/11/2021.
//

import UIKit
import NVActivityIndicatorView

class SearchController: UIViewController {
    // MARK:- Definition of Character Array
    //    An array that is constantly populated whenever the API call to get all the matching characters occurs and that is then used to populate the search results tableView
    var characters = [Character]()
// MARK:- Definition of the search results tableView cell's reuseIdentifier
    let cellIdentifier = "searchResultIdentifier".localizableString
    
//    MARK:- Definition of the search controller
    let searchController = UISearchController(searchResultsController: nil)
    
    //    MARK:- Other Variables
    //  A flag that is used to trigger this View Controller's transition when it's retrieved back from another View Controller.
    var isCoolTransition = true
    //  A string that is used in the implementation of the highlighting of each of the relevant search results.
    var substringToPass = ""
    
//  MARK:- Storyboard's IBOutlet definintions
    @IBOutlet weak var resultsTableView:UITableView!
    @IBOutlet weak var activityView:UIView!
    @IBOutlet weak var activityIndicatorView:NVActivityIndicatorView!
    
//  MARK:- View Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
//  MARK:- Checking whether the View Controller's transition should be triggered.
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
    //    MARK:- Handling the changes in the searchController's search bar text
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text
        substringToPass = String(searchText ?? "")
        getCharacterByName(name: searchText ?? "")
    }
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
    
    //    MARK:- A Function to retrive all characters by name
    //    The name is passed from the search bar's text to the function and used as in GET request.
    func getCharacterByName(name:String){
        activityView.isHidden = false
        activityIndicatorView.startAnimating()
        let privateApiKey = "5551a75410d177e04fe11fb84e178a2e7eb1ac18"
        let publicApiKey = "23d9195168af096b4b2c6de3cfa59d06"
        let ts = String(Date().toMillis())
        let apiHash = "\(ts)\(privateApiKey)\(publicApiKey)".md5
        var charactersEndpoint = "https://gateway.marvel.com:443/v1/public/characters?orderBy=name&ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        if name.count == 0 {
            charactersEndpoint = "https://gateway.marvel.com:443/v1/public/characters?orderBy=name&ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        }
        else{
            charactersEndpoint = "https://gateway.marvel.com:443/v1/public/characters?orderBy=name&nameStartsWith=\(name)&limit=100&ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        }
        // Emptying the results character before each request to avoid inconsistent results
        characters.removeAll()
        var request = URLRequest(url: URL(string: charactersEndpoint)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let charactersList = try JSONDecoder().decode(ResponseModelCharacter.self, from: data)
                charactersList.data?.results?.forEach({ (fetchedcharacter) in
                    let character = fetchedcharacter
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
    //    MARK:- Handling the search bar's Cancel button Actions
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
    
}
extension SearchController:UITableViewDelegate,UITableViewDataSource{
//    MARK:- Defining the number of cells in tableView
    //    This number of cell in the tableView corresponds to the number of search results that are retrieved from the API call.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
//    MARK:- Dequeuing each search result cell
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultsTableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SearchResultCell
        
        let characterName = characters[indexPath.row].name
        cell.characterNameLabel.text = characterName
//        MARK:- Highlight Relevant Character in a search result cell (Bonus)
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
//      MARK:- Handling Character Image in a search result cell
        // If the path contains the string : "image_not_available" or an error occurs when downloading the image, the default image placeholder should be used. Otherwise the corresponding image should be used.
        
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
