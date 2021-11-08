# MarvelHub
![Marvel Logo](https://user-images.githubusercontent.com/38701255/140772302-3f2e801e-9501-4b55-9301-889cada86d5c.png)

## Design:
  ### The app is divided into 3 main view controllers (*All Characters Controller*, *Search Controller* and *Character Details Controller*).
  1. The *All Characters Controller* is considered the home screen where all the characters are initially retrieved, using an API call to Marvel, with their basic attributes, such as ther names, photos, descriptions and ids. Each character is then represented in a tableView cell that is can be selected to display even more details for each character in the "Character Details Controller". The tableView in this controller only required the creation of just one custom *UITableViewCell*, that is used to store the character's name and image.
  2. The *Search Controller* which enables you to search for character by name through entering a search term, then an API call is made to Marvel, retrieveing the characters names and pictures. The tableView in this controller only required the creation of just one custom *UITableViewCell* for the results, that is used to store the resulting characters' names and images.
  3.  The *Character Details Controller* includes the basic details of each individual character retrieved in the "All Character Controller", in addition to more items relevant to each character including comics, events, series and stories they appeared in. The collectionView in this controller required the creation of just one custom *UICollectionViewCell*, to store each category items in, and one custom *UICollectionReusableView* of the *Header* kind, to store the name of each category.

## Challenges Faced:
  1. The app most challenging aspect of the task was the implementation of the *collectionView* in the *Character Details Controller* as it require the addition of a an innner collectionView with a horizontal scrolling direction within each cell of the character items' categories (comics, events, series, and stories), a task that seemed the most fun and rewarding to implement.
  2. The prefetching in the *All Characters Controller*'s tableView required me to tweak some of the API request parameters such as the *limit* and *offset* parameters which were a bit challeging to pass into the request's body as Swift's newest implementation of **URLRequest** doesn't allow you to add an http body to your **GET** request, so I added these parameter to the actual URL of the API Endpoint instead which resolved the problem.

## Third Party Cocoapods:
   1. [NVActiNVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView) was used for the Arc Reactor loader view.
   2. [Alamofire](https://github.com/Alamofire/Alamofire) was considered for handling API requests but ended up not being used for the task and using Swift's native **URLRequest** and **URLSessionDataTask** instead.
   3. [SwiftJSON](https://github.com/SwiftyJSON/SwiftyJSON) was considered for decoding JSON objects but ended up using Swift's native **JSONDecoder** instead.
