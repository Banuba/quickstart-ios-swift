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
            guard let url = URL(string: effect?.previewImageStringUrl ?? ""),
                  let imageData = try? Data(contentsOf: url)
            else { return }

            DispatchQueue.main.async {
                cell.titleLabel.text = effect?.title
                cell.previewImage.image = UIImage(data: imageData)
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
