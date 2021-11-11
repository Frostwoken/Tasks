pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Giver {
    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    function sendTransaction(address dest, uint128 value) public pure {
        tvm.accept();
        dest.transfer(value, false, 1);
    }
}
