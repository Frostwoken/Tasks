pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import 'GameObject.sol';
import 'Unit.sol';

contract Base is GameObject {
    address[] public units;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    function getProtectionPower() public {
        tvm.accept();
        health += 50;
    }

    function addUnit(address unit) public {
        tvm.accept();
        units.push(unit);
    }

    function removeUnit(address unit) public {
        require(units.length != 0, 100, "No units to remove.");
        tvm.accept();
        for (uint8 i = 0; i < units.length; ++i)
        {
            if (units[i] == unit)
            {
                for (uint8 j = i; j < units.length - 1; ++j)
                    units[j] = units[j + 1];
                units.pop();
            }
        }
    }

    function processDeath(address attacker) override internal view {
        tvm.accept();
        for (uint8 i = 0; i < units.length; ++i)
        {
            Unit current = Unit(units[i]);
            current.processDeathBecauseOfBase(this, attacker);
        }
        sendAllAndDestroy(attacker);
    }
}