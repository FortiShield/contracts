// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

import "contracts/infra/interface/IEgiftcardContract.sol";

// solhint-disable const-name-snakecase
contract MockEgiftcardContract is IEgiftcardContract {
    string public contractURI;
    bytes32 public constant contractType = bytes32("MOCK");
    uint8 public constant contractVersion = 1;

    function setContractURI(string calldata _uri) external {
        contractURI = _uri;
    }
}

contract MockEgiftcardContractV2 is IEgiftcardContract {
    string public contractURI;
    bytes32 public constant contractType = bytes32("MOCK");
    uint8 public constant contractVersion = 2;

    function setContractURI(string calldata _uri) external {
        contractURI = _uri;
    }
}
