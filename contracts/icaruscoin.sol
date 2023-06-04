// SPDX-License-Identifier: MIT
//-------------------------------------------------------------------------------------------------------
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//-------------------------------------------------------------------------------------------------------
// File: contracts/icaruscoin.sol

contract Icarus is ERC20, ERC20Burnable, Ownable {
    uint256 initialSupply = 149597870700 * 10 ** decimals();
    address public immutable dexWallet = <dex_wallet>
    address public immutable cexWallet = <cex_wallet>
    bool public limited;
    uint256 public maxHoldingAmount;
    uint256 public minHoldingAmount;
    address public uniswapV2Pair;
    mapping(address => bool) public blacklists;

    constructor() ERC20("Icarus", "ICARUS") {
        uint256 creatorSupply = initialSupply / 10;
        uint256 dexSupply = initialSupply * 8 / 10;
        uint256 cexSupply = initialSupply / 10;
        
        _mint(msg.sender, creatorSupply);
        _mint(dexWallet, dexSupply);
        _mint(cexWallet, cexSupply);
    }
    
    function blacklist(address _address, bool _isBlacklisting) external onlyOwner {
        blacklists[_address] = _isBlacklisting;
    }   
    
    function setRule(bool _limited, address _uniswapV2Pair, uint256 _maxHoldingAmount, 
    uint256 _minHoldingAmount) external onlyOwner {
        limited = _limited;
        uniswapV2Pair = _uniswapV2Pair;
        maxHoldingAmount = _maxHoldingAmount;
        minHoldingAmount = _minHoldingAmount;
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) override internal virtual {
        require(!blacklists[to] && !blacklists[from], "Blacklisted");

        if (uniswapV2Pair == address(0)) {
            require(from == owner() || to == owner(), "trading not available");
            return;
        }

        if (limited && from == uniswapV2Pair) {
            require(super.balanceOf(to) + amount <= maxHoldingAmount && 
            super.balanceOf(to) + amount >= minHoldingAmount, "Forbidden");
        }
    }
    
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
    
    function renounceOwnership() external onlyOwner {
        renounceOwn();
    }





}

