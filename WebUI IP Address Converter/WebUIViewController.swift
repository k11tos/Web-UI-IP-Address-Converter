//
//  FirstViewController.swift
//  WebUI IP Address Converter
//
//  Created by Jang Hyeon Lee on 2016. 4. 11..
//  Copyright © 2016년 Jang Hyeon Lee. All rights reserved.
//

import UIKit

class WebUIViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var networkStatusLabel: UILabel!
    
    var reachability:Reachability?
    var str:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.webView.delegate = self
        
        setupReachability()
        startNotifier()
        
        loadWebSite("")
        networkStatusLabel.text = "Not connected"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.spinner.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.spinner.stopAnimating()
        
        let alert = UIAlertController(title: "오류", message: "페이지를 읽어오지 못했습니다.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "확인", style: .Cancel) {(_) in
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: false, completion: nil)
    }
    
    func setupReachability() {
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            self.reachability = reachability
        } catch ReachabilityError.FailedToCreateWithAddress(_) {
            return
        } catch {}
        
        
        reachability?.whenReachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                self.updateSiteWhenReachable(reachability)
            }
        }
        reachability?.whenUnreachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                self.updateSiteWhenNotReachable(reachability)
            }
        }
        
    }

    func updateSiteWhenReachable(reachability: Reachability) {
        if reachability.isReachableViaWiFi() {
            loadWebSite("http://0.0.0.0")
            networkStatusLabel.text = "WIFI"
        } else {
            loadWebSite("http://0.0.0.0")
            networkStatusLabel.text = "Cellular"
            
        }
    }
    
    func updateSiteWhenNotReachable(reachability: Reachability) {
        loadWebSite("")
        networkStatusLabel.text = "Not connected"
    }
    
    func loadWebSite (str:String!) {
        let url = NSURL(string:str)
        let request = NSURLRequest(URL:url!)
        
        webView.loadRequest(request)
    }
    
    func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            loadWebSite("")
            return
        }
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    
    deinit {
        stopNotifier()
    }
}

