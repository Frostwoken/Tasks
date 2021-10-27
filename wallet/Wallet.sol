pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Wallet {
    struct Token {
        string name;
        string description;
        bool isForSale;
        uint price;
    }
    Token[] tokens;
    mapping (uint => uint) owners;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    modifier checkOwnerAndAccept {
	require(msg.pubkey() == tvm.pubkey(), 102);
    	tvm.accept();
	_;
    }

    function createToken(string name, string description) public {
        for (uint i = 0; i < tokens.length; ++i)
            require(tokens[i].name != name, 100, "Name of your token must be unique.");
        tvm.accept();
        tokens.push(Token(name, description, false, 0));
        owners[tokens.length - 1] = msg.pubkey();
    }

    function setTokenForSale(uint tokenId, uint price) public {
        require(owners[tokenId] == msg.pubkey(), 100, "You are not the owner of the specified token");
        tvm.accept();
        tokens[tokenId].isForSale = true;
        tokens[tokenId].price = price;
    }

    function send(address destination, uint128 value) public pure checkOwnerAndAccept {
        destination.transfer(value, true, 0);
    }

    function sendAndPayFees(address destination, uint128 value) public pure checkOwnerAndAccept {
        destination.transfer(value, true, 1);
    }

    function sendAllAndDestroy(address destination) public pure checkOwnerAndAccept {
        destination.transfer(1, true, 128 + 32);
    }
}
