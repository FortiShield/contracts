// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "./IDropClaimCondition.sol";

/**
 *  Egiftcard's 'Drop' contracts are distribution mechanisms for tokens. The
 *  `DropERC721` contract is a distribution mechanism for ERC721 tokens.
 *
 *  A minter wallet (i.e. holder of `MINTER_ROLE`) can (lazy)mint 'n' tokens
 *  at once by providing a single base URI for all tokens being lazy minted.
 *  The URI for each of the 'n' tokens lazy minted is the provided base URI +
 *  `{tokenId}` of the respective token. (e.g. "ipsf://Qmece.../1").
 *
 *  A minter can choose to lazy mint 'delayed-reveal' tokens. More on 'delayed-reveal'
 *  tokens in [this article](https://blog.egiftcard.cc/delayed-reveal-nfts).
 *
 *  A contract admin (i.e. holder of `DEFAULT_ADMIN_ROLE`) can create claim conditions
 *  with non-overlapping time windows, and accounts can claim the tokens according to
 *  restrictions defined in the claim condition that is active at the time of the transaction.
 */

interface IDropERC1155 is IERC1155Upgradeable, IDropClaimCondition {
    struct AllowlistProof {
        bytes32[] proof;
        uint256 maxQuantityInAllowlist;
    }

    /// @dev Emitted when tokens are claimed.
    event TokensClaimed(
        uint256 indexed claimConditionIndex,
        uint256 indexed tokenId,
        address indexed claimer,
        address receiver,
        uint256 quantityClaimed
    );

    /// @dev Emitted when tokens are lazy minted.
    event TokensLazyMinted(uint256 startTokenId, uint256 endTokenId, string baseURI);

    /// @dev Emitted when new claim conditions are set for a token.
    event ClaimConditionsUpdated(uint256 indexed tokenId, ClaimCondition[] claimConditions);

    /// @dev Emitted when the global max supply of a token is updated.
    event MaxTotalSupplyUpdated(uint256 tokenId, uint256 maxTotalSupply);

    /// @dev Emitted when the sale recipient for a particular tokenId is updated.
    event SaleRecipientForTokenUpdated(uint256 indexed tokenId, address saleRecipient);

    /**
     *  @notice Lets an account with `MINTER_ROLE` lazy mint 'n' NFTs.
     *          The URIs for each token is the provided `_baseURIForTokens` + `{tokenId}`.
     *
     *  @param amount           The amount of NFTs to lazy mint.
     *  @param baseURIForTokens The URI for the NFTs to lazy mint.
     */
    function lazyMint(uint256 amount, string calldata baseURIForTokens) external;

    /**
     *  @notice Lets an account claim a given quantity of NFTs.
     *
     *  @param receiver                       The receiver of the NFT to claim.
     *  @param tokenId                        The tokenId of the NFT to claim.
     *  @param quantity                       The quantity of the NFT to claim.
     *  @param currency                       The currency in which to pay for the claim.
     *  @param pricePerToken                  The price per token to pay for the claim.
     *  @param allowlistProof                 The proof of the claimer's inclusion in the merkle root allowlist
     *                                        of the claim conditions that apply.
     *  @param data                           Arbitrary bytes data that can be leveraged in the implementation of this interface.
     */
    function claim(
        address receiver,
        uint256 tokenId,
        uint256 quantity,
        address currency,
        uint256 pricePerToken,
        AllowlistProof calldata allowlistProof,
        bytes memory data
    ) external payable;

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) set claim conditions.
     *
     *  @param tokenId               The token ID for which to set mint conditions.
     *  @param phases                Claim conditions in ascending order by `startTimestamp`.
     *  @param resetClaimEligibility Whether to reset `limitLastClaimTimestamp` and
     *                               `limitMerkleProofClaim` values when setting new
     *                               claim conditions.
     */
    function setClaimConditions(uint256 tokenId, ClaimCondition[] calldata phases, bool resetClaimEligibility) external;
}
