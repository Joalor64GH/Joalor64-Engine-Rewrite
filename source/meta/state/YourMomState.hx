package meta.state;

class MyPenis 
{
    public var length:Int = 24;
    public var girth:Int = 5;
    public var insideOf:Dynamic = YourMomState;
}

class YourMomState extends MyPenis
{
    public var name:String = "Miranda";
    public var isSo:String = "fat";
    public var weight:Int = 3540963458; // kg
    public var fuckedBy:String = "me";
    public var cheatedOn:Bool = true;
    private var havingBaby:Bool = true;

    public static var moms = [];

    public function new() {
        moms.push(new YourMomState());
    }

    public static function update(elapsed:Float) {
        if (isSo == 'fat' || fuckedBy != 'me' || weight != 3540963458) {
            moms.push(new YourMomState());
        }
    }
}