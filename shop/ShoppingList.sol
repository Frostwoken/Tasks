pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "DataStructures.sol";

contract ShoppingList is IShoppingList {
    mapping (uint32 => Purchase) purchases;
    uint32 purchaseNumber;
    uint256 ownerPubkey;

    constructor(uint256 pubkey) public {
        require(pubkey != 0, 100);
        tvm.accept();
        ownerPubkey = pubkey;
    }

    modifier checkOwnerAndAccept {
	    require(msg.pubkey() == tvm.pubkey(), 101);
    	tvm.accept();
	_;
    }

    function addPurchase(string name, uint32 quantity) override public checkOwnerAndAccept {
        if (purchases.empty())
            purchaseNumber = 1;
        purchases[purchaseNumber] = Purchase(purchaseNumber, name, quantity, now, false, 0);
        purchaseNumber++;
    }

    function deletePurchase(uint32 key) override public checkOwnerAndAccept {
        require(purchases.exists(key), 102, "Wrong key.");
        if (key == purchaseNumber - 1)
            purchaseNumber = key;
        delete purchases[key];
    }

    function buy(uint32 key, uint32 price) override public checkOwnerAndAccept {
        require(purchases.exists(key), 103, "Wrong key.");
        purchases[key].isBought = true;
        purchases[key].price = price;
    }

    function getShoppingList() override public view returns (mapping (uint32 => Purchase)) {
        return purchases;
    }

    function getSummary() override public returns (Summary m_summary) {
        uint32 paidPurchasesNumber;
        uint32 unpaidPurchasesNumber;
        uint32 paidAmount;
        for((, Purchase purchase) : purchases) 
        {
            if (purchase.isBought == true)
            {
                paidPurchasesNumber++;
                paidAmount += purchase.price;
            } 
            else
                unpaidPurchasesNumber++;
        }
        m_summary = Summary(paidPurchasesNumber, unpaidPurchasesNumber, paidAmount);
    }
}