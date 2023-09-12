import UIKit
import WebKit

class WatchListWebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidAppear(_ animated: Bool) {
        let addURL = UserDefaults.standard.object(forKey: "id") as? String
        
        let link = "https://finance.yahoo.com/quote/" + addURL! + ".HK/"
        //https://finance.yahoo.com/quote/0001.HK/
        
        let mURL = URL(string:link)!
        let request = URLRequest(url: mURL)
        webView.load(request)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
