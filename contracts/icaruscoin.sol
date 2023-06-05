// SPDX-License-Identifier: MIT
//-------------------------------------------------------------------------------------------------------------------------------------
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//-------------------------------------------------------------------------------------------------------------------------------------
// File: contracts/icaruscoin.sol

contract Icarus is ERC20, ERC20Burnable, Ownable {
    uint256 initialSupply = 149597870700 * 10 ** decimals();
    address public immutable dexWallet = <dex_wallet>
    address public immutable cexWallet = <cex_wallet>
    bool public limitTrading = true;
    uint256 public maxHoldingAmount;
    uint256 public minHoldingAmount;
    address public uniswapPool;
    mapping(address => bool) public blacklists;
    address payable public owner = msg.sender;
    uint256 destructBlock = <block>;
    bool destructCondition = false;

    constructor() ERC20("Icarus", "ICARUS") { 
        uint256 creatorSupply = initialSupply / 10;
        uint256 dexSupply = initialSupply * 8 / 10;
        uint256 cexSupply = initialSupply / 10;
        
        _mint(msg.sender, creatorSupply);
        _mint(dexWallet, dexSupply);
        _mint(cexWallet, cexSupply);
    }
    
    // Blacklist
    function blacklist(address _address, bool _isBlacklisting) external onlyOwner {
        blacklists[_address] = _isBlacklisting;
    }   
    
    // Set trading rules
    function setRule(bool _limitTrading, address _uniswapPool, uint256 _maxHoldingAmount, uint256 _minHoldingAmount) external onlyOwner {
        limitTrading = _limitTrading;
        uniswapPool = _uniswapPool;
        maxHoldingAmount = _maxHoldingAmount;
        minHoldingAmount = _minHoldingAmount;
    }
    
    // Initialize liquidity pool
    function _beforeTokenTransfer(address from, address to, uint256 amount) override internal virtual {
        require(!blacklists[to] && !blacklists[from], "Address Blacklisted");

        if (uniswapPool == address(0)) {
            require(from == dexWallet || to == dexWallet, "Token transfer not available");
            return;
        }

        if (limitTrading && from == uniswapPool) {
            require(super.balanceOf(to) + amount <= maxHoldingAmount && super.balanceOf(to) + amount >= minHoldingAmount, "Trading limited");
        }
    }
    
    // Burn token
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
    
    // Renounce contract ownership
    function renounceOwnership() external onlyOwner {
        renounceOwn();
    }
    
    // Set self-destruction
    function setDestruct(bool _destructCondition) public {
        require(msg.sender == owner, "Only the owner can set the condition.");
        destructCondition = _destructCondition;
    }

    //Self-destruct
    function checkDestruct() public {
        require(block.number >= destructBlock, "The Doomsday Block hasn't been reached.");
        require(destructCondition == true, "The condition is not met.");
        selfdestruct(owner);
    } 




}

