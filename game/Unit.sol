pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import "GameObject.sol";
import "Base.sol" as BaseStation;

abstract contract Unit is GameObject {
    address public baseAddress;
    uint8 public damage = 1;

    constructor(BaseStation.Base base) internal {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        base.addUnit(this);
        baseAddress = base;
    }

    function attack(IGameObject target) public {
        tvm.accept();
        target.takeTheAttack(damage, this);
    }

    function getProtectionPower() virtual public;

    function getAttackPower() virtual public;

    function processDeath(address attacker) override internal view {
        BaseStation.Base(baseAddress).removeUnit(this);
        sendAllAndDestroy(attacker);
    }

    function processDeathBecauseOfBase(address sender, address attacker) public view {
        require(sender == baseAddress, 100, "Insufficient rights to delete the unit (you are not the owner of the base on which it is located).");
        processDeath(attacker);
    }
}