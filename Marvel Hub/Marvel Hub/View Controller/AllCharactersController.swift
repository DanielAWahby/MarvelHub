//
//  ViewController.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 28/10/2021.
//

import UIKit
import CryptoKit
import NVActivityIndicatorView

class AllCharactersController: UIViewController {
// MARK:- Definition of Character Array
    //    An array that is populated when the API call to get all characters occurs and then is used to populate each cell in the characters tableView
    var allFetchedcharacters = [Character]()

// MARK:- Definition of the characters tableView cell's reuseIdentifier
    let cellIdentifier = "characterCellIdentifier".localizableString
    
    
// MARK:- Storyboard's IBOutlet definintions
    @IBOutlet weak var charactersTableView:UITableView!
    @IBOutlet weak var activityIndicator:NVActivityIndicatorView!
    @IBOutlet weak var activityView:UIView!

//    MARK:- Other Variables and Constants
    //  A constant,used for pagination, that indicates the maximum number of characters that can be retrieved in one API call.
    let itemsPerPage = 5
    //  A pagination's variable that is an offset that is passed to the character's retrieval API call to retrieve more characters with an updated offset of the previously retrieved characters
    var offset = 0
    //  A flag to control pagination
    var isFetchingCharacters = false
    //  A flag that is used to trigger this View Controller's transition when it's retrieved back from another View Controller.
    var isCoolTransition = false

//    MARK:- Search Button IBAction Implementation
    @IBAction func searchPressed(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchController") as? SearchController
        viewController?.isCoolTransition = true
        let navigationController = UINavigationController(rootViewController: viewController ?? UIViewController())
        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController , animated: true, completion: {
            self.allFetchedcharacters.removeAll()
        })
        
    }
//    MARK:- View Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
//    MARK:- Checking whether the View Controller's transition should be triggered.
        if isCoolTransition {
            let transition = CATransition()
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeOut)
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        }
        let imageView = UIImageView(image: UIImage(named: "marvel-logo"))
        //      im
        //        imageView.contentMode = .
        imageView.contentScaleFactor = 2
        //        self.navigationController?.navigationBar.prefersLargeTitles = true
        //
        //        self.navigationController?.navigationBar.layer.cornerRadius = 5
        //        self.navigationController?.navigationBar.layer.masksToBounds = true
        self.navigationController?.navigationBar.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        self.navigationItem.titleView = imageView
        
        //        self.
        self.charactersTableView.register(UINib(nibName: "CharacterViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.charactersTableView.delegate = self
        self.charactersTableView.dataSource = self
        self.charactersTableView.prefetchDataSource = self
        
        getAllCharacters()
        
        
    }
    
//  MARK:- A Function to retrive all characters
    func getAllCharacters(){
        activityView.isHidden = false
        activityIndicator.startAnimating()
        isFetchingCharacters = true
        let privateApiKey = "5551a75410d177e04fe11fb84e178a2e7eb1ac18"
        
        let publicApiKey = "23d9195168af096b4b2c6de3cfa59d06"
        let ts = String(Date().toMillis())
        let apiHash = "\(ts)\(privateApiKey)\(publicApiKey)".md5
        let allCharactersEndpoint = "https://gateway.marvel.com:443/v1/public/characters?orderBy=name&limit=\(itemsPerPage)&offset=\(offset)&ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        var request = URLRequest(url: URL(string: allCharactersEndpoint)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let charactersList = try JSONDecoder().decode(ResponseModelCharacter.self, from: data)
                charactersList.data?.results?.forEach({ (fetchedcharacter) in
                    let character = fetchedcharacter
                    let newCharacter = Character(id: character.id, name: character.name, description: character.description, thumbnail:character.thumbnail)
                    self.allFetchedcharacters.append(newCharacter)
                })
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityView.isHidden = true
                    self.charactersTableView.reloadData()
                    self.isFetchingCharacters = false
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
        
    }
    
}

extension AllCharactersController : UITableViewDelegate, UITableViewDataSource,UITableViewDataSourcePrefetching{
//    MARK:- Pagination / Prefetching of tableView cells implementation
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for index in indexPaths {
            // Check whether the last 2 cells in tableView have been reached and trigger API call accordingly.
            if index.row >= allFetchedcharacters.count - 2 && !isFetchingCharacters{
                offset += itemsPerPage
                getAllCharacters()
                break
            }
        }
    }
//    MARK:- Defining the number of cells in tableView
    //     The number of cells in the tableView is the same as the number of characters that are retrieved through an API call
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFetchedcharacters.count
    }
//    MARK:- Dequeuing each tableView cell
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CharacterViewCell
        cell.selectionStyle = .none
        cell.characterNameLabel.text = allFetchedcharacters[indexPath.row].name
//      MARK:- Handling Character Image in a cell
        let path = allFetchedcharacters[indexPath.row].thumbnail!.path ?? "defaultImagePath".localizableString
        // If the path contains the string : "image_not_available" or an error occurs when downloading the image, the default image placeholder should be used. Otherwise the corresponding image should be used.
        if path.contains("image_not_available"){
            cell.characterImage.image = UIImage(named: "image-placeholder")
        }
        else{
            let imageVariation = "landscape_incredible"
            let imageExtension = allFetchedcharacters[indexPath.row].thumbnail!.imageExtension ?? "defaultImageExtension".localizableString
            let imageUrl = URL(string:"\(path)/\(imageVariation).\(imageExtension)")!
            do {
                
                let imageData = try Data(contentsOf: imageUrl)
                cell.characterImage.image = UIImage(data: imageData)
            } catch{
                print(error.localizedDescription)
                cell.characterImage.image = UIImage(named: "image-placeholder")
            }
        }
        cell.contentView.layer.cornerRadius = 10
        cell.characterImage.layer.cornerRadius = 10
        cell.clipsToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
//    MARK:- Defining the action to be performed upon tableView cell selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CharacterDetailScreen") as? CharacterDetailsController
        viewController?.characterId = allFetchedcharacters[indexPath.row].id ?? Int("defaultCharacterId".localizableString)!
        viewController?.imagePath = allFetchedcharacters[indexPath.row].thumbnail?.path ?? "defaultImagePath".localizableString
        viewController?.imageExtension = allFetchedcharacters[indexPath.row].thumbnail?.imageExtension ?? "defaultImageExtension".localizableString
        viewController?.characterName = allFetchedcharacters[indexPath.row].name ?? "Ultron"
        viewController?.descriptionText =  allFetchedcharacters[indexPath.row].description ?? "Character Description Goes Here."
        viewController?.isCoolTranisition = true
        viewController?.modalTransitionStyle = .crossDissolve
        viewController?.modalPresentationStyle = .fullScreen
        present(viewController ?? UIViewController(), animated: true, completion: nil)
    }
    
}
