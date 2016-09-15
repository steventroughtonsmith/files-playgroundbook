/*
File Browser for Swift Playgrounds
*/

import UIKit
import QuickLook
import PlaygroundSupport

class FBFilesTableViewController : UITableViewController, QLPreviewControllerDataSource
{
	var files = Array<String>()
	var path = "/"
	
	required init(path: String)
	{
		super.init(style: .plain)
		self.title = (path as NSString).lastPathComponent
		
		do
		{
			self.files = try FileManager.default.contentsOfDirectory(atPath: path)
		}
		catch _
		{
			if path == "/System"
			{
				self.files = ["Library"]
			}
		}
		
		let label = NSString(format: "%lu items", self.files.count)
		let itemCountBarItem = UIBarButtonItem(title: label as String, style: .plain, target: nil, action: nil)
		let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		
		self.setToolbarItems([flexibleSpace, itemCountBarItem, flexibleSpace], animated: false)
		
		self.path = path
		self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 72
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return files.count
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let files = self.files
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		var newPath : NSString = (self.path as NSString).appendingPathComponent(files[indexPath.row]) as NSString
		
		cell.textLabel?.text = newPath.lastPathComponent
		cell.imageView?.tintColor = UIColor(colorLiteralRed: 0.565, green: 0.773, blue: 0.961, alpha: 1.0)
		
		var isDirectory = ObjCBool(false)
		FileManager.default.fileExists(atPath:newPath as String, isDirectory: &isDirectory)
		
		if isDirectory.boolValue
		{
			cell.imageView?.image = UIImage(named: "Folder")
		}
		else if (newPath as NSString).pathExtension == "png"
		{
			cell.imageView?.image = UIImage(named: "Picture")
		}
		else
		{
			cell.imageView?.image = UIImage(named: "Document")
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let files = self.files
		var newPath = self.path as NSString
		newPath = newPath.appendingPathComponent(files[indexPath.row]) as NSString
		
		var isDirectory = ObjCBool(false)
		FileManager.default.fileExists(atPath:newPath as String, isDirectory: &isDirectory)
		
		if isDirectory.boolValue
		{
			let tableVC = FBFilesTableViewController(path:newPath as String)
			self.navigationController?.pushViewController(tableVC, animated: true)
		}
		else
		{
			let previewVC = QLPreviewController()
			previewVC.dataSource = self
			self.navigationController?.pushViewController(previewVC, animated: true)
		}
	}
	
	func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
		return 1
	}
	
	func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
		let files = self.files
		var newPath = self.path as NSString
		newPath = newPath.appendingPathComponent(files[self.tableView.indexPathForSelectedRow!.row]) as NSString
		
		return URL(fileURLWithPath: newPath as String) as QLPreviewItem
	}
}

let tableVC = FBFilesTableViewController(path:"/")

let navVC = UINavigationController(rootViewController: tableVC)
navVC.isToolbarHidden = false

let window = UIWindow()
window.rootViewController = navVC
window.makeKeyAndVisible()

window.autoresizingMask = [.flexibleHeight,.flexibleWidth]
PlaygroundPage.current.liveView = window
