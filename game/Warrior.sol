pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import "Unit.sol";
import "Base.sol";

contract Warrior is Unit {
    constructor(Base base) Unit(base) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    function getProtectionPower() override public {
        tvm.accept();
        health += 10;
    }

    function getAttackPower() override public {
        tvm.accept();
        damage += 1;
    }
}