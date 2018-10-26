---
title: Widgets
layout: main.pug
name: widgets
category: main
withHeadings: true
navWeight: 2
editable: true
githubSource: docgen/src/widgets.md
---

## SearchBar
<img src="assets/img/widgets/searchbox.png" class="img-object" align="right" width="300"/>

The **SearchBar** widgets are made to query the Algolia service on each keystroke. It is the main component of a search experience.

There are 3 ways to use a **SearchBar** in your app with InstantSearch.

- The **SearchBarWidget** which is a specialized `UISearchBar`. Since it inherits from `UISearchBar`, it supports all of its existing attributes. 
- The **TextFieldWidget** which is a specialized `UITextField`. Also, it supports all of `UITextField`'s existing attributes.
- Using `InstantSearch.register(searchController:)` for a `UISearchController` or `InstantSearch.register(searchBar:)` for a `UISearchBar` in order for InstantSearch to subscribe to typing events and automatically send search events to Algolia on each new keystroke.

As with any `UIView`, you can specify the first 2 widgets in two ways:

- **Interface builder** by drag and dropping a Search Bar from the _Object library_, and then specifying `SearchBarWidget` as its Custom class inside the _Identity Inspector_.

- **Programatically** with the following snippet of code: 

```swift
var searchBar = SearchBarWidget(frame: CGRect)
// var searchBar = TextFieldWidget(frame: CGRect)
self.view.addSubview(searchBar)
```

## ActivityIndicator

A useful pattern to improve your user's experience consists in displaying a progress indicator when there are ongoing requests still waiting to complete. This activity indicator will spin as long as some requests are still incomplete. 

You can use the `ActivityIndicatorWidget` for that purpose. you can specify it in two ways:

- **Interface builder** by drag and dropping an Activity Indicator View from the _Object library_, and then specifying `ActivityIndicatorWidget` as its Custom class inside the _Identity Inspector_.

- **Programatically** with the following snippet of code: 

```swift
let activityIndicator = ActivityIndicatorWidget(frame: CGRect)
self.view.addSubview(activityIndicator)
```

## Hits

The **Hits** widgets are made to display your search results in a flexible way. They are reloaded automatically when new hits are fetched from Algolia so you don't have to worry about that. We offer two Hits widget in InstantSearch: A `HitsTableWidget` built over a `UITableView`, and a `HitsCollectionWidget` built over a `UICollectionView`.

This widget exposes a few attributes that you can set either in Interface Builder or programatically:

- **`hitsPerPage`** controls how many hits are requested and displayed with each search query. (defaults to 20)
- **`infiniteScrolling`**, when `false`, disables the infinite scroll of the hits widget (defaults to `true`)
- **`remainingItemsBeforeLoading`** sets the minimum number of remaining hits to load the next page: if you set it to 10, the next page will be loaded when there are less than 10 items below the last visible item. (defaults to 5)
- **`showItemsOnEmptyQuery`**, when `false`, will display an empty hits widget when there is no query text entered by the user (defaults to `true`)

If you are familiar with how `UITableview` and `UICollectionView` work, you know that their `delegate` and `dataSource` methods need to be handled in order to specify their layout and data. InstantSearch will help you take care of that while still letting you specify the look and feel of your widget.

### Delegate and DataSource

In order to handle the Delegate and DataSource of a Hits widget, we provide 2 ways to achieve that:

#### ViewController Inheritance
In this method, your `ViewController` will inherit from `HitsTableViewController` or `HitsCollectionViewController`. These **bases classes** will take care of a lot of things for you like creating the necessary properties under the hood, hooking the `delegate` and the `dataSource` of the hits widget behind the scenes. What you need to do on your end is the following: 

- Have your `ViewController` inherit from `HitsTableViewController` or `HitsCollectionViewController`.
- In `viewDidLoad`, assign `hitsTableView` to your hits widget, whether it was created programatically or through Interface Builder.
- At the end of `ViewDidLoad`, call `InstantSearch.shared.registerAllWidgets(in: self.view)` to add your widget to `InstantSearch`.
- To specify the look and feel of your cell, override one of the two methods which will give you access to the hit:
	-  `tableView(_:cellForRowAt:containing:)`
	-  `collectionView(_:cellForItemAt:containing:)`
- *Optional*: To specify what happens when a hit is selected, override one of the two methods:
	- `tableView(_:didSelectRowAt:containing:)`
	- `collectionView(:didSelectItemAt:containing:)`

Here is an example:

```swift
class HitsTableViewControllerDemo: HitsTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hitsTableView = HitsTableWidget()
        hitsTableView.frame = self.view.frame
        hitsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "hitTableCell")
        
        self.view.addSubview(hitsTableView)
        
        InstantSearch.shared.registerAllWidgets(in: self.view)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, containing hit: [String : Any]) -> UITableViewCell {
        let cell = hitsTableView.dequeueReusableCell(withIdentifier: "hitTableCell", for: indexPath)
        cell.textLabel?.text = hit["name"] as? String   
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, containing hit: [String : Any]) {
        print("hit \(String(describing: hit["name"]!)) has been clicked")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("I can also edit height! or any other method")
        return 50
    }

```

Note that you can override any `delegate` or `dataSource` method like `heightForRowAt`. So you have full control over every aspect of your UITableView/UICollectionView by using this method.


#### ViewController Composition

In this method, your `ViewController` will own a `HitsController` object. You will need to specify what hit widget is _controlled_ by the `HitsController`, whether a `HitsTableWidget` or `HitsCollectionWidget`, and then assign the `dataSource` and `delegate` properties of the widget to the `HitsController`. In that way, you are telling the `HitsController`: _please take care of the `delegate` and `dataSource` methods for me please_.

There is still one thing we talked about in the previous section: specifying the data and the behaviour of the widget. The `HitsController` provides `tableDataSource` and `tableDelegate` properties for the `HitsTableWidget`, as well as `collectionDataSource` and `collectionDelegate` for the `HitsCollectionWidget`. The `ViewController` will therefore need to implement a few protocols to be able to specify the hit cells and their onClick behaviour. The protocols to implement are:

- **`HitsTableViewDataSource`**: Specify the rendering of the table hit cells
- **`HitsTableViewDelegate`**: Specify what happens when table hit cell is clicked
- **`HitsCollectionViewDataSource`**: Specify the rendering of the collection hit cells
- **`HitsCollectionViewDelegate`**: Specify what happens when collection hit cell is clicked

Here is an example:

```swift
import InstantSearch

class ViewController: UIViewController, HitsTableViewDataSource, HitsTableViewDelegate {
    
    var instantSearch: InstantSearch!
    @IBOutlet weak var hitsTable: HitsTableWidget!
    var hitsController: HitsController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hitsController = HitsController(table: hitsTable)
        hitsTable.dataSource = hitsController
        hitsTable.delegate = hitsController
        hitsController.tableDataSource = self
        hitsController.tableDelegate = self
        
        InstantSearch.shared.registerAllWidgets(in: self.view)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, containing hit: [String : Any]) -> UITableViewCell {
        let cell = hitsTable.dequeueReusableCell(withIdentifier: "hitCell", for: indexPath)
        cell.textLabel?.text = hit["name"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, containing hit: [String: Any]) {
        print("hit \(String(describing: hit["name"]!)) has been clicked")
    }
    
    func viewForNoResults(in tableView: UITableView) -> UIView {
    	// Specify a View when no results are returned from Algolia
    }
```

The downside of using this method is that it's hard to specify additional `delegate` and `dataSource` methods since they are assigned to the `HitsController` and not to the `ViewController` itself. If you want to do that, then it's preferable that you use the first inheritance method. 

### Infinite scroll

An infinite scroll mechanism is built-in to load more results as the user scrolls.
Enabled by default, it will watch the state of the Hits to load more results before the user reaches the end of the current page.

As explained [in the attributes description](#hits), you can use the attributes `remainingItemsBeforeLoading` and `infiniteScrolling` to control or disable this feature.

### Empty View

The Hits widget implements an empty view mechanism to display an alternative View if there are no results to display. For that, you can use the `HitsTableViewDataSource` or the `HitsCollectionViewDataSource` method:

- `viewForNoResults(in tableView: UITableView) -> UIView` 
- `viewForNoResults(in collectionView: UICollectionView) -> UIView`.

### Highlighting

Visually highlighting the search result is [an essential feature of a great search interface][explain-highlighting]. It will help your users understand your results by explaining them why a result is relevant to their query.

In order to add highlighting to your Hits widget, we offer a utility method and `UILabel` stored properties. Note that you have to import `InstantSearchCore` in order to have access to the utility method. There are a few attributes that you can specify to your highlighted label:

- **`isHighlightingInversed`**: whether the highlighting is reversed or not.
- **`highlightedTextColor `**: The text color of the highlighting (optional).
- **`highlightedBackgroundColor `**: The background color of the highlighting (optional).
- **`highlightedText `**: The text that is highlighted. Here we need to use the utility method `SearchResults.highlightResult(hit: hit, path: "your_attribute")?.value` 

Here is an example:

```swift
import InstantSearchCore

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, containing hit: [String : Any]) -> UITableViewCell {
        let cell = hitsTable.dequeueReusableCell(withIdentifier: "hitCell", for: indexPath)
        
        cell.textLabel?.isHighlightingInversed = true
        cell.textLabel?.highlightedTextColor = .black
        cell.textLabel?.highlightedBackgroundColor = .yellow
        cell.textLabel?.highlightedText = SearchResults.highlightResult(hit: hit, path: "name")?.value
        
        return cell
    }
```

For more info, check the guide on highlighting in the [InstantSearch Core guide](https://community.algolia.com/instantsearch-core-swift/guide/highlighting.html).

## RefinementList

The **RefinementList** is a filtering widget made to display your [facets](https://www.algolia.com/doc/guides/search/filtering-faceting#faceting) and let the user refine the search results. We offer two RefinementList widget in InstantSearch: A `RefinementTableWidget` built over a `UITableView`, and a `RefinementCollectionWidget` built over a `UICollectionView`.

Five attributes allow you to configure how it will filter your results:

- **`attribute`** defines which faceted attribute will be used by the widget.
- **`operator`** can either be `"or"` or `"and"`, to control if the results should match *any* selected value or *all* selected values. (defaults to `"or"`)
- **`limit`** is the maximum amount of facet values we will display (defaults to 10). If there are more values, we will display those with the bigger counts.
- **`isRefined`** defines whether the refined values are displayed first or not (defaults to `true`)
- **`sortBy`** controls the sort order of the attributes. You can either specify a single value or an array of values to apply one after another.

  This attribute accepts the following values:
  - `count:asc` to sort the facets by ascending count
  - `count:desc` to sort the facets by descending count
  - `name:asc` to sort the facet values by alphabetical order
  - `name:desc` to sort the facet values by reverse alphabetical order

For specifying the layout of your refinement cells, we follow the exact same methodology as the one described in the Hits section above. Here is a stripped down version: 

### Delegate and DataSource

In order to handle the Delegate and DataSource of a RefinementList widget, we provide 2 ways to achieve that:

#### ViewController Inheritance

- Have your `ViewController` inherit from `RefinementTableViewController` or `RefinementCollectionViewController`.
- In `viewDidLoad`, assign `refinementTableView` to your refinement widget, whether it was created programatically or through Interface Builder.
- At the end of `ViewDidLoad`, call `InstantSearch.shared.registerAllWidgets(in:)` to add your widget to `InstantSearch`.
- To specify the look and feel of your cell, override one of the two methods:
	- `tableView(_:cellForRowAt:containing:with:is:)`
	- `collectionView(_:cellForItemAt:containing:with:is:) -> UICollectionViewCell` 
- *Optional*: To specify what happens when a refinement is selected, override one of the two methods: 
	- `tableView(_:didSelectRowAt:containing:with:is:)`          
	- `collectionView(_:didSelectItemAt:containing:with:is:)` 

Here is an example:

```swift
import InstantSearch

class RefinementTableViewControllerDemo: RefinementTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refinementTableView = RefinementTableWidget()
        refinementTableView.attribute = "category"
        refinementTableView.frame = self.view.frame
        
        self.view.addSubview(refinementTableView)
        InstantSearch.shared.registerAllWidgets(in: self.view)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, containing facet: String, with count: Int, is refined: Bool) -> UITableViewCell {
        var cell = refinementTableView.dequeueReusableCell(withIdentifier: "refinementCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "refinementCell")
        }
        
        cell!.textLabel?.text = facet
        cell!.detailTextLabel?.text = String(count)
        cell!.accessoryType = refined ? .checkmark : .none
        
        return cell!
    }
}
```

#### ViewController Composition
In this method, your `ViewController` will own a `RefinementController` object.

he `RefinementController` provides `tableDataSource` and `tableDelegate` properties for the `RefinementTableWidget`, as well as `collectionDataSource` and `collectionDelegate` for the `RefinementCollectionWidget`.

The protocols to implement are:

- **`RefinementTableViewDataSource`**: Specify the rendering of the table refinement cells
- **`RefinementTableViewDelegate`**: Specify what happens when table refinement cell is clicked
- **`RefinementCollectionViewDataSource`**: Specify the rendering of the collection refinement cells
- **`RefinementCollectionViewDelegate`**: Specify what happens when collection refinement cell is clicked

Here is an example:

```swift
import InstantSearch

class RefinementTableViewDataSourceDemo: UIViewController, RefinementTableViewDataSource {
    
    var instantSearch: InstantSearch!
    @IBOutlet weak var refinementList: RefinementTableWidget!
    
    var refinementController: RefinementController!
    
    override func viewDidLoad() {
        refinementController = RefinementController(table: refinementList)
        refinementList.dataSource = refinementController
        refinementList.delegate = refinementController
        refinementController.tableDataSource = self
        // refinementController.tableDelegate = self
        
        instantSearch = InstantSearch.shared
        instantSearch.register(widget: refinementList)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, containing facet: String, with count: Int, is refined: Bool) -> UITableViewCell {
        let cell = refinementList.dequeueReusableCell(withIdentifier: "facetCell", for: indexPath)
        
        cell.textLabel?.text = facet
        cell.detailTextLabel?.text = String(count)
        cell.accessoryType = refined ? .checkmark : .none
        
        return cell
    }
}
```

## Numeric Refinements

**Numeric Refinements** are widgets which take care of numeric filters. Possible ones are:

- **`SliderWidget`** inherits from `UISlider`.
- **`StepperWidget`** inherits from `UIStepper`.
- **`DatePickerWidget`** inherits from `UIDatePicker`.

You can configure them with three attributes:

- **`attribute`** defines which faceted attribute will be used by the widget.
- **``operator``** defines the numeric operator to apply to the filter. Possible ones are `<`, `<=`, `==`, `!=`, `>=`, `>`.
- **`inclusive`** defines whether the refinement is inclusive (default) or exclusive.

## Facet Refinements

**Facet Refinements** are widgets which take care of facet filters. Possible ones are:

- **`OneValueSwitchWidget`** inherits from `UISwitch`.
- **`TwoValuesSwitchWidget`** inherits from `UISwitch `.
- **`SegmentedControlWidget`** inherits from `UISegmentedControl`.

You can configure them with two attributes:

- **`attribute`** defines which faceted attribute will be used by the widget.
- **`inclusive`** defines whether the refinement is inclusive (default) or exclusive.

You also have to configure the SwitchWidgets with more parameters: 

- **`valueOn`** Used for faceting when the Switch is on. Example "Free Shipping".
- **`valueOff`** Used for faceting when the Switch is off. Example "isAdmin" for `valueOff` and "isUser" for `valueOn`.
 
## Stats
<img src="assets/img/widgets/stats.png" class="img-object" align="right" width="250"/>

**Stats** are widgets for displaying statistics about the current search result. Possible ones are: 

- **`StatsButtonWidget`** inherits from `UIButton`
- **`StatsLabelWidget`** inherits from `UILabel`

You can configure them with two attributes:

- **`resultTemplate`** defines what this widget will display when a search request returns successfully. It takes the form of a templated string where we will replace the following templates:
  - `{nbHits}` will be replaced by the hit count for the current query
  - `{processingTimeMS}` will be replaced by the time the server took to process the request, in milliseconds
  - `{hitsPerPage}` will be replaced by the maximum number of hits returned per page
  - `{nbPages}` will be replaced by the number of pages corresponding to the number of hits
  - `{page}` will be replaced by the index of the current page (zero-based)
  - `{query}` will be replaced by the query text

  The default `resultTemplate` is `"{nbHits} results"`.

- **`errorText`** defines what this widget will display when a search query returns with an error.

## Custom widgets

If none of these widgets fits your use-case, you can implement your own!

Any class implementing the `AlgoliaWidget`protocol can be added to InstantSearch and will be able to manage the search state or receive specific search events.

These are the protocols that you can add to your class:

- **`SearchableViewModel`**: the widget will have a reference to `Searcher` by implementing function `configure(with:)`, and will therefore be able to use it to trigger methods such as `search()` (e.g: `UISearchBar`), or `updateNumericRefinement()` (e.g: `UISlider`).
- **`ResultingDelegate`**: the widget can process the results or handle the error of a search request to Algolia by implementing `on(results:error:userInfo:)`.
- **`RefinableDelegate`**: the widget receives events when search parameters are being altered in the `Searcher`. The widget will have to specify the refinement `attribute` that it is associated with, and then can subscribe to 4 different methods:
	- `onRefinementChange(numericMap:)` for a change in any numeric refinements.
	- `onRefinementChange(numerics:)` for a change in the numeric refinement associated with the widget's attribute.
	- `onRefinementChange(facetMap:)` for a change in any facet refinements.
	- `onRefinementChange(facets:)` for a change in the facet refinement associated with the widget's attribute. 

**Note**: In order to deal with Custom widgets, you need to import `InstantSearchCore`.

[media-url]: https://github.com/algolia/instantsearch-android-examples/tree/master/media
[ecommerce-url]: https://github.com/algolia/instantsearch-android-examples/tree/master/ecommerce
[explain-highlighting]: https://www.algolia.com/doc/faq/searching/what-is-the-highlighting/
[docs-searcher]: /javadoc/com/algolia/instantsearch/helpers/Searcher.html
