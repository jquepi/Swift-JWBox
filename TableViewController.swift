//
//  ViewController.swift
//  JW Box
//
//  Created by David Díaz on 23/8/17.
//  Copyright © 2017 David Díaz. All rights reserved.
//

import UIKit
import Foundation
import Kanna
import Alamofire

class TableViewController: UITableViewController {
    
    //////////////////////////////////////
    // Declaración de variables globales /
    //////////////////////////////////////
    var isToggleOn: Bool! = false
    let appSettings: UserDefaults = UserDefaults.standard
    let jwUser: String = "jwUserKey"
    let jwPass: String = "jwPassKey"
    
    //////////////////////////////////////
    // Declaración de componentes        /
    //////////////////////////////////////
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnSaveClear: UIButton!
    @IBOutlet weak var lblInbox: UILabel!
    @IBOutlet weak var tvcInbox: UITableViewCell!
    @IBOutlet weak var imgInbox: UIImageView!
    @IBOutlet weak var tvTableView: UITableView!
    
    //////////////////////////////////////
    // Declaración de eventos            /
    //////////////////////////////////////
    
    // Evento del botón SAVE/CLEAR.
    @IBAction func eToggleSaveClear() {
        // True  = Clear activado. False = Save activado.
        if isToggleOn == true { // Evento CLEAR. Se cambia a SAVE.
            isToggleOn = false
            txtUsername.isEnabled = true
            txtPassword.isEnabled = true
            txtUsername.text = ""
            txtPassword.text = ""
            btnSaveClear.setTitle("SAVE", for: .normal)
            btnSaveClear.setTitleColor(nil, for: .normal)
            imgInbox.alpha = 0.5
            lblInbox.isEnabled = false
            tvcInbox.isUserInteractionEnabled = false
            tvTableView.footerView(forSection: 0)?.textLabel?.text = "Please, set up you your credentials"
            tvTableView.footerView(forSection: 0)?.textLabel?.textColor = UIColor.red
            tvTableView.footerView(forSection: 0)?.textLabel?.setNeedsDisplay()
            lblInbox.text = "Inbox"
            appSettings.setValue(txtUsername.text!, forKey: jwUser)
            appSettings.setValue(txtPassword.text!, forKey: jwPass)
            appSettings.synchronize()
            fCheckUserPass()
        } else { // Evento SAVE. Se cambia a CLEAR.
            isToggleOn = true
            txtUsername.isEnabled = false
            txtPassword.isEnabled = false
            btnSaveClear.setTitle("CLEAR", for: .normal)
            btnSaveClear.setTitleColor(.red, for: .normal)
            tvTableView.footerView(forSection: 0)?.textLabel?.text = "Checking Inbox..."
            tvTableView.footerView(forSection: 0)?.textLabel?.textColor = nil
            tvTableView.footerView(forSection: 0)?.textLabel?.setNeedsDisplay()
            lblInbox.text = "Inbox"
            appSettings.setValue(txtUsername.text!, forKey: jwUser)
            appSettings.setValue(txtPassword.text!, forKey: jwPass)
            appSettings.synchronize()
            fCheckUserPass()
            fAccessJW()
        }
    }
    
    // Evento al cambiar el Username.
    @IBAction func eChangeUsername() {
        fCheckUserPass()
    }
    
    // Evento al cambiar el Password.
    @IBAction func eChangePassword() {
        fCheckUserPass()
    }
    
    // Evento al comenzar la edición del Username (entrar en el campo).
    @IBAction func eUsernameBeginEditing() {
        txtUsername.placeholder = nil
    }
    
    // Evento al finalizar la edición del Username (salir del campo).
    @IBAction func eUsernameEndEditing() {
        txtUsername.placeholder = "Username"
    }
    
    // Evento al comenzar la edición del Password (entrar en el campo).
    @IBAction func ePasswordBeginEditing() {
        txtPassword.placeholder = nil
    }
    
    // Evento al finalizar la edición del Password (salir del campo).
    @IBAction func ePasswordEndEditing() {
        txtPassword.placeholder = "Password"
    }
    
    //////////////////////////////////////
    // Funciones                         /
    //////////////////////////////////////
    
    // Carga inicial.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Se inicializan todos los componentes.
        fInitComponents()
    }
    
    // Alerta de memoria.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Se inicializan los componentes.
    func fInitComponents() {
        // Se cargan las credenciales guardadas.
        let username = String(describing: appSettings.value(forKey: jwUser)!)
        let password = String(describing: appSettings.value(forKey: jwPass)!)
        
        if ((username.characters.count != 0) && (password.characters.count != 0)) { // Hay valores guardados.
            txtUsername.text! = username
            txtPassword.text! = password
            isToggleOn = false
            eToggleSaveClear()
            fAccessJW()
        } else { // No hay valores guardados.
            isToggleOn = true
            eToggleSaveClear()
        }
        
        //Se setean los constrains del footer de la primera sección de botones.
        tvTableView.footerView(forSection: 0)?.textLabel?.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        tvTableView.footerView(forSection: 0)?.textLabel?.widthAnchor.constraint(equalTo: view.widthAnchor)
    }
    
    // Si el usuario y la contraseña tienen texto habilita el botón SAVE.
    func fCheckUserPass() {
        if (txtUsername.text!.characters.count != 0) && (txtPassword.text!.characters.count != 0) {
            btnSaveClear.isEnabled = true
        } else {
            btnSaveClear.isEnabled = false
        }
    }
    
    // Sobreescribe la función para el "segue" o transición al WebViewController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let WebViewController = segue.destination as? WebViewController {
            var urlJW: String? = "https://apps.jw.org/E_LOGIN2?txtUserName=" + String(describing: appSettings.value(forKey: jwUser)!) + "&txtPassword=" + String(describing: appSettings.value(forKey: jwPass)!)
            urlJW = urlJW?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            WebViewController.address = urlJW
        }
    }
    
    // Accede a jw.org vía POST.
    func fAccessJW() -> Void {
        var html: String? = ""
        var urlJW: String? = "https://apps.jw.org/E_LOGIN2?txtUserName=" + String(describing: appSettings.value(forKey: jwUser)!) + "&txtPassword=" + String(describing: appSettings.value(forKey: jwPass)!)
        urlJW = urlJW?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        // Intenta acceder con las credenciales.
        Alamofire.request(urlJW!).responseString { response in
            if response.result.isSuccess {
                // Intenta acceder a la bandeja de entrada.
                Alamofire.request("https://apps.jw.org/INBOX").responseString { response in
                    html = response.result.value
                    if html != "" {
                        self.getMessages(html: html!)
                    } else { // Si no hay contenido, jw.org está caída.
                        self.imgInbox.alpha = 0.5
                        self.lblInbox.isEnabled = false
                        self.tvcInbox.isUserInteractionEnabled = false
                        self.tvTableView.footerView(forSection: 0)?.textLabel?.text = "jw.org is unreachable"
                        self.tvTableView.footerView(forSection: 0)?.textLabel?.textColor = UIColor.red
                        self.tvTableView.footerView(forSection: 0)?.textLabel?.setNeedsDisplay()
                        self.lblInbox.text = "Inbox"
                    }
                }
            } else { // Si no hay respuesta, no hay conexión a Internet.
                self.imgInbox.alpha = 0.5
                self.lblInbox.isEnabled = false
                self.tvcInbox.isUserInteractionEnabled = false
                self.tvTableView.footerView(forSection: 0)?.textLabel?.text = "No Internet connection"
                self.tvTableView.footerView(forSection: 0)?.textLabel?.textColor = UIColor.red
                self.tvTableView.footerView(forSection: 0)?.textLabel?.setNeedsDisplay()
                self.lblInbox.text = "Inbox"
            }
        }
        
        // En cualquier caso, hace el LOGOUT de la página.
        Alamofire.request("https://apps.jw.org/S_LOGOUT").responseString
    }
    
    // Obtiene la cantidad de mensajes no leídos y totales de la bandeja de entrada.
    func getMessages(html: String) -> Void {
        var newMessagesString: String = ""
        var totalMessagesString: String = ""
        
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            if doc.innerHTML!.range(of: "selecteditem") != nil {
                newMessagesString = doc.css("li[class^='selecteditem']")[0].text ?? ""
                totalMessagesString = doc.css("div[class^='total-pages']")[0].text ?? ""
                
                // Si se obtiene contenido de las etiquetas...
                if newMessagesString != "" && totalMessagesString != "" {
                    newMessagesString = newMessagesString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    newMessagesString = newMessagesString.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
                    totalMessagesString = totalMessagesString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    totalMessagesString = totalMessagesString.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
                    
                    imgInbox.alpha = 1
                    lblInbox.isEnabled = true
                    tvcInbox.isUserInteractionEnabled = true
                    tvTableView.footerView(forSection: 0)?.textLabel?.text = ""
                    tvTableView.footerView(forSection: 0)?.textLabel?.textColor = nil
                    self.tvTableView.footerView(forSection: 0)?.textLabel?.setNeedsDisplay()
                    lblInbox.text = newMessagesString + " unread messages (" + totalMessagesString + " total)"
                } else { // Si las etiquetas no tienen contenido, las credenciales son incorrectas.
                    imgInbox.alpha = 0.5
                    lblInbox.isEnabled = false
                    tvcInbox.isUserInteractionEnabled = false
                    tvTableView.footerView(forSection: 0)?.textLabel?.text = "Wrong credentials or too many attempts"
                    tvTableView.footerView(forSection: 0)?.textLabel?.textColor = UIColor.red
                    self.tvTableView.footerView(forSection: 0)?.textLabel?.setNeedsDisplay()
                    lblInbox.text = "Inbox"
                }
            } else { // Si no existe la etiqueta "selecteditem", las credenciales son incorrectas.
                imgInbox.alpha = 0.5
                lblInbox.isEnabled = false
                tvcInbox.isUserInteractionEnabled = false
                tvTableView.footerView(forSection: 0)?.textLabel?.text = "Wrong credentials or too many attempts"
                tvTableView.footerView(forSection: 0)?.textLabel?.textColor = UIColor.red
                self.tvTableView.footerView(forSection: 0)?.textLabel?.setNeedsDisplay()
                lblInbox.text = "Inbox"
            }
        } else { // Si no hay contenido, jw.org está caída.
            imgInbox.alpha = 0.5
            lblInbox.isEnabled = false
            tvcInbox.isUserInteractionEnabled = false
            tvTableView.footerView(forSection: 0)?.textLabel?.text = "jw.org is unreachable"
            tvTableView.footerView(forSection: 0)?.textLabel?.textColor = UIColor.red
            self.tvTableView.footerView(forSection: 0)?.textLabel?.setNeedsDisplay()
            lblInbox.text = "Inbox"
        }
    }
    
}
