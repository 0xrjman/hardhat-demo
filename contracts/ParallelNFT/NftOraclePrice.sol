// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title A simple on-chain price oracle mechanism
/// @author github.com/drbh
/// @notice Offchain clients can update the prices in this contract. The public can read prices
contract NftOraclePrice is AccessControl {
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

	struct OracleConfig {
		uint256 twapPeriod;
		uint256 emaPeriod;
	}

	struct PriceInformation {
		/// @dev last reported floor price
		uint256 price;
		uint256 twap;
		uint256 ema;
		uint256 blockLast;
	}

	/// @dev address of the NFT contract -> price information
	mapping (address => PriceInformation) priceMap;

	/// @dev storage for oracle configurations
	OracleConfig config;

	constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(UPDATER_ROLE, msg.sender);
	}

	/// @notice Allows owner to set new price on PriceInformation and updates the
	/// internal TWAP cumulativePrice.
	/// @param token The nft contracts to set a floor price for
	/// @param price The last floor price
	/// @param twap The last floor twap
	/// @param ema The last floor ema
	function setPrice(address token, uint256 price, uint256 twap, uint256 ema) onlyRole(UPDATER_ROLE) public {
		/// @dev get storage ref for gas savings
		PriceInformation storage priceMapEntry = priceMap[token];

		/// @dev set values
		priceMapEntry.price = price;
		priceMapEntry.twap = twap;
		priceMapEntry.ema = ema;
		priceMapEntry.blockLast = block.number;
	}

	/// @notice Allows owner to set new price on PriceInformation and updates the
	/// internal TWAP cumulativePrice.
	/// @param tokens The nft contract to set a floor price for
	/// @param prices The last floor prices
	/// @param twaps The last floor twaps
	function setMultiplePrices(address[] calldata tokens, uint256[] calldata prices, uint256[] calldata twaps, uint256[] calldata emas) onlyRole(UPDATER_ROLE) public {
		require(tokens.length == prices.length, "Tokens and price length differ");
		for(uint i; i<tokens.length; i++) {
			setPrice(tokens[i], prices[i], twaps[i], emas[i]);
		}
	}

	/// @notice Allows owner to update oracle configs
	/// @param twapPeriod The period of the time weighted average price
	/// @param emaPeriod The period of the exponential moving average price
	function setConfig(uint256 twapPeriod, uint256 emaPeriod) onlyRole(UPDATER_ROLE) public {
		config.twapPeriod = twapPeriod;
		config.emaPeriod = emaPeriod;
	}

	/// @param token The nft contract
	/// @return price The most recent price on chain
	function getPrice(address token) view public returns(uint256 price) {
		return priceMap[token].price;
	}

	/// @param token The nft contract
	/// @return twap The most recent twap on chain
	function getTwap(address token) view public returns(uint256 twap) {
		return priceMap[token].twap;
	}

	/// @param token The nft contract
	/// @return ema The most recent ema on chain
	function getEma(address token) view public returns(uint256 ema) {
		return priceMap[token].ema;
	}

	/// @param token The nft contract
	/// @return price The last block the price was updated
	function getBlockLast(address token) view public returns(uint256 price) {
		return priceMap[token].blockLast;
	}
}
