//
//  CharacterItemCell.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 02/11/2021.
//

import UIKit

// MARK:- Definition of protocol required for presenting the item's overlay view from the inner collectionView cell through the Character Details controller
protocol ItemSelectionDelegate: NSObjectProtocol {
     func presentPopOverViewController(image:UIImage,itemName:String) -> ()
}

// MARK:- CollectionView cell for the Character Details Controller

class CharacterItemCell: UICollectionViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CharacterDetailDelegate{
//     MARK:- An identifier for the inner collection cell within the upper main cell
     let innerItemIdentifier = "characterInnerItemIdentifier".localizableString

//     MARK:- Passed section number from Character Details View Controller to cell
     var passedSection = 0

//     MARK:- Passed Items from View Controller to cell
     var passedComics = [Comic]()
     var passedEvents = [Event]()
     var passedSeries = [Series]()
     var passedStories = [Story]()
     
//     MARK:- An instance of the protocol defined above to be used within the cell.
     weak var delegate : ItemSelectionDelegate?

//     MARK:- Defining the inner collection view that includes all items within each character's item category.
     let subItemsCollectionView: UICollectionView = {
          let layout = UICollectionViewFlowLayout()
          layout.scrollDirection = .horizontal
          let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
          collectionView.backgroundColor = .clear
          collectionView.translatesAutoresizingMaskIntoConstraints = false
          return collectionView
     }()
     
     
     
     
     override init(frame: CGRect) {
          super.init(frame: frame)
//          MARK:- Adding the inner collection view to the cell's view and defining its delegate and datasource properties.
          addSubview(subItemsCollectionView)
          subItemsCollectionView.dataSource = self
          subItemsCollectionView.delegate = self
//          MARK:- Registration of the inner collection view cell.
          subItemsCollectionView.register(SubItemCell.self, forCellWithReuseIdentifier: innerItemIdentifier)

//          MARK:- Programmatically adding the inner collection view's layout constraints.
          addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0" : subItemsCollectionView]))
          addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0" : subItemsCollectionView]))
          
          
     }
     
     required init?(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
     }
//     MARK:- Defining the number of items in each character item categories.
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
//     MARK:- Defining the number of sections of the inner collection view. The number is set to '1' since we treat each cell that is dequeued from the view controller as its own section that contains the items of a category
     
     func numberOfSections(in collectionView: UICollectionView) -> Int {
          return 1
     }
//     MARK:- Dequeuing the inner collectionview cells.
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: innerItemIdentifier, for: indexPath) as! SubItemCell
          cell.cellSection = passedSection
          cell.itemTitle.text = getTitleForInnerCell(section: passedSection, row: indexPath.row)
          cell.photoImageView.image = getImageForInnerCell(section: passedSection, row: indexPath.row)
          return cell
          
     }
// MARK:- Size for each inner item.
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          return CGSize(width: frame.width / 3 - 10, height: 150)
     }
// MARK:- Calling the delegate method when an inner collection view cell is pressed
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          let section =  (collectionView.dequeueReusableCell(withReuseIdentifier: innerItemIdentifier, for: indexPath) as! SubItemCell).cellSection
          self.delegate?.presentPopOverViewController(image: getImageForInnerCell(section: section, row: indexPath.row), itemName: getTitleForInnerCell(section: indexPath.section, row: indexPath.row))
     }
//     MARK:- A function used to notify this view cell that it should update its inner collectionView.
     func onInnerCollectionlShouldUpdate() {
          self.subItemsCollectionView.reloadData()
     }
//    MARK:- A function used to retrieve each item's image given the the item's current section (category) and its row (index within the cetgory array).
     func getImageForInnerCell(section:Int,row:Int)->UIImage{
          var cellImage = UIImage(contentsOfFile: "")
          var path = "defaultImagePath".localizableString
          var imageExtension = "defaultImageExtension".localizableString
         
          switch section {
          case 0:
               path = passedComics[row].thumbnail?.path ?? "defaultImagePath".localizableString
               imageExtension = passedComics[row].thumbnail?.imageExtension ?? ""
          case 1:
               path = passedEvents[row].thumbnail?.path ?? "defaultImagePath".localizableString
               imageExtension = passedEvents[row].thumbnail?.imageExtension ?? ""
          case 2:
               path = passedSeries[row].thumbnail?.path ?? "defaultImagePath".localizableString
               imageExtension = passedSeries[row].thumbnail?.imageExtension ?? ""
          case 3:
               path = passedStories[row].thumbnail?.path ?? "defaultImagePath".localizableString
               imageExtension = passedStories[row].thumbnail?.imageExtension ?? ""
          default:
               path = "defaultImagePath".localizableString
               imageExtension = "defaultImageExtension".localizableString
          }
          if path.contains("image_not_available"){
               cellImage = UIImage(named: "image-placeholder")
          }
          else{
               let imageVariation = "portrait_incredible"
               
               let imageUrl = URL(string:"\(path)/\(imageVariation).\(imageExtension)")!
               do {
                    
                    let imageData = try Data(contentsOf: imageUrl)
                    cellImage = UIImage(data: imageData)
               } catch{
                    print(error.localizedDescription)
                    cellImage = UIImage(named: "image-placeholder")
               }
          }
          
          return cellImage ?? UIImage(named: "image-placeholder")!
     }
//    MARK:- A function used to retrieve each item's title text given the the item's current section (category) and its row (index within the cetgory array).
     func getTitleForInnerCell(section:Int,row:Int)->String{
          var title = "Item Title"
          switch section{
          case 0:
               title = passedComics[row].title ?? "defaultComicTitle".localizableString
          case 1:
               title = passedEvents[row].title ?? "defaultEventTitle".localizableString
          case 2:
               title = passedSeries[row].title ?? "defaultSeriesTitle".localizableString
          default:
               title = passedStories[row].title ?? "defaultStoryTitle".localizableString
          }
          return title
     }
}
// MARK:- Definition of the Inner Item Cell.
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
          label.textAlignment = .left
          label.textColor = .white
          label.numberOfLines = 0
          label.minimumScaleFactor = 0.1
          label.font = UIFont.systemFont(ofSize: 10.0,weight: .bold)
          return label
     }()
     var cellSection = 0
     override init(frame: CGRect) {
          super.init(frame: frame)
          addSubview(photoImageView)
//          MARK:- Programmatically adding the inner cell's layout constraints for the inner cell's imageView and title label.

          photoImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
          photoImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
          photoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:0).isActive = true
          photoImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: -30).isActive = true
          addSubview(itemTitle)
          itemTitle.topAnchor.constraint(equalTo: self.photoImageView.bottomAnchor,constant: 20).isActive = true
          itemTitle.centerXAnchor.constraint(equalTo: self.photoImageView.centerXAnchor).isActive = true
          itemTitle.widthAnchor.constraint(equalTo: self.photoImageView.widthAnchor, multiplier: 1).isActive = true
     }
     
     
     
     required init?(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
     }
     
     
}
