pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "DataStructures.sol";
import "../debots/Debot.sol";
import "../debots/Terminal.sol";
import "../debots/Menu.sol";
import "../debots/AddressInput.sol";
import "../debots/ConfirmInput.sol";
import "../debots/Upgradable.sol";
import "../debots/Sdk.sol";

abstract contract ShoppingDebot is Debot, Upgradable {
    TvmCell internal stateInit;
    uint internal userPubkey;
    address internal contractAddress;
    address internal walletAddress;
    Summary internal information;
    uint32 internal constant initialBalance = 200000000; 

    function buildStateInit(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        stateInit = tvm.buildStateInit(code, data);
    }

    function start() override public {
        Terminal.input(tvm.functionId(generateContractAddress), "Please enter your public key.", false);
    }

    function generateContractAddress(string value) public {
        (uint result, bool status) = stoi("0x" + value);
        if (status == true) 
        {
            userPubkey = result;
            Terminal.print(0, "Checking if you already have a shopping list...");
            TvmCell deployState = tvm.insertPubkey(stateInit, userPubkey);
            contractAddress = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format("Your shopping list contract address is {}", contractAddress));
            Sdk.getAccountType(tvm.functionId(checkAccountType), contractAddress);
        } 
        else
            Terminal.input(tvm.functionId(generateContractAddress), "Wrong public key. Try again.\nPlease enter your public key.", false);
    }

    function checkAccountType(int8 acc_type) public {
        if (acc_type == 1) 
            getSummary(tvm.functionId(setSummary));
        else if (acc_type == -1)
        {
            Terminal.print(0, "You don't have a shopping list yet, so a new contract with an initial balance of 0.2 tokens will be deployed.");
            AddressInput.get(tvm.functionId(topUpAccount), "Select a wallet for payment. We will ask you to sign two transactions.");
        } 
        else if (acc_type == 0)
        {
            Terminal.print(0, format("Deploying new contract. If an error occurs, check if your shopping list contract has enough tokens on its balance."));
            deploy();
        } 
        else if (acc_type == 2) 
            Terminal.print(0, format("Can not continue: account {} is frozen.", contractAddress));
    }

    function getSummary(uint32 answerId) internal view {
        optional(uint256) none;
        IShoppingList(contractAddress).getSummary{
            abiVer: 2,
            sign: false,
            extMsg : true,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function setSummary(Summary summary) public {
        information = summary;
        showMenu();
    }

    function topUpAccount(address value) public {
        walletAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        ITransactable(walletAddress).sendTransaction{
            abiVer: 2,
            sign: true,
            extMsg : true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitForMoneyReceipt),
            onErrorId: tvm.functionId(repeatReplenishment)
        }(contractAddress, initialBalance, false, 3, empty);
    }

    function waitForMoneyReceipt() public {
        Sdk.getAccountType(tvm.functionId(checkStatus), contractAddress);
    }

    function checkStatus(int8 acc_type) public {
        if (acc_type ==  0)
            deploy();
        else
            waitForMoneyReceipt();
    }

    function repeatReplenishment(uint32 sdkError, uint32 exitCode) public {
        sdkError;
        exitCode;
        topUpAccount(walletAddress);
    }

    function deploy() internal {
        Terminal.print(0, format("Deploying..."));
        TvmCell deployState = tvm.insertPubkey(stateInit, userPubkey);
        optional(uint256) none;
        TvmCell deployMsg = tvm.buildExtMsg({
            abiVer: 2,
            dest: contractAddress,
            callbackId: 0,
            onErrorId: tvm.functionId(repeatDeploy),
            time: 0,
            expire: 0,
            sign: true,
            pubkey: none,
            stateInit: deployState,
            call: {HasConstructorWithPubKey, userPubkey}
        });
        tvm.sendrawmsg(deployMsg, 1);
        Terminal.print(0, format("Done!"));
        onSuccess();
    }

    function repeatDeploy(uint32 sdkError, uint32 exitCode) public {
        sdkError;
        exitCode;
        deploy();
    }

    function onSuccess() public view {
        getSummary(tvm.functionId(setSummary));
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        showMenu();
    }

    function showMenu() public virtual;

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }
}