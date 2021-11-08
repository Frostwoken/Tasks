pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "DataStructures.sol";

contract ShoppingList is IShoppingList {
    uint256 ownerPubkey;
    mapping (uint32 => Purchase) m_purchases;
    uint32 purchaseNumber;

    constructor(uint256 pubkey) public {
        require(pubkey != 0, 100);
        tvm.accept();
        ownerPubkey = pubkey;
    }

    modifier onlyOwner() {
    require(msg.pubkey() == ownerPubkey, 101);
    _;
    }

    function addPurchase(string name, uint32 quantity) override public onlyOwner {
        tvm.accept();
        m_purchases[purchaseNumber] = Purchase(purchaseNumber, name, quantity, now, false, 0);
        purchaseNumber++;
    }

    function deletePurchase(uint32 id) override public onlyOwner {
        require(m_purchases.exists(id) && m_purchases[id].isBought != true, 102, "The key does not exist or you are trying to delete" 
                                                                                  "a purchase for which money has already been paid.");
        tvm.accept();
        delete m_purchases[id];
    }

    function buy(uint32 id, uint32 price) override public onlyOwner {
        require(m_purchases.exists(id), 102, "There are no item(s) to buy for this number.");
        tvm.accept();
        m_purchases[id].isBought = true;
        m_purchases[id].price = price;
    }

    function getShoppingList() override public returns (Purchase[] purchases) {
        uint32 number;
        string name;
        uint32 quantity;
        uint32 createdAt;
        bool isBought;
        uint32 price;
        for((, Purchase purchase) : m_purchases) 
        {
            number = purchase.number;
            name = purchase.name;
            quantity = purchase.quantity;
            createdAt = purchase.createdAt;
            isBought = purchase.isBought;
            price = purchase.price;
            purchases.push(Purchase(number, name, quantity, createdAt, isBought, price));
       }
    }

    function getSummary() override public returns (Summary summary) {
        uint32 paidPurchasesNumber;
        uint32 unpaidPurchasesNumber;
        uint32 paidAmount;
        for((, Purchase purchase) : m_purchases) 
        {
            if (purchase.isBought == true)
            {
                paidPurchasesNumber++;
                paidAmount += purchase.price;
            } 
            else
                unpaidPurchasesNumber++;
        }
        summary = Summary(paidPurchasesNumber, unpaidPurchasesNumber, paidAmount);
    }
}