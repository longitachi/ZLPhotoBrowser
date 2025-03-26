//
//  ZLEmbedAlbumListView.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/9/7.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import Photos

class ZLEmbedAlbumListView: UIView {
    static let rowH: CGFloat = 60
    
    private var selectedAlbum: ZLAlbumListModel?
    
    private lazy var tableBgView = UIView()
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .zl.albumListBgColor
        view.tableFooterView = UIView()
        view.rowHeight = ZLEmbedAlbumListView.rowH
        view.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        view.separatorColor = .zl.separatorLineColor
        view.delegate = self
        view.dataSource = self
        ZLAlbumListCell.zl.register(view)
        return view
    }()
    
    private var arrDataSource: [ZLAlbumListModel] = []
    
    var selectAlbumBlock: ((ZLAlbumListModel) -> Void)?
    
    var hideBlock: (() -> Void)?
    
    private var orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
    
    init(selectedAlbum: ZLAlbumListModel?) {
        self.selectedAlbum = selectedAlbum
        super.init(frame: .zero)
        setupUI()
        loadAlbumList()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let currOri = UIApplication.shared.statusBarOrientation
        
        guard currOri != orientation else {
            return
        }
        orientation = currOri
        
        guard !isHidden else {
            return
        }
        
        let bgFrame = calculateBgViewBounds()
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: bgFrame.height), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 8, height: 8))
        tableBgView.layer.mask = nil
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        tableBgView.layer.mask = maskLayer
        
        tableBgView.frame = bgFrame
        tableView.frame = tableBgView.bounds
    }
    
    private func setupUI() {
        clipsToBounds = true
        
        backgroundColor = .zl.embedAlbumListTranslucentColor
        
        addSubview(tableBgView)
        tableBgView.addSubview(tableView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    private func loadAlbumList(completion: (() -> Void)? = nil) {
        DispatchQueue.global().async {
            ZLPhotoManager.getPhotoAlbumList(
                ascending: ZLPhotoUIConfiguration.default().sortAscending,
                allowSelectImage: ZLPhotoConfiguration.default().allowSelectImage,
                allowSelectVideo: ZLPhotoConfiguration.default().allowSelectVideo
            ) { [weak self] albumList in
                self?.arrDataSource.removeAll()
                self?.arrDataSource.append(contentsOf: albumList)
                
                ZLMainAsync {
                    completion?()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    private func calculateBgViewBounds() -> CGRect {
        let contentH = CGFloat(arrDataSource.count) * ZLEmbedAlbumListView.rowH
        
        let maxH: CGFloat
        if UIApplication.shared.statusBarOrientation.isPortrait {
            maxH = min(frame.height * 0.7, contentH)
        } else {
            maxH = min(frame.height * 0.8, contentH)
        }
        
        return CGRect(x: 0, y: 0, width: frame.width, height: maxH)
    }
    
    @objc private func tapAction(_ tap: UITapGestureRecognizer) {
        hide()
        hideBlock?()
    }
    
    /// 这里不采用监听相册发生变化的方式，是因为每次变化，系统都会回调多次，造成重复获取相册列表
    func show(reloadAlbumList: Bool) {
        guard reloadAlbumList else {
            animateShow()
            return
        }
        
        if #available(iOS 14.0, *), PHPhotoLibrary.zl.authStatus(for: .readWrite) == .limited {
            loadAlbumList { [weak self] in
                self?.animateShow()
            }
        } else {
            loadAlbumList()
            animateShow()
        }
    }
    
    func hide() {
        var toFrame = tableBgView.frame
        toFrame.origin.y = -toFrame.height
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.tableBgView.frame = toFrame
        }) { _ in
            self.isHidden = true
            self.alpha = 1
        }
    }
    
    private func animateShow() {
        let toFrame = calculateBgViewBounds()
        
        isHidden = false
        alpha = 0
        var newFrame = toFrame
        newFrame.origin.y -= newFrame.height
        
        if newFrame != tableBgView.frame {
            let path = UIBezierPath(
                roundedRect: CGRect(x: 0, y: 0, width: newFrame.width, height: newFrame.height),
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 8, height: 8)
            )
            tableBgView.layer.mask = nil
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            tableBgView.layer.mask = maskLayer
        }
        
        tableBgView.frame = newFrame
        tableView.frame = tableBgView.bounds
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.tableBgView.frame = toFrame
        }
    }
}

extension ZLEmbedAlbumListView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        return !tableBgView.frame.contains(point)
    }
}

extension ZLEmbedAlbumListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ZLAlbumListCell.zl.identifier, for: indexPath) as! ZLAlbumListCell
        
        let m = arrDataSource[indexPath.row]
        
        cell.configureCell(model: m, style: .embedAlbumList)
        
        cell.selectBtn.isSelected = m == selectedAlbum
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let m = arrDataSource[indexPath.row]
        selectedAlbum = m
        selectAlbumBlock?(m)
        hide()
        if let indexPaths = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: indexPaths, with: .none)
        }
    }
}
