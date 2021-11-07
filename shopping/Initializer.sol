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

abstract contract Initializer is Debot, Upgradable {
    bytes m_icon;
    TvmCell internal state;
    uint internal userPubkey;
    address internal contractAddress;
    address internal walletAddress;
    Summary internal information;
    uint32 internal constant initialBalance = 200000000; 

    function setCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        state = tvm.buildStateInit(code, data);
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
            TvmCell deployState = tvm.insertPubkey(state, userPubkey);
            contractAddress = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format("Your shopping list contract address is {}", contractAddress));
            Sdk.getAccountType(tvm.functionId(checkAccountType), contractAddress);
        } 
        else
            Terminal.input(tvm.functionId(generateContractAddress), "Wrong public key. Try again.\nPlease enter your public key.", false);
    }

    function checkAccountType(int8 acc_type) public {
        if (acc_type == 1)  // acc is active and contract is already deployed
            getSummary(tvm.functionId(setSummary));
        else if (acc_type == -1) // acc is inactive
        {
            Terminal.print(0, "You don't have a shopping list yet, so a new contract with an initial balance of 0.2 tokens will be deployed.");
            AddressInput.get(tvm.functionId(topUpAccount), "Select a wallet for payment. We will ask you to sign two transactions.");
        } 
        else if (acc_type == 0)  // acc is uninitialized
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

    function deploy() internal view {
        TvmCell deployState = tvm.insertPubkey(state, userPubkey);
        optional(uint256) none;
        TvmCell deployMsg = tvm.buildExtMsg({
            abiVer: 2,
            dest: contractAddress,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(repeatDeploy),
            time: 0,
            expire: 0,
            sign: true,
            pubkey: none,
            stateInit: deployState,
            call: {HasConstructorWithPubKey, userPubkey}
        });
        tvm.sendrawmsg(deployMsg, 1);
    }

    function repeatDeploy(uint32 sdkError, uint32 exitCode) public view {
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

    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "TODO DeBot";
        version = "0.2.0";
        publisher = "TON Labs";
        key = "TODO list manager";
        author = "TON Labs";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a TODO DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }
}