pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

//referenced from https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
contract ThrowProxy {
    address public target;
    bytes data;

    function ThrowProxy(address _target) {
        target = _target;
    }

    function() {
        data = msg.data;
    }

    function execute() returns (bool) {
        return target.call(data);
    }
}

contract TestSupplyChain {


    uint public initialBalance = 10 ether;

    function testItemNotForSale() {
        SupplyChain supplyChainContract = new SupplyChain();
        ThrowProxy throwProxy = new ThrowProxy(address(supplyChainContract));
        SupplyChain(address(throwProxy)).addItem("test1", 15 ether);
        bool r1 = throwProxy.execute.gas(200000)();
        Assert.isTrue(r1, "Transaction adding items should not throw errors");
        SupplyChain(address(throwProxy)).buyItem(6433);
        bool r2 = throwProxy.execute.gas(200000)();
        Assert.isFalse(r2, "forSale modifier should be thrown");
    }

    function testShipItemNotSold() {
        SupplyChain supplyChainContract = new SupplyChain();
        ThrowProxy throwProxy = new ThrowProxy(address(supplyChainContract));
        SupplyChain(address(throwProxy)).addItem("test1", 15 ether);
        bool r1 = throwProxy.execute.gas(200000)();
        Assert.isTrue(r1, "Transaction adding items should not throw errors");
        SupplyChain(address(throwProxy)).shipItem(0);
        bool r2 = throwProxy.execute.gas(200000)();
        Assert.isFalse(r2, "sold modifier should be thrown");
    }

    function testReceivedItemNotShipped() {
        SupplyChain supplyChainContract = new SupplyChain();
        ThrowProxy throwProxy = new ThrowProxy(address(supplyChainContract));
        SupplyChain(address(throwProxy)).addItem("test1", 15 ether);
        bool r1 = throwProxy.execute.gas(200000)();
        Assert.isTrue(r1, "Transaction adding items should not throw errors");
        SupplyChain(address(throwProxy)).receiveItem(0);
        bool r2 = throwProxy.execute.gas(200000)();
        Assert.isFalse(r2, "shipped modifier should be thrown");
    }
     


}
