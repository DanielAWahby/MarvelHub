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
    
    var allFetchedcharacters = [Character]()
    
    let cellIdentifier = "characterCellIdentifier".localizableString
    
    
    
    @IBOutlet weak var charactersTableView:UITableView!
    @IBOutlet weak var activityIndicator:NVActivityIndicatorView!
    @IBOutlet weak var activityView:UIView!
    
    let itemsPerPage = 5
    var offset = 0
    var isFetchingCharacters = false
    var isCoolTransition = false
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
    override func viewDidLoad() {
        super.viewDidLoad()
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
    func getAllCharacters(){
        activityView.isHidden = false
        activityIndicator.startAnimating()
        isFetchingCharacters = true
        let privateApiKey = "5551a75410d177e04fe11fb84e178a2e7eb1ac18"
        
        let publicApiKey = "23d9195168af096b4b2c6de3cfa59d06"
        let ts = String(Date().toMillis())
        let apiHash = MD5(string:"\(ts)\(privateApiKey)\(publicApiKey)")
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
    
    func MD5(string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
        
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
}

extension AllCharactersController : UITableViewDelegate, UITableViewDataSource,UITableViewDataSourcePrefetching{
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for index in indexPaths {
            if index.row >= allFetchedcharacters.count - 2 && !isFetchingCharacters{
                offset += itemsPerPage
                getAllCharacters()
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFetchedcharacters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CharacterViewCell
        cell.selectionStyle = .none
        cell.characterNameLabel.text = allFetchedcharacters[indexPath.row].name
        let path = allFetchedcharacters[indexPath.row].thumbnail!.path ?? "defaultImagePath".localizableString
        
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
        //        cell.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
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
