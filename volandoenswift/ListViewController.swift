//
//  ListViewController.swift
//  volandoenswift
//
//  Created by Juan Manuel Moreno on 7/9/16.
//  Copyright © 2016 uzupis. All rights reserved.
//

import UIKit
import Reachability
import SDWebImage
import DownPicker

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    // Propiedades view
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var txtOrder: UITextField!
    
    // Propiedades controller
    var piatti: NSMutableArray! // Restaurantes json. TODO: Cambiar por nombre mas significativo
    var filter: NSDictionary! // Filtro que asocia nombres de picker con keys json
    var downPicker: DownPicker! // Picker opciones ordenar
    var handy: String! // Filtro para ordenar
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Agregamos valores por protocolos
        self.tblList.delegate = self;
        self.tblList.dataSource = self;
        
        self.piatti = NSMutableArray() // Nuevo contenedor restaurantes
        
        filter = ["Categoria": "categorias", "Precio": "domicilio", "Nombre": "nombre", "Tiempo Trayecto": "tiempo_domicilio"]; // Nuevo filtro. key = opcion picker, value = atributo json
        
        let jsonUrl:NSURL = NSURL(string: "https://api.myjson.com/bins/1zib8")! // URL json

        // Evaluamos conectividad con framework cocoapods Reachability
        var networkReachability: Reachability = Reachability.reachabilityForInternetConnection()
        if !networkReachability.isReachable() {
            
            print("No internet connection")
        } else {
            
            var request: NSURLRequest = NSURLRequest.init(URL: jsonUrl)
            var response: NSURLResponse?
            var error: NSError?
            do {
                
                // Recibimos json
                let urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
                var result: NSMutableArray = try NSJSONSerialization.JSONObjectWithData(urlData, options:NSJSONReadingOptions.MutableContainers) as! NSMutableArray
                piatti = result.mutableCopy() as! NSMutableArray // Agregamos a contenedor restaurantes

                // Agregamos contenido a picler
                var combo: NSMutableArray = NSMutableArray()
                combo.addObject("Categoria")
                combo.addObject("Precio")
                combo.addObject("Nombre")
                combo.addObject("Tiempo Trayecto")
                downPicker = DownPicker.init(textField: txtOrder, withData: combo as [AnyObject])
                downPicker.addTarget(self, action: #selector(order), forControlEvents: UIControlEvents.ValueChanged) // Accion al escoger una opcion del picker
                txtOrder.text = "Ordenar por ..."

                // Mostramos imagen de cabecera con framework cocoapods SDWebIamge para traer imagenes de Internet
                let urlImage = NSURL(string: "https://s-media-cache-ak0.pinimg.com/564x/27/70/ec/2770ec756dca44267b7f378dcbc55362.jpg")
                self.imgCover.sd_setImageWithURL(urlImage)
                
            } catch (let e) {
                
                print(e)
            }
        }
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

    /*func numberOfSectionsInTableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return piatti.count
    }*/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return piatti.count // No. de restaurantes
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Place") as? PlaceViewCell!

        // Nombre restaurante
        var place: NSDictionary = (piatti.objectAtIndex(indexPath.row) as? NSDictionary)!
        cell!.txtNombre.text = place.objectForKey("nombre") as? String
        
        // Descripcion
        var categoria: String = (place.objectForKey("categorias") as? String)!
        var precio: String = (place.objectForKey("domicilio") as? String)!
        var minutos: String = (place.objectForKey("tiempo_domicilio") as? String)!
        cell!.txtDesc.text = "Categoria " + categoria + " a un precio de $" + precio + " llega en " + minutos + " minutos"
        
        // Imagen TODO: No esta trayendo las imagenes del json. Aplicamos placeholder
        var image = (place.objectForKey("domicilio")) as? String
        let urlImage = NSURL(string: image!)
        cell?.imgPlace.sd_setImageWithURL(urlImage, placeholderImage: UIImage(named: "logo01"))
        
        return cell!
    }
    
    /*
     
        Reordena los elementos de la tabla
     */
    func order() {
        
        var key = txtOrder.text // Opcion picker
         handy = filter.objectForKey(key!) as! String! // key json dada la opcion picker
        var sortedResult: NSMutableArray = piatti.sortedArrayUsingComparator { // Comparador
         (obj1, obj2) -> NSComparisonResult in
         
            let first = obj1 as? NSDictionary
            let valueFirst = first?.objectForKey(self.handy) as! String
            let second = obj2 as? NSDictionary
            let valueSecond = second?.objectForKey(self.handy) as! String
            
            if (self.handy == "domicilio" || self.handy == "tiempo_domicilio") { // Comparamos numericos
            
                if Double(valueFirst) < Double(valueSecond) {
                
                    return NSComparisonResult.OrderedAscending
                } else if Double(valueFirst) > Double(valueSecond) {
                    
                    return NSComparisonResult.OrderedDescending
                } else {
                    
                    return NSComparisonResult.OrderedSame
                }
            } else {
                
                return valueFirst.compare(valueSecond)
            }
         
        } as! NSMutableArray
        
        piatti = sortedResult.mutableCopy() as! NSMutableArray // Copiamos a contenedor restaurantes
        tblList.reloadData() // Recargamos tabla
    }
}
