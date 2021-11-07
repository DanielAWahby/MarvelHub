//
//  CharacterItemCell.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 02/11/2021.
//

import UIKit

class CharacterItemCell: UICollectionViewCell,UICollectionViewDelegate,UICollectionViewDataSource,CharacterDetailDelegate{
    
    
    //    @IBOutlet weak var itemImage: UIImageView!
    
    
    let secondCellId = "secondCellId"
    var passedSection = 0
    var passedComics = [Comic]()
    var passedEvents = [Event]()
    var passedSeries = [Series]()
    var passedStories = [Story]()
    
    let subItemsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let itemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.userInterfaceIdiom == .phone {
            label.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
        } else {
            label.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.medium)
        }
        label.textAlignment = .left
        label.textColor = UIColor(named: "SubtextColor")
        return label
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(itemLabel)
        itemLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        itemLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        itemLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        addSubview(subItemsCollectionView)
        subItemsCollectionView.dataSource = self
        subItemsCollectionView.delegate = self
        subItemsCollectionView.register(SubItemCell.self, forCellWithReuseIdentifier: secondCellId)
        subItemsCollectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        subItemsCollectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        subItemsCollectionView.topAnchor.constraint(equalTo: self.itemLabel.bottomAnchor, constant: 10).isActive = true
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Cell comics:",passedComics.count)
        print("Cell events:",passedEvents.count)
        switch passedSection {
        case 0:
            return passedComics.count
        case 1:
            return passedEvents.count
        case 2:
            return passedSeries.count
        default:
            return passedStories.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: secondCellId, for: indexPath) as! SubItemCell

//        cell.photoImageView.image = passedImages[indexPath.row]
        if passedComics.count > 0 {
            if passedSection == 0 {
                let path = passedComics[indexPath.row].thumbnail!.path ?? "http://i.annihil.us/u/prod/marvel/i/mg/3/40/4bb4680432f73"
        //        print("Image Path: ",path)
                if path.contains("image_not_available"){
                    cell.photoImageView.image = UIImage(named: "image-placeholder")
                }
                else{
                    let imageVariation = "portrait_small"
                    let imageExtension = passedComics[indexPath.row].thumbnail!.imageExtension ?? ".jpg"
                    let imageUrl = URL(string:"\(path)/\(imageVariation).\(imageExtension)")!
                    do {
                        
                        let imageData = try Data(contentsOf: imageUrl)
                        cell.photoImageView.image = UIImage(data: imageData)
                    } catch{
                        print(error.localizedDescription)
                        cell.photoImageView.image = UIImage(named: "image-placeholder")
                    }
                }
                cell.itemTitle.text = passedComics[indexPath.row].title
                print("Inner comic title:",passedComics[indexPath.row].title)
            }
            else{
                let path = passedEvents[indexPath.row].thumbnail!.path ?? "http://i.annihil.us/u/prod/marvel/i/mg/3/40/4bb4680432f73"
        //        print("Image Path: ",path)
                if path.contains("image_not_available"){
                    cell.photoImageView.image = UIImage(named: "image-placeholder")
                }
                else{
                    let imageVariation = "portrait_small"
                    let imageExtension = passedEvents[indexPath.row].thumbnail!.imageExtension ?? ".jpg"
                    let imageUrl = URL(string:"\(path)/\(imageVariation).\(imageExtension)")!
                    do {
                        
                        let imageData = try Data(contentsOf: imageUrl)
                        cell.photoImageView.image = UIImage(data: imageData)
                    } catch{
                        print(error.localizedDescription)
                        cell.photoImageView.image = UIImage(named: "image-placeholder")
                    }
                }
            }
        }
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.height, height: frame.height)
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item PRessed")
    }
    func onInnerCollectionlShouldUpdate() {
        self.subItemsCollectionView.reloadData()
    }
}

class SubItemCell: UICollectionViewCell {
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let itemTitle:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.2
        label.font = UIFont.systemFont(ofSize: 10.0,weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoImageView)
        photoImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        photoImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        photoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:0).isActive = true
        photoImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        addSubview(itemTitle)
        itemTitle.topAnchor.constraint(equalTo: self.photoImageView.bottomAnchor,constant: 20).isActive = true
        itemTitle.centerXAnchor.constraint(equalTo: self.photoImageView.centerXAnchor).isActive = true
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
