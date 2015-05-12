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
    @IBOutlet weak var audienceScoreLabel: UILabel!
    @IBOutlet weak var criticsScoreLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var synopsisTextView: UITextView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var title: String = movie["title"] as! String
        var rating: String = movie["mpaa_rating"] as! String
        var ratings: NSDictionary = (movie["ratings"] as? NSDictionary)!
        var audienceScore: Int = (ratings["audience_score"] as? Int)!
        var criticsScore: Int = (ratings["critics_score"] as? Int)!
        
        self.title = title
        titleLabel.text! = "\(title) [\(rating)]"
        audienceScoreLabel.text = "Audience Score: \(audienceScore)"
        criticsScoreLabel.text = "Critics Score: \(criticsScore)"
        synopsisTextView.text = movie["synopsis"] as? String
        
        var posterImageUrlStringLowRes: String = movie.valueForKeyPath("posters.original") as! String
        
        var posterImageUrlStringHighRes: String = String()
        var range = posterImageUrlStringLowRes.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            posterImageUrlStringHighRes = posterImageUrlStringLowRes.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        
        // load the low-res image first
        let posterImageUrlLowRes: NSURL = NSURL(string: posterImageUrlStringLowRes)!
        posterImageView.setImageWithURL(posterImageUrlLowRes)
        
        // then load the high-rest image
        let posterImageUrlHighRes: NSURL = NSURL(string: posterImageUrlStringHighRes)!
        let posterImageUrlRequest = NSURLRequest(URL: posterImageUrlHighRes)
        posterImageView.setImageWithURLRequest(posterImageUrlRequest, placeholderImage: UIImage(named: "Loading"),
            success: { (urlRequest: NSURLRequest!, urlResponse: NSHTTPURLResponse!, image: UIImage!) ->
                Void in
                var transition = CATransition()
                transition.type = kCATransitionFade;
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                transition.duration = 1;
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
