// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

/**
 *  Egiftcard's TokenStake smart contract allows users to stake their ERC-20 Tokens
 *  and earn rewards in form of a different ERC-20 token.
 *
 *  note:
 *  - Reward token and staking token can't be changed after deployment.
 *    Reward token contract can't be same as the staking token contract.
 *
 *  - ERC20 tokens from only the specified contract can be staked.
 *
 *  - All token transfers require approval on their respective token-contracts.
 *
 *  - Admin must deposit reward tokens using the `depositRewardTokens` function only.
 *    Any direct transfers may cause unintended consequences, such as locking of tokens.
 *
 *  - Users must stake tokens using the `stake` function only.
 *    Any direct transfers may cause unintended consequences, such as locking of tokens.
 */

interface ITokenStake {
    /// @dev Emitted when contract admin withdraws reward tokens.
    event RewardTokensWithdrawnByAdmin(uint256 _amount);

    /// @dev Emitted when contract admin deposits reward tokens.
    event RewardTokensDepositedByAdmin(uint256 _amount);

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) deposit reward-tokens.
     *
     *          note: Tokens should be approved on the reward-token contract before depositing.
     *
     *  @param _amount     Amount of tokens to deposit.
     */
    function depositRewardTokens(uint256 _amount) external payable;

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) withdraw reward-tokens.
     *          Useful for removing excess balance, thus preventing locking of tokens.
     *
     *  @param _amount     Amount of tokens to deposit.
     */
    function withdrawRewardTokens(uint256 _amount) external;
}
