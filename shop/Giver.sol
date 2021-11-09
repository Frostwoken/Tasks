pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Giver {
    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    function send(address destination, uint128 value) public pure {
        tvm.accept();
        destination.transfer(value, false, 0);
    }

    function sendAndPayFees(address destination, uint128 value) public pure {
        tvm.accept();
        destination.transfer(value, false, 1);
    }

    function sendAllAndDestroy(address destination) public pure {
        tvm.accept();
        destination.transfer(1, false, 128 + 32);
    }
}
