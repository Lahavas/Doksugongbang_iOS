//
//  SearchViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: -

enum SearchViewState {
    case barcodeSearching
    case typingSearchingStart
    case showQuickSearch
}

// MARK: -

class SearchViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Outlets

    @IBOutlet var barcodeCameraView: BarcodeCameraView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var quickSearchTableView: UITableView!

    // MARK: Model
    
    let store: BookStore = BookStore.shared
    
    var book: Book!
    var bookList: [Book]!
    
    var searchText: String!
    
    // MARK: Session
    
    let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: AVCaptureSession.self.description(), attributes: [], target: nil)
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "검색"
        
        self.searchBar.delegate = self
        
        self.quickSearchTableView.delegate = self
        self.quickSearchTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpSessionConfiguration()
        self.toggleSearchViewState(.barcodeSearching)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.searchBar.text = ""
        self.toggleSearchViewState(.typingSearchingStart)
    }

    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "ShowDetail":
            guard let bookDetailViewController = segue.destination as? BookDetailViewController else {
                preconditionFailure("Unexpected destination: \(segue.destination)")
            }
            
            bookDetailViewController.book = self.book
        case "Search":
            guard let searchBookListViewController = segue.destination as? SearchBookListViewController else {
                preconditionFailure("Unexpected destination: \(segue.destination)")
            }
            
            searchBookListViewController.searchText = self.searchText
            searchBookListViewController.bookList = self.bookList
        default:
            preconditionFailure("Unexpected Segue Identifier")
        }
    }

    // MARK: - Methods
    
    func setUpSessionConfiguration() {
        
        self.session.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if videoDevice != nil {
            
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice)
            
            if videoDeviceInput != nil {
                if (self.session.canAddInput(videoDeviceInput)) {
                    self.session.addInput(videoDeviceInput)
                }
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (self.session.canAddOutput(metadataOutput)) {
                self.session.addOutput(metadataOutput)
                metadataOutput.metadataObjectTypes = [
                    AVMetadataObjectTypeEAN13Code,
                    AVMetadataObjectTypeQRCode
                ]
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            }
        }
        self.session.commitConfiguration()
        self.barcodeCameraView.layer.session = self.session
        self.barcodeCameraView.layer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
    
    func toggleSearchViewState(_ state: SearchViewState) {
        
        switch state {
        case .barcodeSearching:
            self.sessionQueue.async {
                self.session.startRunning()
            }
            
            self.barcodeCameraView.isHidden = false
            self.quickSearchTableView.isHidden = true
            
            self.view.endEditing(true)
        case .typingSearchingStart:
            self.sessionQueue.async {
                self.session.stopRunning()
            }
            
            self.barcodeCameraView.isHidden = true
            self.quickSearchTableView.isHidden = false
        case .showQuickSearch:
            self.sessionQueue.async {
                self.session.stopRunning()
            }
            
            self.barcodeCameraView.isHidden = true
            self.quickSearchTableView.isHidden = false
        }
    }
}

// MARK: -

extension SearchViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - AV Capture Metadata Output Objects Delegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputMetadataObjects metadataObjects: [Any]!,
                       from connection: AVCaptureConnection!) {
        
        if (metadataObjects.count > 0 && metadataObjects.first is AVMetadataMachineReadableCodeObject) {
            
            guard let scan = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
                return
            }
            
            self.session.stopRunning()
            
            if let isbnString = scan.stringValue {
                
                var bookLookUpURL: URL {
                    
                    return AladinAPI.aladinApiURL(method: .itemLookUp,
                                                  parameters: ["itemIdType": "ISBN13",
                                                               "itemId": isbnString])
                }
                
                self.store.fetchBook(url: bookLookUpURL) {
                    (bookResult) -> Void in
                    
                    switch bookResult {
                    case let .success(book):
                        self.book = book
                        self.performSegue(withIdentifier: "ShowDetail", sender: self)
                    case let .failure(error):
                        print(error)
                    }
                }
            }
        }
    }
}

// MARK: -

extension SearchViewController: UISearchBarDelegate {
    
    // MARK: - Search Bar Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.toggleSearchViewState(.showQuickSearch)
        
        guard let searchText = searchBar.text else {
            preconditionFailure("Unexpected Search Text")
        }
        
        self.searchText = searchText
        
        var bookSearchURL: URL {
            
            return AladinAPI.aladinApiURL(method: .itemSearch,
                                          parameters: ["Query": searchText])
        }
        
        self.store.fetchBookList(url: bookSearchURL) {
            (bookListResult) -> Void in
            
            switch bookListResult {
            case let .success(bookList):
                self.bookList = bookList
                self.performSegue(withIdentifier: "Search", sender: self)
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.toggleSearchViewState(.barcodeSearching)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard let updatedString = searchBar.text else {
            return false
        }
        
        let replacementSearchFieldNumber = updatedString.characters.count
        
        if replacementSearchFieldNumber > 0 && self.session.isRunning {
            self.toggleSearchViewState(.typingSearchingStart)
        }
        
        if replacementSearchFieldNumber > 1 {
            
            var bookSearchURL: URL {
                
                self.searchText = updatedString
                
                return AladinAPI.aladinApiURL(method: .itemSearch,
                                              parameters: ["Query": updatedString,
                                                           "QueryType": "Title"])
            }
            
            self.store.fetchBookList(url: bookSearchURL) {
                (bookListResult) -> Void in
                
                switch bookListResult {
                case let .success(bookList):
                    
                    if bookList.count > 0 {
                        
                        if self.quickSearchTableView.isHidden {
                            self.quickSearchTableView.isHidden = false
                        }
                        self.bookList = bookList
                        self.quickSearchTableView.reloadData()
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }
        
        return true
    }
}

// MARK: -

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let bookList = self.bookList {
            return bookList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "QuickSearchTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? QuickSearchTableViewCell else {
            preconditionFailure("The dequeued cell is not an instance of QuickSearchTableViewCell.")
        }
        
        let book = self.bookList[indexPath.row]
        
        cell.titleLabel.text = book.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let book = self.bookList[indexPath.row]
        
        var bookSearchURL: URL {
            
            self.searchText = book.title
            
            return AladinAPI.aladinApiURL(method: .itemSearch,
                                          parameters: ["Query": book.title])
        }
        
        self.store.fetchBookList(url: bookSearchURL) {
            (bookListResult) -> Void in
            
            switch bookListResult {
            case let .success(bookList):
                
                if bookList.count > 0 {
                    
                    if self.quickSearchTableView.isHidden {
                        self.quickSearchTableView.isHidden = false
                    }
                    self.bookList = bookList
                    self.performSegue(withIdentifier: "Search", sender: self)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
}

