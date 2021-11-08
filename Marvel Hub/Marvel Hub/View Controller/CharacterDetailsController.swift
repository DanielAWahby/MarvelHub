//
//  CharacterDetailsController.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 02/11/2021.
//

import UIKit
import NVActivityIndicatorView

protocol CharacterDetailDelegate: class {
    func onInnerCollectionlShouldUpdate()
}

class CharacterDetailsController: UIViewController,ItemSelectionDelegate{
    func presentPopOverViewController(image: UIImage, itemName: String) {
        print("Passed Title: ",itemName)
        let viewController = UIViewController()
        let imageView = UIImageView(image: image)
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        blurView.frame = self.view.frame
        blurView.alpha = 0.7
        viewController.view.addSubview(blurView)
        imageView.center = blurView.contentView.center
        imageView.contentMode = .scaleAspectFill
        blurView.contentView.addSubview(imageView)
        let itemNameLabel = UILabel()
        blurView.contentView.addSubview(itemNameLabel)
        itemNameLabel.frame = CGRect(x: blurView.contentView.frame.origin.x, y:blurView.contentView.center.y * 1.5, width: blurView.contentView.frame.size.width, height: 100)
        itemNameLabel.text = itemName
        itemNameLabel.textAlignment = .center
        itemNameLabel.numberOfLines = 0
        itemNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        itemNameLabel.textColor = UIColor(named: "SubTextColor")
        viewController.modalPresentationStyle = .formSheet
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    let cellIdentifier = "characterItemIdentifier".localizableString
    let headerIdentifier = "headerItem".localizableString
    
    let publicApiKey = "23d9195168af096b4b2c6de3cfa59d06"
    let privateApiKey = "5551a75410d177e04fe11fb84e178a2e7eb1ac18"
    
    var characterId = 0
    var imagePath = ""
    var imageExtension = ""
    var characterName = ""
    var descriptionText = ""
    var numberOfSections = 1
    
    var comics = [Comic]()
    var events = [Event]()
    var series = [Series]()
    var stories = [Story]()
    
    var comicsTask : URLSessionTask?
    var eventsTask : URLSessionTask?
    var seriesTask : URLSessionTask?
    var storiesTask : URLSessionTask?
    
    var isCoolTranisition = true
    
    var sectionInsets : UIEdgeInsets{
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    let spacingBetweenCells: CGFloat = 5
    
    @IBOutlet weak var backButtonContainerView: UIVisualEffectView!
    @IBOutlet weak var characterFullName: UILabel!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var desriptionTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    
    //    @IBOutlet weak var activityIndicator : NVActivityIndicatorView!
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isCoolTranisition {
            let transition = CATransition()
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeOut)
            self.view.layer.add(transition, forKey: kCATransition)
        }
        backButtonContainerView.layer.cornerRadius = backButtonContainerView.frame.height / 2
        backButtonContainerView.layer.maskedCorners = self.isAppArabic ? [.layerMinXMinYCorner,.layerMinXMaxYCorner]: [.layerMaxXMinYCorner,.layerMaxXMaxYCorner]
        backButton.setImage(self.isAppArabic ? UIImage(named:"ic-back-flipped") : UIImage(named:"ic-back") , for: .normal)
        backButtonContainerView.layer.masksToBounds = true
        characterImage.layer.cornerRadius = 10
        characterImage.clipsToBounds = true
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(CharacterItemCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.collectionView.register(UINib(nibName: "Header", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
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
        desriptionTextView.text = descriptionText == "" ? "defaultDesriptionText".localizableString : descriptionText
        getCurrentCharacterItems(characterId: characterId)
        collectionView.reloadData()
        view.layoutIfNeeded()
    }
    
    func getCurrentCharacterItems(characterId:Int){
        var ts = String(Date().toMillis())
        var apiHash = "\(ts)\(privateApiKey)\(publicApiKey)".md5
        let comicsEndpoint = "https://gateway.marvel.com:443/v1/public/characters/\(characterId)/comics?ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        
        var request = URLRequest(url: URL(string: comicsEndpoint)!)
        request.httpMethod = "GET"
        
        comicsTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let comicList = try JSONDecoder().decode(ResponseModelComic.self, from: data)
                
                comicList.data?.results?.forEach({ (fetchedComic) in
                    let comic = fetchedComic
                    let newComic = Comic(id: comic.id, digitalId: comic.digitalId, title: comic.title, thumbnail: comic.thumbnail)
                    self.comics.append(newComic)
                })
                DispatchQueue.main.async {
                    self.numberOfSections += 1
                    self.collectionView.reloadData()
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        comicsTask?.resume()
        while comicsTask?.state == .running{
            if comicsTask?.state == .completed || comicsTask?.state == .suspended {
                break
            }
        }
        ts = String(Date().toMillis())
        apiHash = "\(ts)\(privateApiKey)\(publicApiKey)".md5
        let eventsEndpoint = "https://gateway.marvel.com:443/v1/public/characters/\(characterId)/events?ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        request = URLRequest(url: URL(string: eventsEndpoint)!)
        request.httpMethod = "GET"
        eventsTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let eventList = try JSONDecoder().decode(ResponseModelEvent.self, from: data)
                eventList.data?.results?.forEach({ (fetchedEvent) in
                    let event = Event(id: fetchedEvent.id,title: fetchedEvent.title, thumbnail: fetchedEvent.thumbnail)
                    self.events.append(event)
                })
                DispatchQueue.main.async {
                    self.numberOfSections += 1
                    self.collectionView.reloadData()
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        eventsTask?.resume()
        
        while eventsTask?.state == .running{
            if eventsTask?.state == .completed || eventsTask?.state == .suspended {
                break
            }
        }
        ts = String(Date().toMillis())
        apiHash = "\(ts)\(privateApiKey)\(publicApiKey)".md5
        let seriesEndpoint = "https://gateway.marvel.com:443/v1/public/characters/\(characterId)/series?ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        request = URLRequest(url: URL(string: seriesEndpoint)!)
        request.httpMethod = "GET"
        seriesTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let seriesList = try JSONDecoder().decode(ResponseModelSeries.self, from: data)
                seriesList.data?.results?.forEach({ (fetchedSeries) in
                    let series = Series(id: fetchedSeries.id,title: fetchedSeries.title, thumbnail: fetchedSeries.thumbnail)
                    self.series.append(series)
                })
                DispatchQueue.main.async {
                    self.numberOfSections += 1
                    self.collectionView.reloadData()
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        seriesTask?.resume()
        
        while seriesTask?.state == .running{
            if seriesTask?.state == .completed || seriesTask?.state == .suspended {
                break
            }
        }
        ts = String(Date().toMillis())
        apiHash = "\(ts)\(privateApiKey)\(publicApiKey)".md5
        let storiesEndpoint = "https://gateway.marvel.com:443/v1/public/characters/\(characterId)/stories?ts=\(ts)&apikey=\(publicApiKey)&hash=\(apiHash)"
        request = URLRequest(url: URL(string: storiesEndpoint)!)
        request.httpMethod = "GET"
        storiesTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let storiesList = try JSONDecoder().decode(ResponseModelStories.self, from: data)
                storiesList.data?.results?.forEach({ (fetchedStory) in
                    let story = Story(id: fetchedStory.id,title: fetchedStory.title, thumbnail: fetchedStory.thumbnail)
                    self.stories.append(story)
                })
                DispatchQueue.main.async {
//                    self.numberOfSections += 1
                    self.collectionView.reloadData()
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        storiesTask?.resume()
    }
    
}

extension CharacterDetailsController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if comicsTask?.state == .running || eventsTask?.state == .running || seriesTask?.state == .running || storiesTask?.state == .running{
            return 0
        }
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if comicsTask?.state == .running || eventsTask?.state == .running || seriesTask?.state == .running || storiesTask?.state == .running{
            return 0
        }
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenCells
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if comicsTask?.state == .running || eventsTask?.state == .running || seriesTask?.state == .running || storiesTask?.state == .running{
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as? Header
        switch indexPath.section {
        case 0:
            header?.characterItemLabel.text = "comicsTitle".localizableString
        case 1:
            header?.characterItemLabel.text = "eventsTitle".localizableString
        case 2:
            header?.characterItemLabel.text = "seriesTitle".localizableString
        default:
            header?.characterItemLabel.text = "storiesTitle".localizableString
        }
        return header ?? UICollectionReusableView()
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 15)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width * 0.8, height: 300)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if comicsTask?.state == .running || eventsTask?.state == .running || seriesTask?.state == .running || storiesTask?.state == .running{
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CharacterItemCell
        cell.passedSection = indexPath.section
        
        cell.passedComics = comics
        cell.passedEvents = events
        cell.passedSeries = series
        cell.passedStories = stories
        cell.delegate = self
        cell.onInnerCollectionlShouldUpdate()
        return cell
    }
}
