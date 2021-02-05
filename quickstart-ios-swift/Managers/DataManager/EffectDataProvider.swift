//
//  EffectDataProvider.swift
//  quickstart-ios-swift
//
//  Created by Pavel Sakhanko on 05/02/2021.
//  Copyright © 2021 Ivan Gulidov. All rights reserved.
//

import UIKit

class EffectDataProvider: NSObject {
    var dataManager = EffectDataManager()
}

extension EffectDataProvider: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataManager.effectArray?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectCollectionViewCell", for: indexPath) as! EffectCollectionViewCell
        let effect = self.dataManager.effectArray?[indexPath.item]

        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = URL(string: effect?.previewImage ?? "") else { return }
            let imageData = try? Data(contentsOf: (url))
            var image: UIImage?
            DispatchQueue.main.async {
                image = imageData != nil ? UIImage(data: imageData!) : UIImage()

                cell.titleLabel.text = effect?.title
                cell.previewImage.image = image
            }
        }
        return cell
    }
}

extension EffectDataProvider: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let effect = self.dataManager.effectArray?[indexPath.item]
        guard let effectName = effect?.title else { return }

        ARCloudManager.loadTappedEffect(effectName: effectName) { (effectUrl) in
            if effectUrl.absoluteString.contains(effectName) {
                NotificationCenter.default.post(name: Notification.Name.newEffectDidLoad, object: self, userInfo: ["name": effectName])
            }
        }
    }
}

extension EffectDataProvider: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            CGSize(width: 180, height: 180)
    }
}
