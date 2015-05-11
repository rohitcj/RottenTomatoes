//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Rohit Jhangiani on 5/6/15.
//  Copyright (c) 2015 5TECH. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UISearchBarDelegate {

    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkStatusView: UIView!
    @IBOutlet weak var networkStatusLabel: UILabel!
    @IBOutlet weak var moviesTabBar: UITabBar!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // views/controls
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var searchController: UISearchController!
    
    // variables
    var movies: [NSDictionary]? = []
    var movieSearchResults: [NSDictionary] = []
    var isSearchActive = false
    var isNetworkError = false
    
    // constants
    let boxOfficeUrl: String = "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"
    let topDvdsUrl: String = "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // datasources and delegates
        self.tableView.dataSource = self
        self.tableView.delegate = self
        searchBar.delegate = self
        
        self.moviesTabBar.selectedItem = moviesTabBar.items![0] as? UITabBarItem
        
        // add refresh control
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        loadData()
    }
    
    // MARK: - ViewController

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NetworkHelper.startMonitoring()
        // add observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "networkConnected", name: "NetworkConnected", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "networkError", name: "NetworkError", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NetworkHelper.stopMonitoring()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchActive {
            return self.movieSearchResults.count
        }
        if let movies = movies {
            return movies.count
        }   else {
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell
        var movie: NSDictionary = [:]
        
        if self.isSearchActive && movieSearchResults.count > 0  {
            movie = movieSearchResults[indexPath.row]
        } else {
            movie = movies![indexPath.row]
        }
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        let posterImageUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        // cell.posterImageView.setImageWithURL(posterImageUrl)
        let posterImageUrlRequest = NSURLRequest(URL: posterImageUrl)
        
        cell.posterImageView.setImageWithURLRequest(posterImageUrlRequest, placeholderImage: UIImage(named: "Loading"),
            success: { (urlRequest: NSURLRequest!, urlResponse: NSHTTPURLResponse!, image: UIImage!) ->
            Void in
            var transition = CATransition()
            transition.type = kCATransitionFade;
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                transition.duration = 0.1;
            cell.posterImageView.layer.addAnimation(transition, forKey: nil)
            cell.posterImageView.image = image
            },
            failure: { (urlRequest: NSURLRequest!, httpURLResponse: NSHTTPURLResponse!, error: NSError!) ->
            Void in
            })
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - SearchBar
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        isSearchActive = true
        var searchText: String = searchBar.text
        filterSearchResults(searchText)
        searchBar.showsCancelButton = true;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var searchText: String = searchBar.text
        filterSearchResults(searchText)
        searchBar.resignFirstResponder()
        isSearchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        stopSearch()
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        var searchText = searchBar.text
        let trimmedSearchText = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if trimmedSearchText.isEmpty {
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = false
            self.isSearchActive = false
            
        }
        loadData()
        return true
    }
    
    // MARK: - Search Helpers
    
    func stopSearch() {
        searchBar.text = String()
        searchBar.showsCancelButton = false
        self.isSearchActive = false
        searchBar.resignFirstResponder()
        loadData()
    }
    
    func filterSearchResults(searchText: String) {
        let trimmedSearchText = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if trimmedSearchText.isEmpty {
            stopSearch()
            return
        } else {
            self.isSearchActive = true
            movieSearchResults = []
            if let movies = self.movies {
                for movie in movies {
                    let title = movie["title"] as! String
                    let synopsis = movie["synopsis"] as! String
                    if title.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil ||
                        synopsis.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                            movieSearchResults.append(movie)
                    }
                }
            }
        tableView.reloadData()
        }
    }
    
    // MARK: - TabBar

    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        // called when a new view is selected by the user (but not programatically)
       loadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let movieCell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(movieCell)!
        var selectedMovie = [:]
        if self.isSearchActive {
            selectedMovie = movieSearchResults[indexPath.row]
        } else {
            selectedMovie = movies![indexPath.row]
        }
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = selectedMovie
    }
    
    // MARK: - Helpers
    
    func loadData() {
        var loadingHud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingHud.mode = MBProgressHUDMode.Indeterminate
        loadingHud.labelText = "Loading..."
        
        var requestUrl = NSURL()
        
        if (moviesTabBar.selectedItem!.title == "DVDs") {
            requestUrl = NSURL(string: topDvdsUrl)!
        } else {
            requestUrl = NSURL(string: boxOfficeUrl)!
        }
        let request = NSURLRequest(URL: requestUrl)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) ->
            Void in
            if let data = data {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if let json = json {
                self.movies = json["movies"] as! [NSDictionary]?
                self.tableView.reloadData()
                }
            }
        }
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        if (self.refreshControl.refreshing == true) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func onRefresh() {
        loadData()
        refreshControl.endRefreshing()
    }
    
    func networkConnected() {
        if self.isNetworkError {
            networkStatusView.hidden = true
            networkStatusLabel.hidden = true
            tableView.frame =  CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y - networkStatusView.frame.height, tableView.frame.size.width, tableView.frame.size.height);
        }
        self.isNetworkError = false
    }
    
    func networkError() {
        self.isNetworkError = true
        networkStatusView.hidden = false
        networkStatusLabel.hidden = false
        tableView.frame =  CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y + networkStatusView.frame.height, tableView.frame.size.width, tableView.frame.size.height);
        networkStatusLabel.text = "Network Error"
    }
}
