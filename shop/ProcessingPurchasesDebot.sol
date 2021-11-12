pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "Header.sol";
import "ShoppingDebot.sol";
import "../debots/Debot.sol";
import "../debots/Terminal.sol";
import "../debots/Menu.sol";

contract ProcessingPurchasesDebot is ShoppingDebot {
    uint32 number;

    function showMenu() override internal {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "Number of paid purchases: {}\nNumber of unpaid purchases: {}\nPaid amount: {}",
                    summary.paidPurchasesNumber,
                    summary.unpaidPurchasesNumber,
                    summary.paidAmount
            ),
            sep,
            [
                MenuItem("Buy", "", tvm.functionId(enterPurchaseNumber)),
                MenuItem("Show shopping list", "", tvm.functionId(getShoppingList)),
                MenuItem("Delete purchase", "", tvm.functionId(enterPurchaseNumberToDelete))
            ]
        );
    }

    function enterPurchaseNumber(uint32 index) public {
        Terminal.input(tvm.functionId(enterPurchasePrice), "Enter purchase number", false);
    }

    function enterPurchasePrice(string value) public {
        (uint result, bool status) = stoi(value);
        if (status == true)
        {
            number = uint32(result);
            Terminal.input(tvm.functionId(buy), "Enter purchase price", false);
        }
        else
            Terminal.input(tvm.functionId(enterPurchaseNumber), "Wrong data, try again\n", false);
    }

    function buy(string value) public {
        (uint price, bool status) = stoi(value);
        if (status == true)
            IShoppingList(contractAddress).buy{
                abiVer: 2,
                sign: true,
                extMsg : true,
                pubkey: 0,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(number, uint32(price));
        else
            Terminal.input(tvm.functionId(enterPurchasePrice), "Wrong data, try again\n", false);
    }

    function getShoppingList(uint32 index) public view {
        optional(uint256) none;
        IShoppingList(contractAddress).getShoppingList{
            abiVer: 2,
            sign: false,
            extMsg : true,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showShoppingList),
            onErrorId: 0
        }();
    }

    function showShoppingList(mapping (uint32 => Purchase) purchases) public {
        if (!purchases.empty())
        {
            string purchaseStatus;
            Terminal.print(0, format("Infromation about your purchases..."));
            optional(uint32, Purchase) keyValuePair = purchases.min();
            while (keyValuePair.hasValue())
            {
                (uint32 key, Purchase purchase) = keyValuePair.get();
                if (purchase.isBought == true)
                    purchaseStatus = "purchased";
                else
                    purchaseStatus = 'not purchased';
                Terminal.print(0, format("{}: {}, {}, created at {} for price {}. Purchase status: {}", purchase.number, purchase.name, 
                                                                purchase.quantity, purchase.createdAt, purchase.price, purchaseStatus));
                keyValuePair = purchases.next(key);
            }
        } 
        else
            Terminal.print(0, "Your shopping list is empty");
        onSuccess();
    }

    function enterPurchaseNumberToDelete(uint32 index) public {
        if (summary.paidPurchasesNumber + summary.unpaidPurchasesNumber > 0)
            Terminal.input(tvm.functionId(deletePurchase), "Enter purchase number", false);
        else 
        {
            Terminal.print(0, "Sorry, you have no purchases to delete");
            showMenu();
        }
    }

    function deletePurchase(string value) public {
        (uint key, bool status) = stoi(value);
        if (status == true)
        {
            IShoppingList(contractAddress).deletePurchase{
                abiVer: 2,
                sign: true,
                extMsg : true,
                pubkey: 0,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(key));
        }
        else
            Terminal.input(tvm.functionId(enterPurchaseNumberToDelete), "Wrong data, try again\n", false);
    }

    function getDebotInfo() public functionID(0xDEB) override view returns(string name, string version, string publisher, string key, string author,
                                                                            address support, string hello, string language, string dabi, bytes icon) 
    {
        name = "Processing purchases DeBot";
        version;
        publisher;
        key;
        author;
        support;
        hello = "Hello!";
        language = "en";
        dabi = m_debotAbi.get();
        icon;
    }
}