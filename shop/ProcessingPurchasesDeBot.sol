pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "DataStructures.sol";
import "ShoppingDebot.sol";
import "../debots/Debot.sol";
import "../debots/Terminal.sol";
import "../debots/Menu.sol";
import "../debots/AddressInput.sol";
import "../debots/ConfirmInput.sol";
import "../debots/Upgradable.sol";
import "../debots/Sdk.sol";

contract ProcessingPurchasesDeBot is ShoppingDebot {
    uint32 purchaseNumber;

    function showMenu() override public {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "Number of paid purchases: {}\nNumber of unpaid purchases: {}\nPaid amount: {}.",
                    information.paidPurchasesNumber,
                    information.unpaidPurchasesNumber,
                    information.paidAmount
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
        Terminal.input(tvm.functionId(enterPurchasePrice), "Enter purchase number.", false);
    }

    function enterPurchasePrice(string value) public {
        (uint result, bool status) = stoi(value);
        if (status == true)
        {
            purchaseNumber = uint32(result);
            Terminal.input(tvm.functionId(buy), "Enter purchase price.", false);
        }
        else
            Terminal.input(tvm.functionId(enterPurchaseNumber), "Wrong data, try again.\n", false);
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
            }(purchaseNumber, uint32(price));
        else
            Terminal.input(tvm.functionId(enterPurchasePrice), "Wrong data, try again.\n", false);
    }

    function getShoppingList(uint32 index) public view {
        index = index;
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

    function showShoppingList(Purchase[] purchases) public {
        if (!purchases.empty())
        {
            string purchaseStatus;
            Terminal.print(0, format("Infromation about your purchases..."));
            for (uint i = 0; i < purchases.length; ++i)
            {
                if (purchases[i].isBought == true)
                    purchaseStatus = "purchased";
                else
                    purchaseStatus = 'not purchased';
                Terminal.print(0, format("{}: {}, {}, created at {} for price {}. Purchase status: {}.", purchases[i].number, purchases[i].name, 
                                                                purchases[i].quantity, purchases[i].createdAt, purchases[i].price, purchaseStatus));
            }
        }
        else
            Terminal.print(0, "Your shopping list is empty.");
        onSuccess();
    }

    function enterPurchaseNumberToDelete(uint32 index) public {
        if (information.paidPurchasesNumber + information.unpaidPurchasesNumber > 0)
            Terminal.input(tvm.functionId(deletePurchase), "Enter purchase number.", false);
        else 
        {
            Terminal.print(0, "Sorry, you have no purchases to delete.");
            showMenu();
        }
    }

    function deletePurchase(string value) public {
        (uint id, bool status) = stoi(value);
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
            }(uint32(id));
        }
        else
            Terminal.input(tvm.functionId(enterPurchaseNumberToDelete), "Wrong data, try again.\n", false);
    }

    function getDebotInfo() public functionID(0xDEB) override view returns(string name, string version, string publisher, string key, string author,
                                                                            address support, string hello, string language, string dabi, bytes icon) 
    {
        name = "Processing purchases DeBot";
        hello = "Hi, i'm a processing purchases DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
    }
}