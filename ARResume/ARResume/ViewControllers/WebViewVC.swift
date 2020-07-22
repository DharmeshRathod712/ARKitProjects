//
//  WebViewVC.swift
//  ARImageTrackingWithText
//
//  Created by Rathod on 7/20/20.
//  Copyright © 2020 Rathod. All rights reserved.
//

import UIKit
import WebKit

class WebViewVC: UIViewController, WKNavigationDelegate, Storyboarded {
    
    @IBOutlet weak var webView: WKWebView!
    
    var urlString: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        print("urlString: \(urlString)")
        
        if !urlString.isEmpty {
            let url = URL(string: urlString)!
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }
    }
}
