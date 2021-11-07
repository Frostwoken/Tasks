pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "DataStructures.sol";
import "Initializer.sol";
import "../debots/Debot.sol";
import "../debots/Terminal.sol";
import "../debots/Menu.sol";
import "../debots/AddressInput.sol";
import "../debots/ConfirmInput.sol";
import "../debots/Upgradable.sol";
import "../debots/Sdk.sol";

contract Filler is Initializer {
    string name;
    uint32 quantity;

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
                MenuItem("Add purchase", "", tvm.functionId(enterName)),
                MenuItem("Show shopping list", "", tvm.functionId(getShoppingList)),
                MenuItem("Delete purchase", "", tvm.functionId(enterPurchaseNumberToDelete))
            ]
        );
    }

    function enterName(uint32 index) public {
        Terminal.input(tvm.functionId(enterQuantity), "Enter purchase name.", false);
    }

    function enterQuantity(string value) public {
        name = value;
        Terminal.input(tvm.functionId(addPurchase), "Enter quantity.", false);
    }

    function addPurchase(string value) public {
        (uint result, bool status) = stoi(value);
        if (status == true)
        {
            quantity = uint32(result);
            IShoppingList(contractAddress).addPurchase{
                abiVer: 2,
                sign: true,
                extMsg : true,
                pubkey: 0,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(name, quantity);
        }
        else
            Terminal.input(tvm.functionId(enterQuantity), "Wrong data, try again.\n", false);
    }

    function getShoppingList(uint32 index) public view {
        IShoppingList(contractAddress).getShoppingList{
            abiVer: 2,
            sign: false,
            extMsg : true,
            pubkey: 0,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showShoppingList),
            onErrorId: 0
        }();
    }

    function showShoppingList(Purchase[] purchases) public {
        if (!purchases.empty())
        {
            string completed;
            Terminal.print(0, format("Infromation about your purchases..."));
            for (uint i = 0; i < purchases.length; ++i)
            {
                if (purchases[i].isBought == true)
                    completed = '✓';
                else
                    completed = 'X';
                Terminal.print(0, format("{}: {}, {}, created at {} for price {}. Bought status: {}.", purchases[i].number, purchases[i].name, 
                                                                purchases[i].quantity, purchases[i].createdAt, purchases[i].price, completed));
            }
        } 
        else
            Terminal.print(0, "Your shopping list is empty.");
        showMenu();
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
        (uint number, bool status) = stoi(value);
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
            }(uint32(number));
        }
        else
            Terminal.input(tvm.functionId(enterPurchaseNumberToDelete), "Wrong data, try again.\n", false);
    }
}