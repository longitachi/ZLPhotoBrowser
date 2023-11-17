//
//  ZLEditorManager.swift
//  ZLPhotoBrowser
//
//  Created by long on 2023/9/25.
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

import Foundation

public enum ZLEditorAction {
    case draw(ZLDrawPath)
    case eraser([ZLDrawPath])
    case clip(oldStatus: ZLClipStatus, newStatus: ZLClipStatus)
    case sticker(oldState: ZLBaseStickertState?, newState: ZLBaseStickertState?)
    case mosaic(ZLMosaicPath)
    case filter(oldFilter: ZLFilter?, newFilter: ZLFilter?)
    case adjust(oldStatus: ZLAdjustStatus, newStatus: ZLAdjustStatus)
}

protocol ZLEditorManagerDelegate: AnyObject {
    func editorManager(_ manager: ZLEditorManager, didUpdateActions actions: [ZLEditorAction], redoActions: [ZLEditorAction])
    
    func editorManager(_ manager: ZLEditorManager, undoAction action: ZLEditorAction)
    
    func editorManager(_ manager: ZLEditorManager, redoAction action: ZLEditorAction)
}

class ZLEditorManager {
    private(set) var actions: [ZLEditorAction] = []
    private(set) var redoActions: [ZLEditorAction] = []
    
    weak var delegate: ZLEditorManagerDelegate?
    
    init(actions: [ZLEditorAction] = []) {
        self.actions = actions
        redoActions = actions
    }
    
    func storeAction(_ action: ZLEditorAction) {
        actions.append(action)
        redoActions = actions
        
        deliverUpdate()
    }
    
    func undoAction() {
        guard let preAction = actions.popLast() else { return }
        
        delegate?.editorManager(self, undoAction: preAction)
        deliverUpdate()
    }
    
    func redoAction() {
        guard actions.count < redoActions.count else { return }
        
        let action = redoActions[actions.count]
        actions.append(action)
        
        delegate?.editorManager(self, redoAction: action)
        deliverUpdate()
    }
    
    private func deliverUpdate() {
        delegate?.editorManager(self, didUpdateActions: actions, redoActions: redoActions)
    }
}
