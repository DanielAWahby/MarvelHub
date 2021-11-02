//
//  CharacterDetailsController.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 02/11/2021.
//

import UIKit

class CharacterDetailsController: UIViewController {
    
    let cellIdentifier = "characterItem"
    let publicApiKey = "23d9195168af096b4b2c6de3cfa59d06"
    let privateApiKey = "5551a75410d177e04fe11fb84e178a2e7eb1ac18"
    
    var characterId = 0
    var imagePath = ""
    var imageExtension = ""
    var characterName = ""
    var descriptionText = ""
    
    var comics = [Comic]()
    var events = [EventList]()
    var series = [SeriesList]()
    var stories = [StoryList]()
    
    
    @IBOutlet weak var backButtonContainerView: UIVisualEffectView!
    @IBOutlet weak var characterFullName: UILabel!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var desriptionTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButtonContainerView.layer.cornerRadius = backButtonContainerView.frame.height / 2
        backButtonContainerView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMaxXMaxYCorner]
        backButtonContainerView.layer.masksToBounds = true
        characterImage.layer.cornerRadius = 10
        characterImage.clipsToBounds = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "CharacterItemCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        characterFullName.text = characterName
        let imageVariation = "portrait_incredible"
        let imageUrl = URL(string:"\(imagePath)/\(imageVariation).\(imageExtension)")!
        do {
            let imageData = try Data(contentsOf: imageUrl)
            characterImage.image = UIImage(data: imageData)
        } catch{
            print(error.localizedDescription)
            characterImage.image = UIImage(named: "image-placeholder")
        }
        desriptionTextView.text = descriptionText
        print("Added ",comics.count," comics")
    }
    
    func getCurrentCharacterItems( characterId:Int){
        let ts = String(Date().toMillis())
        let apiHash = "\(ts)\(privateApiKey)\(publicApiKey)".md5
        let allCharactersEndpoint = "https://gateway.marvel.com:443/v1/public/characters/\(characterId)/?ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        
//        let parameters : [String:Any] = [ "orderBy" : "name","limit":100]
        var request = URLRequest(url: URL(string: allCharactersEndpoint)!)
        request.httpMethod = "GET"
//        request.httpBody = parameters as? Data
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let charactersList = try JSONDecoder().decode(ResponseModel.self, from: data)
                charactersList.data?.results?.forEach({ (fetchedcharacter) in
                    let character = fetchedcharacter
                    let newCharacter = Character(id: character.id, name: character.name, description: character.description, thumbnail:character.thumbnail, comics: character.comics, stories: character.stories, events: character.events, series: character.series)
//                    self.comics = newCharacter.comics
//                    self.events = newCharacter.events
//                    self.stories = newCharacter.stories
//                    self.series = newCharacter.series
                })
//                print(self.allFetchedcharacters)
                DispatchQueue.main.async {
//                    self.activityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
}

extension CharacterDetailsController : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        TODO
        return 1
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        Each Section represents a category of items that is associated with the currently opened character. These categories are: Comics, Events, Series and Stories.
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CharacterItemCell
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        TODO
    }
}
