//
//  MovieDetailsViewController.swift
//  RottenTomatoes
//
//  Created by Rohit Jhangiani on 5/6/15.
//  Copyright (c) 2015 5TECH. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String
        
        var posterImageUrlString: String = movie.valueForKeyPath("posters.original") as! String
        
        var range = posterImageUrlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            posterImageUrlString = posterImageUrlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        
        // let posterImageUrl = NSURL(string: movie.valueForKeyPath("posters.original") as! String)!
        let posterImageUrl = NSURL(string: posterImageUrlString)!

        posterImageView.setImageWithURL(posterImageUrl)
        
        let posterImageUrlRequest = NSURLRequest(URL: posterImageUrl)
        
        posterImageView.setImageWithURLRequest(posterImageUrlRequest, placeholderImage: UIImage(named: "Loading"),
            success: { (urlRequest: NSURLRequest!, urlResponse: NSHTTPURLResponse!, image: UIImage!) ->
                Void in
                var transition = CATransition()
                transition.type = kCATransitionFade;
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                transition.duration = 0.1;
                self.posterImageView.layer.addAnimation(transition, forKey: nil)
                self.posterImageView.image = image
            },
            failure: { (urlRequest: NSURLRequest!, httpURLResponse: NSHTTPURLResponse!, error: NSError!) ->
                Void in
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
