//
//  CharacterDetailsController.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 02/11/2021.
//

import UIKit

class CharacterDetailsController: UIViewController {
    
    let cellIdentifier = "characterItem"
    var imagePath = ""
    var imageExtension = ""
    var characterName = ""
    var descriptionText = ""
    
    
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
