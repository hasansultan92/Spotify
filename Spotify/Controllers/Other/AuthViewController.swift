//
//  AuthViewController.swift
//  Spotify
//
//  Created by Hasan Sultan on 9/6/23.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private var webView: WKWebView?
    private var url: URL {
        guard let url = AuthManager.shared.signInURL else {return URL(string: "https://www.google.com")! }
        return url
    }
    
    public var completionHandler :((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
    }
    
    override func loadView() {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        view = webView
        if let url = AuthManager.shared.signInURL {
            print(url)
            webView.load(URLRequest(url: url))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let url = webView.url else {return}
        // Exchange code for access token
        
        let component = URLComponents(string: url.absoluteString)
        guard let code = component?.queryItems?.first(where: {$0.name=="code"})?.value else{return}
        webView.isHidden = true
        print("Code: \(code)") // Exchange code for access token
        AuthManager.shared.exchangeCodeForToken(code: code){
            [weak self] success in
            DispatchQueue.main.async {
                self?.completionHandler?(success)
                self?.navigationController?.popToRootViewController(animated: true)
            }
    
        }
    }

}
