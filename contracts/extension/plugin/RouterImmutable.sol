// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author egiftcard

import "./Router.sol";

/**
 *  @author  egiftcard.cc
 */
contract RouterImmutable is Router {
    /*///////////////////////////////////////////////////////////////
                    Constructor + initializer logic
    //////////////////////////////////////////////////////////////*/

    constructor(address _pluginMap) Router(_pluginMap) {}

    /*///////////////////////////////////////////////////////////////
                        Internal functions
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns whether plug-in can be set in the given execution context.
    function _canSetPlugin() internal pure override returns (bool) {
        return false;
    }
}
