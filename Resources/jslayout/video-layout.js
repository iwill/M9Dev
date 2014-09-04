/**
 * main
 *
 * ==== DOC ====
 *
 *  JSLayout
 *      @string name;
 *      - (void)layout_setUp(layout);
 *      - (void)cell_setUp(cell);
 *      - (vdoi)cell_prepareForReuse(cell);
 *      - (void)cell_updateWithData(cell, data);
 *
 * ==== API ====
 *
 *  console
 *      - log(NSString *msg);
 *      - dir(NSDictionary *dictionary);
 *
 *  $class
 *      @see http://github.com/iwill/
 *
 */
(function() {
    var fontSize = 14, textMargin = 5;
    
    var JSLayout = $class({
        constructor: function() {
        },
        name: "JSLayout",
        width: 0,
        height: 0,
        placeholderImage: "iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAACXBIWXMAABYlAAAWJQFJUiTwAAAAHGlET1QAAAACAAAAAAAAAAEAAAAoAAAAAQAAAAEAAABDeWVRjwAAAA9JREFUCB1iYGBgaABhAAAAAP//k71SXwAAAAxJREFUY2BgYGgAYQAPEgIBCnYZtgAAAABJRU5ErkJggg==",
        layout_setUp: function(layout) {
            layout.itemSize = { width: this.width, height: this.height };
            layout.js_sectionInset = { top: 7, left: 7, bottom: 7, right: 7 };
            layout.minimumLineSpacing = 6;
            layout.minimumInteritemSpacing = 6;
        },
        cell_setUp: function(cell) {
            var imageView = new UIImageView({ x: 0, y: 0, width: this.width, height: this.height });
            imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            var lableHeight = fontSize + textMargin * 2;
            var titleLabel = new UILabel({ x: 0, y: this.height - lableHeight, width: this.width, height: lableHeight });
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = UIFont.systemFontOfSize(fontSize);
            titleLabel.backgroundColor = UIColor.colorWithHexString("#FFFFFF").colorWithAlphaComponent(0.93);
            titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
            
            cell.addSubviewForKey(imageView, "imageView");
            cell.contentView.addSubview(imageView);
            
            cell.addSubviewForKey(titleLabel, "titleLabel");
            cell.contentView.addSubview(titleLabel);
        },
        cell_prepareForReuse: function(cell) {
            cell.subviewForKey("titleLabel").text = null;
            cell.subviewForKey("imageView").sd_cancelCurrentImageLoad();
            cell.subviewForKey("imageView").image = null;
        },
        cell_updateWithData: function(cell, data) {
            cell.subviewForKey("titleLabel").text = data.album_name;
        }
    });
    
    var JSHorLayout = $class({
        name: "JSHorLayout",
        width: 150,
        height: 124,
        cell_updateWithData: function(cell, data) {
            JSLayout.prototype.cell_updateWithData.apply(this, arguments);
            var url = NSURL.URLWithString(data.hor_high_pic);
            var image = UIImage.imageWithData(NSData.dataWithBase64String(this.placeholderImage || ""));
            cell.subviewForKey("imageView").sd_setImageWithURLPlaceholderImage(url, image);
        }
    }, JSLayout);
    
    var JSVerLayout = $class({
        name: "JSVerLayout",
        width: 98,
        height: 135,
        cell_updateWithData: function(cell, data) {
            JSLayout.prototype.cell_updateWithData.apply(this, arguments);
            var url = NSURL.URLWithString(data.ver_high_pic);
            var image = UIImage.imageWithData(NSData.dataWithBase64String(this.placeholderImage || ""));
            cell.subviewForKey("imageView").sd_setImageWithURLPlaceholderImage(url, image);
        }
    }, JSLayout);
    
    JSLayout.jsLayouts = [ new JSHorLayout(), new JSVerLayout() ];
    
    this.JSLayout = JSLayout;
})();
