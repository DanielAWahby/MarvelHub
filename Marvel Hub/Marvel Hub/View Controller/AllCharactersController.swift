//
//  ViewController.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 28/10/2021.
//

import UIKit
import Alamofire
import CryptoKit
import SwiftyJSON
import NVActivityIndicatorView

class AllCharactersController: UIViewController {
    var allFetchedcharacters = [Character]()
    let cellIdentifier = "characterCell"
    
   
    
    @IBOutlet weak var charactersTableView:UITableView!
    @IBOutlet weak var activityIndicator:NVActivityIndicatorView!
    @IBOutlet weak var activityView:UIView!

    let itemsPerPage = 3
    var currentPage = 3
    var isFetchingCharacters = false
    @IBAction func searchPressed(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchController") as? SearchController
        viewController?.passedResults = allFetchedcharacters
//        let transition = CATransition()
//        transition.duration = 0.25
//        transition.type = CATransitionType.fade
////        transition.subtype = CATransitionSubtype.fromRight
////        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.linear)
//        view.window!.layer.add(transition, forKey: kCATransition)
        let navigationController = UINavigationController(rootViewController: viewController ?? UIViewController())
        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController , animated: true, completion: {
            self.allFetchedcharacters.removeAll()
        })
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        if allFetchedcharacters.count == 0 {
            activityView.isHidden = false
            activityIndicator.startAnimating()
            getAllCharacters()
        }
        
        
    }
    func getAllCharacters(){
        isFetchingCharacters = true
        let privateApiKey = "5551a75410d177e04fe11fb84e178a2e7eb1ac18"
        let parameters : [String:Any] = [ "orderBy" : "name","limit":itemsPerPage,"offset":currentPage]
        
        let publicApiKey = "23d9195168af096b4b2c6de3cfa59d06"
        let ts = String(Date().toMillis())
        let apiHash = MD5(string:"\(ts)\(privateApiKey)\(publicApiKey)")
        let allCharactersEndpoint = "https://gateway.marvel.com:443/v1/public/characters?ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        var request = URLRequest(url: URL(string: allCharactersEndpoint)!)
        request.httpMethod = "GET"
        request.httpBody = parameters as? Data
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let charactersList = try JSONDecoder().decode(ResponseModelCharacter.self, from: data)
                charactersList.data?.results?.forEach({ (fetchedcharacter) in
                    let character = fetchedcharacter
                    let newCharacter = Character(id: character.id, name: character.name, description: character.description, thumbnail:character.thumbnail)
                    self.allFetchedcharacters.append(newCharacter)
                })
                print(self.allFetchedcharacters)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.5, animations: {
                        self.activityView.alpha = 0
                    })
                    self.activityView.isHidden = true
                    self.charactersTableView.reloadData()
                    self.currentPage += 1
                    self.isFetchingCharacters = false
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
        
    }
//    func getCurrentCharacterItems( characterId:Int)->([ComicList],[EventList],[SeriesList]){
//
//    }
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
                getAllCharacters()
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        print("cancel prefetch row of \(indexPaths)")

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\(allFetchedcharacters.count) characters")
        return allFetchedcharacters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CharacterViewCell
        cell.selectionStyle = .none
        cell.characterNameLabel.text = allFetchedcharacters[indexPath.row].name
        
//        do {
//        q    data = try Data(contentsOf: URL(string: ("\(allFetchedcharacters[indexPath.row].thumbnail?.path)\(allFetchedcharacters[indexPath.row].thumbnail?.imageExtension)")!)
//        } catch {
//            print(error.localizedDescription)
//        }
//        let currentCharacterImage = UIImage(data: data!)
        let path = allFetchedcharacters[indexPath.row].thumbnail!.path ?? "http://i.annihil.us/u/prod/marvel/i/mg/3/40/4bb4680432f73"
//        print("Image Path: ",path)
        if path.contains("image_not_available"){
            cell.characterImage.image = UIImage(named: "image-placeholder")
        }
        else{
            let imageVariation = "landscape_incredible"
            let imageExtension = allFetchedcharacters[indexPath.row].thumbnail!.imageExtension ?? ".jpg"
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
        viewController?.characterId = allFetchedcharacters[indexPath.row].id ?? 0
        viewController?.imagePath = allFetchedcharacters[indexPath.row].thumbnail?.path ?? "http://i.annihil.us/u/prod/marvel/i/mg/3/40/4bb4680432f73"
        viewController?.imageExtension = allFetchedcharacters[indexPath.row].thumbnail?.imageExtension ?? ".jpg"
        viewController?.characterName = allFetchedcharacters[indexPath.row].name ?? "Ultron"
        viewController?.descriptionText =  allFetchedcharacters[indexPath.row].description ?? "Character Description Goes Here."
        
        viewController?.modalTransitionStyle = .crossDissolve
        viewController?.modalPresentationStyle = .fullScreen
        present(viewController ?? UIViewController(), animated: true, completion: nil)
    }
    
}