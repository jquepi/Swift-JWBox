//
//  WebViewController.swift
//  JW Box
//
//  Created by David Díaz on 16/8/17.
//  Copyright © 2017 David Díaz. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var address: String! = ""
    var isJWLoaded: Bool! = false
    var isBlankLoaded: Bool! = false
    var isInboxLoaded: Bool! = false
    
    @IBOutlet weak var webBrowser: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Se asigna el delegado del navegador al ViewController.
        webBrowser.delegate = self
        
        // Carga la URL que se le pasa desde UITableViewController.
        fLoadURL()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Evento al pulsar el botón BACK.
    override func viewWillDisappear(_ animated: Bool) {
        if self.navigationController?.viewControllers .index(of: self) == nil {
            // Se cierra la sesión en jw.org.
            Alamofire.request("https://apps.jw.org/S_LOGOUT").responseString
        }
    }
    
    // Carga la URL que se le pasa desde UITableViewController.
    func fLoadURL() {
        webBrowser.isHidden = true
        webBrowser.loadRequest(URLRequest(url: URL(string: address!)!))
    }
    
    // Función sobreescrita del delegado UIWebViewDelegate.
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        if !isJWLoaded! {
            isJWLoaded = true
            webBrowser.stopLoading()
            address = "about:blank"
            webBrowser.loadRequest(URLRequest(url: URL(string: address!)!))
        } else if !isBlankLoaded! {
            isBlankLoaded = true
            webBrowser.stopLoading()
            address = "https://apps.jw.org/INBOX"
            webBrowser.loadRequest(URLRequest(url: URL(string: address!)!))
        } else if !isInboxLoaded! {
            isInboxLoaded = true
            webBrowser.isHidden = false
        }
    }
}
