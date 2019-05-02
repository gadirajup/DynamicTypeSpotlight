//
//  ViewController.swift
//  DynamicTypeSpotlight
//
//  Created by Prudhvi Gadiraju on 5/1/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import UIKit
import SafariServices
import CoreSpotlight
import MobileCoreServices

class ViewController: UITableViewController {
    
    var projects = [[String]]()
    var favorites = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProjects()
        
        let defaults = UserDefaults.standard
        
        if let savedFavorites = defaults.object(forKey: "favorites") as? [Int] {
            favorites = savedFavorites
        }
        
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }
    
    
    private func setupProjects() {
        projects.append(["Project 1: Storm Viewer", "Constants and variables, UITableView, UIImageView, FileManager, storyboards"])
        projects.append(["Project 2: Guess the Flag", "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+= and -=), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController"])
        projects.append(["Project 3: Social Media", "UIBarButtonItem, UIActivityViewController, the Social framework, URL"])
        projects.append(["Project 4: Easy Browser", "loadView(), WKWebView, delegation, classes and structs, URLRequest, UIToolbar, UIProgressView., key-value observing"])
        projects.append(["Project 5: Word Scramble", "Closures, method return values, booleans, NSRange"])
        projects.append(["Project 6: Auto Layout", "Get to grips with Auto Layout using practical examples and code"])
        projects.append(["Project 7: Whitehouse Petitions", "JSON, Data, UITabBarController"])
        projects.append(["Project 8: 7 Swifty Words", "addTarget(), enumerated(), count, index(of:), property observers, range operators."])
    }
    
    func showProject(_ id: Int) {
        let urlString = "https://www.hackingwithswift.com/read/\(id+1)"
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let svc = SFSafariViewController(url: URL(string: urlString)!, configuration: config)
        present(svc, animated: true)
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if favorites.contains(indexPath.row) {
            cell.editingAccessoryType = .checkmark
        } else {
            cell.editingAccessoryType = .none
        }
        
        let attributedString = NSMutableAttributedString(string: "\(projects[indexPath.row][0])\n", attributes: [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .headline), NSAttributedString.Key.foregroundColor: UIColor.red])
        attributedString.append(NSAttributedString(string: projects[indexPath.row][1], attributes: [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .subheadline)]))
        
        cell.textLabel?.attributedText = attributedString
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showProject(indexPath.row)
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if favorites.contains(indexPath.row) {
            return .delete
        } else {
            return .insert
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            favorites.append(indexPath.row)
            index(item: indexPath.row)
        } else {
            if let index = favorites.firstIndex(of: indexPath.row) {
                favorites.remove(at: index)
                deindex(item: indexPath.row)
            }
        }
        
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: "favorites")
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func index(item: Int) {
        let project = projects[item]
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = project[0]
        attributeSet.contentDescription = project[1]
        
        let item = CSSearchableItem(uniqueIdentifier: "\(item)", domainIdentifier: "me.prudhvi", attributeSet: attributeSet)
        
        CSSearchableIndex.default().indexSearchableItems([item]) { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Indexed")
            }
        }
    }
    
    func deindex(item: Int) {
        
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(item)"]) { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("De-indexed successfully")
            }
        }
        
    }
    
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let action = UITableViewRowAction(style: .normal, title: "Woo") { (action, indexPath) in
//            print(indexPath.row)
//        }
//        action.backgroundColor = .purple
//        return [action]
//    }
}

