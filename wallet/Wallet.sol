pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Wallet {
    struct Image {
        string name;
        string description;
        bool isForSale;
        uint price;
    }

    Image[] images;
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

    function createImageToken(string name, string description) public {
        for (uint i = 0; i < images.length; ++i)
            require(images[i].name != name, 100, "Name of your image must be unique.");
        tvm.accept();
        images.push(Image(name, description, false, 0));
        owners[images.length - 1] = msg.pubkey();
    }

    function setImageTokenForSale(uint tokenId, uint price) public {
        require(owners[tokenId] == msg.pubkey(), 100, "You are not the owner of the specified token");
        tvm.accept();
        images[tokenId].isForSale = true;
        images[tokenId].price = price;
    }

    function send(address destination, uint128 value) public pure checkOwnerAndAccept {
        destination.transfer(value, true, 0);
    }

    function sendAndPayFees(address destination, uint128 value) public pure checkOwnerAndAccept {
        destination.transfer(value, true, 1);
    }

    function sendAllAndDestroy(address destination, uint128 value) public pure checkOwnerAndAccept {
        destination.transfer(value, true, 128 + 32);
    }
}
