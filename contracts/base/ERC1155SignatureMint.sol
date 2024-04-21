// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author egiftcard

import "./ERC1155Base.sol";

import "../extension/PrimarySale.sol";
import "../extension/SignatureMintERC1155.sol";
import { ReentrancyGuard } from "../extension/upgradeable/ReentrancyGuard.sol";
import { CurrencyTransferLib } from "../lib/CurrencyTransferLib.sol";

/**
 *      BASE:      ERC1155Base
 *      EXTENSION: SignatureMintERC1155
 *
 *  The `ERC1155SignatureMint` contract uses the `ERC1155Base` contract, along with the `SignatureMintERC1155` extension.
 *
 *  The 'signature minting' mechanism in the `SignatureMintERC1155` extension uses EIP 712, and is a way for a contract
 *  admin to authorize an external party's request to mint tokens on the admin's contract. At a high level, this means
 *  you can authorize some external party to mint tokens on your contract, and specify what exactly will be minted by
 *  that external party.
 *
 */

contract ERC1155SignatureMint is ERC1155Base, PrimarySale, SignatureMintERC1155, ReentrancyGuard {
    /*//////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        address _primarySaleRecipient
    ) ERC1155Base(_defaultAdmin, _name, _symbol, _royaltyRecipient, _royaltyBps) {
        _setupPrimarySaleRecipient(_primarySaleRecipient);
    }

    /*//////////////////////////////////////////////////////////////
                        Signature minting logic
    //////////////////////////////////////////////////////////////*/

    /**
     *  @notice           Mints tokens according to the provided mint request.
     *
     *  @param _req       The payload / mint request.
     *  @param _signature The signature produced by an account signing the mint request.
     */
    function mintWithSignature(
        MintRequest calldata _req,
        bytes calldata _signature
    ) external payable virtual override nonReentrant returns (address signer) {
        require(_req.quantity > 0, "Minting zero tokens.");

        uint256 tokenIdToMint;
        uint256 nextIdToMint = nextTokenIdToMint();

        if (_req.tokenId == type(uint256).max) {
            tokenIdToMint = nextIdToMint;
            nextTokenIdToMint_ += 1;
        } else {
            require(_req.tokenId < nextIdToMint, "invalid id");
            tokenIdToMint = _req.tokenId;
        }

        // Verify and process payload.
        signer = _processRequest(_req, _signature);

        address receiver = _req.to;

        // Collect price
        _collectPriceOnClaim(_req.primarySaleRecipient, _req.quantity, _req.currency, _req.pricePerToken);

        // Set royalties, if applicable.
        if (_req.royaltyRecipient != address(0)) {
            _setupRoyaltyInfoForToken(tokenIdToMint, _req.royaltyRecipient, _req.royaltyBps);
        }

        // Set URI
        if (_req.tokenId == type(uint256).max) {
            _setTokenURI(tokenIdToMint, _req.uri);
        }

        // Mint tokens.
        _mint(receiver, tokenIdToMint, _req.quantity, "");

        emit TokensMintedWithSignature(signer, receiver, tokenIdToMint, _req);
    }

    /*//////////////////////////////////////////////////////////////
                            Internal functions
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns whether a given address is authorized to sign mint requests.
    function _canSignMintRequest(address _signer) internal view virtual override returns (bool) {
        return _signer == owner();
    }

    /// @dev Returns whether primary sale recipient can be set in the given execution context.
    function _canSetPrimarySaleRecipient() internal view virtual override returns (bool) {
        return msg.sender == owner();
    }

    /// @dev Collects and distributes the primary sale value of NFTs being claimed.
    function _collectPriceOnClaim(
        address _primarySaleRecipient,
        uint256 _quantityToClaim,
        address _currency,
        uint256 _pricePerToken
    ) internal virtual {
        if (_pricePerToken == 0) {
            require(msg.value == 0, "!Value");
            return;
        }

        uint256 totalPrice = _quantityToClaim * _pricePerToken;

        bool validMsgValue;
        if (_currency == CurrencyTransferLib.NATIVE_TOKEN) {
            validMsgValue = msg.value == totalPrice;
        } else {
            validMsgValue = msg.value == 0;
        }
        require(validMsgValue, "Invalid msg value");

        address saleRecipient = _primarySaleRecipient == address(0) ? primarySaleRecipient() : _primarySaleRecipient;
        CurrencyTransferLib.transferCurrency(_currency, msg.sender, saleRecipient, totalPrice);
    }
}
