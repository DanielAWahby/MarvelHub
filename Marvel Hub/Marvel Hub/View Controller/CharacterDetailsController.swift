//
//  CharacterDetailsController.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 02/11/2021.
//

import UIKit

protocol CharacterDetailDelegate: class {
    func onInnerCollectionlShouldUpdate()
}

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
    var events = [Event]()
    var series = [Series]()
    var stories = [Story]()
    var passedImages = [UIImage]()
    
    
    
    var sectionInsets : UIEdgeInsets{
        return UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
    }
    
    let spacingBetweenCells: CGFloat = 5
    @IBOutlet weak var backButtonContainerView: UIVisualEffectView!
    @IBOutlet weak var characterFullName: UILabel!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var desriptionTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButtonContainerView.layer.cornerRadius = backButtonContainerView.frame.height / 2
        backButtonContainerView.layer.maskedCorners = self.isAppArabic ? [.layerMinXMinYCorner,.layerMinXMaxYCorner]: [.layerMaxXMinYCorner,.layerMaxXMaxYCorner]
        backButton.setImage(self.isAppArabic ? UIImage(named:"ic-back-flipped") : UIImage(named:"ic-back") , for: .normal)
        backButtonContainerView.layer.masksToBounds = true
        characterImage.layer.cornerRadius = 10
        characterImage.clipsToBounds = true
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(CharacterItemCell.self, forCellWithReuseIdentifier: cellIdentifier)
        characterFullName.text = characterName
        if imagePath.contains("image_not_available"){
            characterImage.image = UIImage(named: "image-placeholder")
        }
        else{
            let imageVariation = "portrait_incredible"
            let imageUrl = URL(string:"\(imagePath)/\(imageVariation).\(imageExtension)")!
            do {
                let imageData = try Data(contentsOf: imageUrl)
                characterImage.image = UIImage(data: imageData)
            } catch{
                print(error.localizedDescription)
                characterImage.image = UIImage(named: "image-placeholder")
            }
        }
        descriptionLabel.text = "descriptionTitle".localizableString
        descriptionLabel.textAlignment = self.isAppArabic ? .right : .left
        desriptionTextView.text = descriptionText
        print(descriptionText)
        print("ID: ",characterId)
        getCurrentCharacterItems(characterId: characterId)
        collectionView.reloadData()
        view.layoutIfNeeded()
    }
    
    func getCurrentCharacterItems( characterId:Int){
        let ts = String(Date().toMillis())
        let apiHash = "\(ts)\(privateApiKey)\(publicApiKey)".md5
        let allCharactersEndpoint = "https://gateway.marvel.com:443/v1/public/characters/\(characterId)/comics?ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        
//        let parameters : [String:Any] = [ "characterId" : characterId]
        var request = URLRequest(url: URL(string: allCharactersEndpoint)!)
        request.httpMethod = "GET"
//        request.httpBody = parameters as? Data
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let comicList = try JSONDecoder().decode(ResponseModelComic.self, from: data)
                
                comicList.data?.results?.forEach({ (fetchedComic) in
                    let comic = fetchedComic
                    let newComic = Comic(id: comic.id, digitalId: comic.digitalId, title: comic.title, thumbnail: comic.thumbnail)
                    self.comics.append(newComic)
                })
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
//        ts = String(Date().toMillis())
//        apiHash = "\(ts)\(privateApiKey)\(publicApiKey)".md5
//        allCharactersEndpoint = "https://gateway.marvel.com:443/v1/public/characters/\(characterId)/events?ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
//        
////        let parameters : [String:Any] = [ "characterId" : characterId]
//        request = URLRequest(url: URL(string: allCharactersEndpoint)!)
//        request.httpMethod = "GET"
////        request.httpBody = parameters as? Data
//        task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else { return }
//            do {
//                let eventList = try JSONDecoder().decode(ResponseModelEvent.self, from: data)
//                print("Status: ",eventList.status ?? 200)
//                eventList.data?.results?.forEach({ (fetchedEvent) in
//                    let event = Event(id: fetchedEvent.id,title: fetchedEvent.title, thumbnail: fetchedEvent.thumbnail)
//                    self.events.append(event)
//                    print(event.title ?? "TITLE")
//                })
//                DispatchQueue.main.async {
////                    self.collectionView.reloadData()
////                    self.collectionView.collectionViewLayout.invalidateLayout()
//                }
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//        }
//        task.resume()
        
    }
    
}

extension CharacterDetailsController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        Each Section represents a category of items that is associated with the currently opened character. These categories are: Comics, Events, Series and Stories.
        
        return 4
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        ////            let screenLeft = -(UIScreen.main.bounds.width / 2)
//        //    ////        let screenRight = UIScreen.main.bounds.width / 4
//        return sectionInsets
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return spacingBetweenCells
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height / 4)
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("Width: ",self.collectionView.frame.size.width)
        return CGSize(width: self.view.frame.size.width * 0.8, height: 150)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CharacterItemCell
        print(passedImages.count)
        cell.passedSection = indexPath.section
        cell.passedComics = comics
        cell.passedEvents = events
        cell.passedSeries = series
        cell.passedStories = stories
   
        switch indexPath.section {
        case 0: cell.itemLabel.text = "comicsTitle".localizableString
        case 1: cell.itemLabel.text = "eventsTitle".localizableString
        case 2: cell.itemLabel.text = "seriesTitle".localizableString
        default:
            cell.itemLabel.text = "storiesTitle".localizableString
        }
        cell.itemLabel.textAlignment  = self.isAppArabic ? .right : .left
        cell.onInnerCollectionlShouldUpdate()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
