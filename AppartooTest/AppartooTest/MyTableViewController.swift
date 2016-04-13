
import UIKit
import CoreLocation

class MyTableViewController: UITableViewController {

    var bars = [Bar]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension
        self.title = "Bars"
        bars = parseJsonFile()
        
        if let map = self.navigationController?.parentViewController!.childViewControllers.last as? MapViewController{
            for bar in bars{
                let coordinate = CLLocationCoordinate2D(latitude: bar.latitude, longitude: bar.longitude)
                map.infoAll.append((coordinate, bar.name))
            }
        }
        
        
    }

    func parseJsonFile() -> [Bar]
    {
        var bars = [Bar]()
        
        if let path = NSBundle.mainBundle().pathForResource("Pensebete", ofType: "json")
        {
            if let data = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)
            {
                if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
                {
                    if let jsonBars = jsonResult["bars"] as? [AnyObject]
                    {
                        for jsonBar in jsonBars
                        {
                            let bar = Bar()
                            
                            bar.name = jsonBar["name"] as? String ?? ""
                            bar.longitude = jsonBar["longitude"] as? Double ?? 0
                            bar.latitude = jsonBar["latitude"] as? Double ?? 0
                            bar.address = jsonBar["address"] as? String ?? ""
                            bar.imageUrl = jsonBar["image_url"] as? String ?? ""
                            bars.append(bar)
                        }
                    }
                }
            }
        }
      
        return bars
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bars.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MyTableViewCell

        
        let bar = bars[indexPath.row]
        cell.name.text = "NAME:  \(bar.name)"
        cell.gps.text = "GPS:  \(bar.latitude), \(bar.longitude)"
        cell.adress.text = "ADRESS:  \(bar.address)"
        if bar.imageUrl != ""{
            if let url = NSURL(string: bar.imageUrl){
                if let imageData = NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil){
                    cell.photo.image = UIImage(data: imageData)
                }
            }
            
        }
        
        return cell
    }



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMap" {
            if let row = tableView.indexPathForSelectedRow()?.row {
                let bar = bars[row]
                let map = segue.destinationViewController as! MapViewController
                let coordinate = CLLocationCoordinate2D(latitude: bar.latitude, longitude: bar.longitude)
                map.infoActuel = (coordinate, bar.name)
            }
        }
    }


}
