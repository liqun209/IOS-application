
import UIKit
import MapKit
class MapViewController: UIViewController {


    @IBOutlet var mapView: MKMapView!
    var infoActuel: (CLLocationCoordinate2D, String)!
    var infoAll = [(CLLocationCoordinate2D, String)]()
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let infoActuel = infoActuel{
            let annotation = MKPointAnnotation()
            annotation.coordinate = infoActuel.0
            annotation.title = infoActuel.1
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
            self.title = infoActuel.1
        }
        
        if infoAll.count != 0{
            for info in infoAll{
                let annotation = MKPointAnnotation()
                annotation.coordinate = info.0
                annotation.title = info.1
                annotations.append(annotation)
            }
            
            self.mapView.showAnnotations(annotations, animated: true)
        }
        
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
