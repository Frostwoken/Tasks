pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

interface ITransactable {
    function sendTransaction(address destination, uint128 value, bool bounce, uint8 flags, TvmCell payload) external;
}

interface IShoppingList {
    function addPurchase(string name, uint32 quantity) external;
    function deletePurchase(uint32 id) external;
    function buy(uint32 id, uint32 price) external;
    function getShoppingList() external returns (Purchase[] purchases);
    function getSummary() external returns (Summary summary);
}

struct Purchase {
    uint32 number;
    string name;
    uint32 quantity;
    uint32 createdAt;
    bool isBought;
    uint32 price;
}

struct Summary {
    uint32 paidPurchasesNumber;
    uint32 unpaidPurchasesNumber;
    uint32 paidAmount;
}

abstract contract HasConstructorWithPubKey {
   constructor(uint256 pubkey) public {}
}