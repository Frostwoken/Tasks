pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

interface IGameObject {
    function takeTheAttack(uint8 damage, address attacker) external;
}