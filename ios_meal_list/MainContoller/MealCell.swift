import UIKit


class MealCell: UICollectionViewCell {
    static let cellIdentifier = "MealCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var mealCategory: String? {
        didSet {
            mealCategoryLabel.text = mealCategory
        }
    }
    
    
    var mealName: String? {
        didSet {
            mealNameLabel.text = mealName
        }
    }
    
    
    private let mealCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.textAlignment = .center
        
        return label
    }()
    
    
    private let mealNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.textAlignment = .center
        
        return label
    }()
    
    
    private func setupViews() {
        mealCategoryLabel.scaleFont(scale: 0.2, view: self)
        mealNameLabel.scaleFont(scale: 0.2, view: self)
        
        addSubview(mealCategoryLabel)
        addSubview(mealNameLabel)
        
        mealCategoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        mealCategoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        mealCategoryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        
        mealNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        mealNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        mealNameLabel.topAnchor.constraint(equalTo: mealCategoryLabel.bottomAnchor, constant: 20).isActive = true
        
        layer.borderWidth = 4
        layer.borderColor = UIColor.black.cgColor
    }
}
