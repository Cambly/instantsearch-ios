---
title: Main Concepts
layout: main.pug
name: concepts
category: main
withHeadings: true
navWeight: 10
editable: true
githubSource: docgen/src/concepts.md
---

**InstantSearch iOS** is a declarative UI library providing widgets and helpers for building native, component-driven UIs with Algolia.
It is built on top of Algolia's [iOS API Client](https://github.com/algolia/algoliasearch-client-swift) and [iOS InstantSearch Core Client](https://github.com/algolia/instantsearch-core-swift) to provide you a high-level solution to quickly build various search interfaces.


In this guide, you will learn the key concepts of InstantSearch iOS.


## InstantSearch Core

The InstantSearch library is built on top of InstantSearch Core. The essence of InstantSearch Core is the **Searcher**, which will wrap an [Algolia API Client](https://github.com/algolia/algoliasearch-client-swift/blob/master/Source/Client.swift) and provide a level of abstraction over it. You can think of InstantSearch Core as the UIKit agnostic library that takes care of everything related to the search session, while InstantSearch is a UIKit dependent library uses InstantSearch Core to offer ready-made configurable widgets that are "search aware" and automatically react to all kinds of search events. For more info about InstantSearchCore, checkout its [community website](https://community.algolia.com/instantsearch-core-swift/).

## Widgets

The core part of InstantSearch iOS are the widgets, which are search-aware UI components that are bound to search events coming from Algolia. We provide some universal widgets such as the [`SearchBar`][widgets-searchbar], the [`Hits`][widgets-hits] or the [`RefinementList`][widgets-refinementlist], and you can easily create new ones by implementing a few protocols (discussed below).

Widgets inherit from the different UIKit `UIViews`, whether it is an advanced `UICollectionView`, or a simple `UISlider`. They are also customizable by exposing `IBInspectable` parameters that can be set right through Interface Builder.

The nice thing about InstantSearch iOS is that you don't have to rewrite your existing `UIViews` to start using the library. In fact, the architecture of the library is mostly protocol-oriented, making it extendible and compatible with your existing UI. It follows Plugin Architecture conventions by providing most of the business logic mostly through protocols, and sometimes through base `UIViewController` classes.

In that way, it is also very easy to create your own search-aware custom widgets. All it takes is implementing one or more protocols depending on the purpose of the widget, and then writing the business logic using the provided properties and methods coming from the protocols.

## Protocols

Let's talk about the 4 most important protocols used throughout InstantSearch iOS. This will help you understand how things work under the hood, and help you write your own custom widgets later on. But first, let's see the 2 types of widgets that we have.

A widget can either be an **input widget** with which the user can interact with (e.g: searchBar), an **output widget** with which the user can see results (e.g: hits), or both (e.g: refinementList). In both cases, all widgets implement the `AlgoliaWidget` protocol, which is an empty marker protocol used to identify all Algolia related widgets in the `UIView's ViewController`.

```swift
class SliderWidget: UISlider, AlgoliaWidget {}
```

An input widget will implement `SearchableViewModel`. By implementing this protocol, the widget will have a reference to `Searcher`, and will therefore be able to use it to trigger methods such as `#search()` (e.g: `UISearchBar`), or `#params.updateNumericRefinement` (e.g: `UISlider`).

```swift
A implements SearchableViewModel -> searcher.search(query)
B implements SearchableViewModel -> searcher.params.updateNumericRefinement()
```

An output widget is basically a delegate that reacts to new "search events" that are triggered by the user interacting with an input widget, whether it is writing in a search bar or selecting a new filter. An output widget can implement one of the 2 following protocols: 

`ResultingDelegate` where the widget can process the results or handle the error of a search request to Algolia.

```swift
                                          ┌-> A implements ResultingDelegate
searcher.search(query) -> InstantSearch --┤
                                          └-> B implements ResultingDelegate
```

`RefinableDelegate` where the widget receives events when search parameters are being altered in the `Searcher`.



```swift
                                                             ┌-> A implements RefinableDelegate
searcher.params.updateNumericRefinement() -> InstantSearch --┤
                                                             └-> B implements RefinableDelegate
```




## Add Widgets

In order to add a widget to InstantSearch, there are 2 methods you can call. First you can call `InstantSearch.registerAllWidgets(in view: UIView)`, which will add all the `AlgoliaWidget` subviews found inside the `view` param. This is usually useful when your widgets are added to your ViewController, so all you have to do inside your ViewController is calling `InstantSearch.registerAllWidgets(in self.view)`.
If you want finer control over what you add, then you can use `InstantSearch.register(widget: AlgoliaWidget)`.

## Query params

If you're not using InstantSearch and using either the API client or InstantSearchCore, you're probably familiar with the `Query` or `SearchParameters` classes. These usually specify the query string and the parameters used for the search request to Algolia. 

With InstantSearch widgets, you don't have to worry about these classes anymore. In fact, the widgets will set all the parameters for you behind the scenes, without you having to worry about it. All what you will have to do on your side is specify a few properties linked to a specific widget, and you'll be good to go!

However, sometimes, you will still want to modify and configure some functionalities available on the `Searcher` level but not on the `InstantSearch` level. In that case, `InstantSearch` still gives you access to a reference to its `Searcher` in order for you to do just that.

## Configuring InstantSearch

There are two ways you can configure and initialize InstantSearch in iOS.

### Singleton

You can use the singleton shared reference of InstantSearch throughout your app. For that, you can simply use the publicly available `InstantSearch.shared`.

### Instance 

Another way to deal with InstantSearch is to just instantiate an `InstantSearch` instance with one of its constructors. Note that in this case, you will have to take the responsibility of passing that reference between different screens.

[widgets-hits]: widgets.html#hits
[widgets-searchbar]: widgets.html#searchbar
[widgets-refinementlist]: widgets.html#refinementlist
[widgets-stats]: widgets.html#stats

## ViewModels 

As we've seen, InstantSearch iOS provides widgets out of the box. Those are great when you want a default style to be applied and you do not need heavy customization of the behavior of the widget.

Hence come the idea of ViewModels, which are used when you want to have full control on the rendering without having to reimplement business logic. As soon as you hit a feature wall using our default widgets, you can use ViewModels to have more flexibility. 

At the end of the day, the ViewModels encapsulate the logic for a specific search concept and provide a way to interact with InstantSearch.

### SearchViewModel

Use this to customize any kind of search box. 

#### Methods

- `search(query:)`

#### Example

```swift
@IBOutlet weak var searchBar: SearchBarWidget!
var searchViewModel: SearchViewModel!

override func viewDidLoad() {
        super.viewDidLoad()
        
        searchViewModel = SearchViewModel(view: searchBar)
        InstantSearch.shared.register(viewModel: searchViewModel)

        // Now can access access the searchBar's delegate
        searchBar.delegate = self
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Call the search function of the viewModel. It will take care of changing the 
        // search state and sending search events when new results arrive.
        searchViewModel.search(query: searchText)
    }
```

### HitsViewModel

Use this to customize a hits view with only 1 index. 

#### Methods

- `numberOfRows()`
- `hitForRow(at:)`

#### Example

```swift
@IBOutlet weak var tableView: HitsTableWidget!
var hitsViewModel: HitsViewModel!

override func viewDidLoad() {
        super.viewDidLoad()
        
        hitsViewModel = HitsViewModel(view: tableView)
        InstantSearch.shared.register(viewModel: hitsViewModel)

        // Now can access access the tableView's delegate and datasource methods.
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hitsViewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let hit = hitsViewModel.hitForRow(at: indexPath)
        cell.textLabel?.text = getTextOutOfHit(hit)
        
        return cell
    }
```

### MultiHitsViewModel

Use this to customize a hits view with only multiple indices. 

#### Methods

- `numberOfRows(in:)`
- `hitForRow(at:)`
- `numberOfSections()`

#### Example

```swift
@IBOutlet weak var tableView: MultiHitsTableWidget!
var multiHitsViewModel: MultiHitsViewModel!

override func viewDidLoad() {
        super.viewDidLoad()
        
        multiHitsViewModel = MultiHitsViewModel(view: tableView)
        InstantSearch.shared.register(viewModel: multiHitsViewModel)

        // Now can access access the tableView's delegate and datasource methods.
        tableView.dataSource = self
        tableView.delegate = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return multiHitsViewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return multiHitsViewModel.numberOfRows(in: section)
    }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let hit = multiHitsViewModel.hitForRow(at: indexPath)

        if indexPath.section == 0 { // First index
            cell.textLabel?.text = getTextOutOfHitWithFirstIndex(hit)
        } else { // Second index
            cell.textLabel?.text = getTextOutOfHitWithSecondIndex(hit)
        }
        
        return cell
    }
```

### NumericControlViewModel

Use this to customize any kind of numeric control view. 

#### Methods

- `updateNumeric(value:doSearch:)`
- `removeNumeric(value:)`

### FacetControlViewModel

Use this to customize any kind of facet control view. 

#### Methods

- `addFacet(value:doSearch:)`
- `updatefacet(oldValue:newValue:doSearch:)`
- `removeFacet(value:)`

### RefinementMenuViewModel

Use this to customize any kind of refinement menu view. 

#### Methods

- `numberOfRows()`
- `facetForRow(at:)`
- `isRefined(at:)`
- `didSelectRow(at:)`

