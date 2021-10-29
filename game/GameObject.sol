pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import "IGameObject.sol";

abstract contract GameObject is IGameObject {
    int32 public health = 5;

    constructor() internal {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    function takeTheAttack(uint8 damage, address attacker) override external {
        tvm.accept();
        health -= damage;
        bool isKilled = checkIfKilled();
        if (isKilled == true)
            processDeath(attacker);
    }

    function checkIfKilled() private view returns (bool) {
        if (health <= 0)
            return true;
        else
            return false;
    }

    function processDeath(address attacker) virtual internal view {
        sendAllAndDestroy(attacker);
    }

    function sendAllAndDestroy(address attacker) internal pure {
        attacker.transfer(1, true, 128 + 32);
    }
}