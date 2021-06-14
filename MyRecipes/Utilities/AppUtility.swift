//
//  AppUtility.swift
//  MyRecipes
//
//  Created by Dzul on 12/06/2021.
//

import UIKit

class AppUtility: NSObject {
    
    // MARK: - Project Info
    class func appNameAndBuildNumber() -> String {
        guard let strBuildNumber = Bundle.buildVersionNumber else { return "iceService IOS 1.0.0" }
        return strBuildNumber
    }
    
    class func appName() -> String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
    
    class func getCoreDataDBPath() {
        let path = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .last?
            .absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .removingPercentEncoding

        print("Core Data DB Path :: \(path ?? "Not found")")
    }
    
    // MARK: - Storybords
    class func getUserStoryboardInstance() -> UIStoryboard
    {
        let userStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return userStoryboard
    }
    
    class func getCustomPickerInstance() -> CustomPicker
    {
        let storyboard = AppUtility.getUserStoryboardInstance()
        let customPickerObj = (storyboard.instantiateViewController(withIdentifier: "CustomPickerID")) as! CustomPicker
        return customPickerObj
    }
    
    // MARK: - Conversion
    class func convertStringToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print("Error when convert string to dict: ", error.localizedDescription)
            }
        }
        return [:]
    }
    
    class func convertUrlQueryToDictionary(urlQuery: String) -> [String : Any]? {
        let arrUrlQueryParams = urlQuery.components(separatedBy:"&")
        var dictUrlQueryParams = [String:Any]()
        for row in arrUrlQueryParams {
            let pairs = row.components(separatedBy:"=")
            dictUrlQueryParams[pairs[0]] = pairs[1]
        }
        return dictUrlQueryParams
    }
    
    static func stringToBytes(_ string: String) -> [UInt8]? {
        let length = string.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for _ in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
    
    class func base64ToImage(base64String: String?, placeholder: String) -> UIImage{
        
        if let imgBase64Str = base64String, imgBase64Str != "" {
            let dataDecoded : Data = Data(base64Encoded: imgBase64Str, options: [])!
            let decodedimage = UIImage(data: dataDecoded)
            return decodedimage ?? UIImage.init(named: placeholder)!
        } else {
            return UIImage.init(named: placeholder)!
        }
    }
    
    class func imageToBase64(image: UIImage) -> String? {
        guard let imageData = image.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    // MARK: - Filter
    class func filterSpace(removeSpace : String) -> String{
        let trimmedString = removeSpace.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedString
    }
    
    // MARK: - Date
    class func changeTimeWithCorrectFormat(inputDatetime: String) -> String {
        if inputDatetime != "" {
            let arrSplitDateTime = inputDatetime.components(separatedBy: "T")
            if arrSplitDateTime.count >= 2 {
                let arrTimeZ = arrSplitDateTime[1].components(separatedBy: ".")
                if arrTimeZ.count >= 1 {
                    return arrTimeZ[0]
                }
            }
        }
        return ""
    }
    
    class func changeGivenDateAsString(inputDate : Date, OutputFormat: String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = OutputFormat
        return dateformatter.string(from: inputDate)
    }
    
    class func changeGivenStringDateAsDate(inputDateString : String, OutputFormat: String) -> Date {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = OutputFormat
        return dateformatter.date(from: inputDateString)!
    }
    
    class func getDayOfWeekForGivenDate(strInputDate: String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/yyyy"
        
        let inputDate = dateformatter.date(from: strInputDate)
        dateformatter.dateFormat = "EEEE"
        
        return dateformatter.string(from: inputDate!)
    }
    
    class func convertTimestampToReadableDateString(timestamp: Double) -> String {
        let issueDate = Date(timeIntervalSince1970: TimeInterval(timestamp/1000.0))// 1573387464000.0
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 60 * 60 * 8)
        dateFormatter.dateFormat = "EE, dd MMM yyyy HH:mm:ss"
        let strDate = dateFormatter.string(from: issueDate)
        
        return strDate
    }
    
    class func intervalBetweenTwoDates(startDate: String, endDate: String, format: String) -> String {
        let timeformatter = DateFormatter()
        timeformatter.dateFormat = format
        
        let time1 = timeformatter.date(from: startDate)
        let time2 = timeformatter.date(from: endDate)
        
        //You can directly use from here if you have two dates
        
        let interval = time2?.timeIntervalSince(time1!)
        let hour = interval! / 3600;
        let minute = interval!.truncatingRemainder(dividingBy: 3600) / 60
        let intervalInt = Int(interval!)
        
        let finalString = "\(intervalInt < 0 ? "-" : "+") \(Int(hour)) Hours \(Int(minute)) Minutes"
        print("\(intervalInt < 0 ? "-" : "+") \(Int(hour)) Hours \(Int(minute)) Minutes")
        
        return finalString
    }
    
    class func convertTimeTo24HourFormat(strInputDate : String, inputFormat : String) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat    = inputFormat // "hh:mm a"
        
        let inputDate : Date = timeFormatter.date(from: strInputDate)!
        timeFormatter.dateFormat = "HHmm"
        
        return timeFormatter.string(from: inputDate)
    }
    
    class func calculateTimeDifference(start: Int, end: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        var startString = "\(start)"
        if startString.count < 4 {
            for _ in 0..<(4 - startString.count) {
                startString = "0" + startString
            }
        }
        var endString = "\(end)"
        if endString.count < 4 {
            for _ in 0..<(4 - endString.count) {
                endString = "0" + endString
            }
        }
        let startDate = formatter.date(from: startString)!
        let endDate = formatter.date(from: endString)!
        let difference = endDate.timeIntervalSince(startDate)
        return "\(Int(difference) / 3600) Hr \(Int(difference) % 3600 / 60) Min"
    }
    
    class func diffTimeBtwTwoDates(fromDate: String, toDate: String, fromDateFormat: String, toDateFormat: String) -> (diffDay : Int, diffHour : Int, strDiff : String) {
        
        let secondsInAnHour : Double = 3600 // 60*60
        let secondsInDays   : Double = 86400 // 60*60*24
        
        let dateString1 = fromDate
        let dateString2 = toDate
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = fromDateFormat
        let date1 = dateformatter.date(from: dateString1)
        dateformatter.dateFormat = toDateFormat
        let date2 = dateformatter.date(from: dateString2)
        
        let distanceBetweenDates: TimeInterval? = date2?.timeIntervalSince(date1!)
        let hoursBetweenDates   = Int((distanceBetweenDates! / secondsInAnHour))
        let daysBetweenDates    = Int((distanceBetweenDates! / secondsInDays))
        
        let components              = Set<Calendar.Component>([.minute, .hour, .day, .month, .year])
        let differenceOfDate        = Calendar.current.dateComponents(components, from: date1!, to: date2!)
        
        var strFinalDiffBtwDates    = ""
        if differenceOfDate.day! >= 1 {
            
            let hoursInTotalDays    = (24*differenceOfDate.day!) + differenceOfDate.hour!
            strFinalDiffBtwDates    = "\(String(describing: hoursInTotalDays))h \(String(describing: differenceOfDate.minute!))m"
        } else {
            strFinalDiffBtwDates    = "\(String(describing: differenceOfDate.hour!))h \(String(describing: differenceOfDate.minute!))m"
        }
        
        return (daysBetweenDates, hoursBetweenDates, strFinalDiffBtwDates)
    }
    
    
    class func getPastDateFromToday(inputDate: Date, format: String, diff: Int) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        // Date From
        let secondDate = Calendar.current.date(byAdding: Calendar.Component.day, value: diff, to: inputDate)
        let fromDate    = dateFormatter.string(from: secondDate!)
        
        return fromDate
    }
    
    // MARK: - String
    class func splitGivenStringAsArray(strInput: String, separateBy: String) -> String {
        
        var locationNameOnly : String = strInput
        let arrSplitLocationDetails     = strInput.components(separatedBy: separateBy)
        if arrSplitLocationDetails.count >= 2 {
            // Split string
            locationNameOnly    = arrSplitLocationDetails[0]
        }
        
        return locationNameOnly
    }
    
    // MARK: - Alert Methods
    class func showSuccessFailureAlert(title : String, message: String, controller : UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertOKButton = UIAlertAction(title: IDENTIFIERS.OKAY, style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(alertOKButton)
        controller.present(alert, animated: true, completion: {
            print("Alert presented success-1");
        })
    }
    
    class func showSuccessFailureAlertWithDismissHandler(title : String, message: String, controller : UIViewController, alertDismissed:@escaping ((_ okPressed: Bool)->Void))
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertOKButton = UIAlertAction(title: IDENTIFIERS.OKAY, style: UIAlertAction.Style.default, handler: { action in
            print("Alert Dismissed")
            alertDismissed(true)
        })
        alert.addAction(alertOKButton)
        controller.present(alert, animated: true, completion: {
            print("Alert presented success-2");
        })
    }
    
    class func showAlertWithOptionsAndDismissHandler(title : String, message: String, postiveOption: String, negativeOption: String, controller : UIViewController, alertDismissedWithPos:@escaping ((_ posOptionPressed: Bool)->Void), alertDismissedWithNeg:@escaping ((_ negOptionPressed: Bool)->Void))
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        if negativeOption != "" {
            let alertNegative = UIAlertAction(title: negativeOption.capitalized, style: UIAlertAction.Style.default, handler: { action in
                print("Alert Dismissed with negative option")
                alertDismissedWithNeg(true)
            })
            alert.addAction(alertNegative)
        }
        
        let alertPostive = UIAlertAction(title: postiveOption.capitalized, style: UIAlertAction.Style.default, handler: { action in
            print("Alert Dismissed with postive option")
            alertDismissedWithPos(true)
        })
        alert.addAction(alertPostive)
        
        controller.present(alert, animated: true, completion: {
            print("Alert presented success-3");
        })
    }
    
    // MARK: - File
    enum FILE_FOLDER_NAMES : CaseIterable {
        case FOLDER1, FOLDER2
        public var description: String {
            switch self {
            case .FOLDER1: return "folder1"
            case .FOLDER2: return "folder2"
            }
        }
    }
    
    class func appDocumentDirectory() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }
    
    class func getDirectoryPath(withFolderName: String) -> URL {
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(withFolderName)
        let url = URL(string: path)
        return url!
    }
    
    class func checkPhotoExistsInDirectory(folderName: String, fileName: String) -> (isFileExist: Bool, urlString: String) {
        // read image from document directory
        let fileManager     = FileManager.default
        var imagePath       = AppUtility.getDirectoryPath(withFolderName: folderName)
        imagePath.appendPathComponent(fileName)
        let urlString       = imagePath.absoluteString
        
        return (fileManager.fileExists(atPath: urlString), urlString)
    }
    
    class func saveImageFileInDirectory(directoryName: FILE_FOLDER_NAMES, fileName: FILE_FOLDER_NAMES, capturedImage : UIImage, imgOutputQuality: CGFloat) -> (Bool) {
        let fileManager = FileManager.default
        let directoryPathURL = AppUtility.getDirectoryPath(withFolderName: directoryName.description)
        if !fileManager.fileExists(atPath: directoryPathURL.absoluteString) {
            do {
                try fileManager.createDirectory(atPath: directoryPathURL.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("ERROR WHEN WRITE FILE: ", error.localizedDescription)
                return false
            }
        }
        
        let url = URL(string: directoryPathURL.absoluteString)
        let imagePath = url!.appendingPathComponent(fileName.description)
        let urlString: String = imagePath.absoluteString
        let imageData = capturedImage.jpegData(compressionQuality: imgOutputQuality)
        return fileManager.createFile(atPath: urlString as String, contents: imageData, attributes: nil)
    }
    
    class func deleteImageFileInDirectory(directoryName: FILE_FOLDER_NAMES, fileName: FILE_FOLDER_NAMES) {
        let checkFileStatus = AppUtility.checkPhotoExistsInDirectory(folderName: directoryName.description, fileName: fileName.description)
        if checkFileStatus.isFileExist {
            let fileManager     = FileManager.default
            do {
                try fileManager.removeItem(atPath: checkFileStatus.urlString)
            }
            catch let error {
                print("ERROR WHEN WRITE FILE: ", error.localizedDescription)
            }
        }
    }
}
