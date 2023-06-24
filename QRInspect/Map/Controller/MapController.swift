//
//  MapController.swift
//  hackathon
//
//
import UIKit
import MapKit
import CoreLocation
import PromiseKit
import Toast_Swift

final class MapController: UIViewController {

    @IBOutlet weak private var mapView: MKMapView!
    @IBOutlet weak private var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var bottomView: UIView!

    @IBOutlet weak private var plotLabel: UILabel!
    @IBOutlet weak private var temperatureLabel: UILabel!
    @IBOutlet weak private var humidityLabel: UILabel!
    @IBOutlet weak private var stageLabel: UILabel!

    private var isNeedPurple: Bool = false
    private var location = CLLocationManager()
    private var locationModel = MapRequests()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        getLocations()
    }

    //MARK: setupUI
    private func setupUI() {
        makeShadowBehindMap()
        viewHeightConstraint.constant = 0
        mapView.delegate = self
        location.delegate = self

        setLocation(latitude: 44.539779, longitude: 38.083293, zoom: 700) //mark on tolstiy mis
        //setLocation(latitude: 44.635395, longitude: 38.000555, zoom: 3500)  //mark on vinogradniy

        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeBottomView)))
        bottomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showInfoAboutPlot)))
    }

    private func getLocations() {
        firstly(execute: {
            locationModel.getLocations()
        }).done({   data in
            dump(data)
        }).catch {  error in
            self.view.makeToast("\(error)")
        }
    }

    @objc private func showInfoAboutPlot() {
        self.performSegue(withIdentifier: "showInfoAboutPlot", sender: self)
        viewHeightConstraint.constant = 0
    }

    @objc private func closeBottomView() {
        UIView.animate(withDuration: 1) {
            self.viewHeightConstraint.constant = 0
        }
        self.view.layoutIfNeeded()
    }

    //MARK: showLocation
    private func setLocation(latitude: CGFloat, longitude: CGFloat, zoom: Double) {

            let viewRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters: zoom, longitudinalMeters: zoom)

            drawRectangles()

            mapView.setRegion(viewRegion, animated: false)
            mapView.showsUserLocation = true

            mapView.mapType = .satellite

            DispatchQueue.main.async { [self] in
                location.startUpdatingLocation()
            }
    }

    //MARK: draw rectangles on field
    private func drawRectangles() {
        let bluePolygonFirstPoint: Point = Point(coordinate: CLLocationCoordinate2D(latitude: 44.540892, longitude: 38.081614))
        let bluePolygonSecondPoint: Point = Point(coordinate: CLLocationCoordinate2D(latitude: 44.541668, longitude: 38.082625))
        let bluePolygonThirdPoint: Point = Point(coordinate: CLLocationCoordinate2D(latitude: 44.540530, longitude: 38.084292))
        let bluePolygonFourthPoint: Point = Point(coordinate: CLLocationCoordinate2D(latitude: 44.539784, longitude: 38.083303))
        let bluePolygonArray = [bluePolygonFirstPoint, bluePolygonSecondPoint, bluePolygonThirdPoint, bluePolygonFourthPoint, bluePolygonFirstPoint]

        var locationsBluePolygon = bluePolygonArray.map { $0.coordinate }
        let bluePolygon = MKPolygon(coordinates: &locationsBluePolygon, count: locationsBluePolygon.count)
        self.mapView.addOverlay(bluePolygon)

        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 44.540736, longitude: 38.082993)
        annotation.title = "Анализ почвы"
        annotation.subtitle = "Дополнительная информация"
        mapView.addAnnotation(annotation)

        let purplePolygonFirstPoint: Point = Point(coordinate: CLLocationCoordinate2D(latitude: 44.539032, longitude: 38.082379))
        let purplePolygonSecondPoint: Point = Point(coordinate: CLLocationCoordinate2D(latitude: 44.539709, longitude: 38.083306))
        let purplePolygonThirdoint: Point = Point(coordinate: CLLocationCoordinate2D(latitude: 44.538869, longitude: 38.084546))
        let purplePolygonFourthPoint: Point = Point(coordinate: CLLocationCoordinate2D(latitude: 44.538168, longitude: 38.083671))
        let purplePolygonArray = [purplePolygonFirstPoint, purplePolygonSecondPoint, purplePolygonThirdoint, purplePolygonFourthPoint, purplePolygonFirstPoint]

        var locationsPurplePolygon = purplePolygonArray.map { $0.coordinate }
        let purplePolygon = MKPolygon(coordinates: &locationsPurplePolygon, count: locationsPurplePolygon.count)
        self.mapView.addOverlay(purplePolygon)

        let annotation2 = MKPointAnnotation()
        annotation2.coordinate = CLLocationCoordinate2D(latitude: 44.538948, longitude: 38.083397)
        annotation2.title = "Угроза заболевания лозы"
        annotation2.subtitle = "Дополнительная информация"
        mapView.addAnnotation(annotation2)
    }

    //MARK: create polyline
//    private func createPolyline(points: [Point]) {
//        var locations = points.map { $0.coordinate }
//        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
//        self.mapView.addOverlay(polyline)
//    }

    //MARK: show user location
    private func showUserLocation() {
        if let userLocation = location.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(viewRegion, animated: false)
            mapView.showsUserLocation = true
            mapView.mapType = .satellite

            DispatchQueue.main.async { [self] in
                location.startUpdatingLocation()
            }
        }
    }

    //MARK: make a search request
    private func makeSearchRequest(message: String) {

        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = message
        searchRequest.region = mapView.region
        searchRequest.resultTypes = [.pointOfInterest, .address]

        let search = MKLocalSearch(request: searchRequest)

        search.start { [self] response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "No error specified").")
                return
            }
            // Create annotation for every map item
            for mapItem in response.mapItems {

                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate

                annotation.title = mapItem.name
                annotation.subtitle = mapItem.phoneNumber

                mapView.addAnnotation(annotation)
            }
            mapView.setRegion(response.boundingRegion, animated: true)
        }
    }

    //MARK: make shadow around map
    private func makeShadowBehindMap() {
        let radius: CGFloat = mapView.frame.width / 2 //change it to .height if you need spread for height
        let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 2.1 * radius, height: mapView.frame.height))

        mapView.layer.cornerRadius = 2
        mapView.layer.shadowColor = UIColor.black.cgColor
        mapView.layer.shadowOffset = CGSize(width: 0.1, height: 0.1)  //Here you control x and y
        mapView.layer.shadowOpacity = 0.3
        mapView.layer.shadowRadius = 7.0    // blur
        mapView.layer.masksToBounds =  false
        mapView.layer.shadowPath = shadowPath.cgPath
    }

}

//MARK: - CLLocationManagerDelegate
extension MapController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if CLLocationManager.locationServicesEnabled() {
                location.requestWhenInUseAuthorization()
                location.requestAlwaysAuthorization()


                location.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            }
        }
    }
}

//MARK: - MKMapViewDelegate
extension MapController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        if annotation.title == "Анализ почвы" {
            annotationView?.image = UIImage(named: "blueDot")
            isNeedPurple.toggle()
        } else {
            annotationView?.image = UIImage(named: "purpleDot")
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer

        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(named: "blueDotMap")
            renderer.lineWidth = 2
            return renderer

        } else if overlay is MKPolygon {
            if !isNeedPurple {
                let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
                renderer.fillColor = UIColor.blue.withAlphaComponent(0.3)
                renderer.strokeColor = UIColor(named: "blueDotMap")
                renderer.lineWidth = 2
                isNeedPurple.toggle()
                return renderer
            } else {
                let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
                renderer.fillColor = UIColor.purple.withAlphaComponent(0.3)
                renderer.strokeColor = UIColor(named: "purpleDotMap")
                renderer.lineWidth = 2
                isNeedPurple.toggle()
                return renderer
            }
        }

        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let myView = view.annotation {

            plotLabel.text = "мыс Виноградный участок №3"
            temperatureLabel.text = "31℃"
            humidityLabel.text = "44%"
            stageLabel.text = "цветение"

            UIView.animate(withDuration: 1, animations: {
                self.viewHeightConstraint.constant = 210
            })

            self.view.layoutIfNeeded()

            //mapView.deselectAnnotation(view.annotation, animated: true)
        }
    }
}
