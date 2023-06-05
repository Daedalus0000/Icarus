// SPDX-License-Identifier: MIT
//-------------------------------------------------------------------------------------------------------------------------------------
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

//-------------------------------------------------------------------------------------------------------------------------------------
// CONTRACT
contract Icarus is ERC20, ERC20Burnable, Ownable {
    using SafeMath for uint256;

    uint256 initialSupply;
    
    address payable public owner;
    address public immutable dexWallet;
    address public immutable cexWallet;
    
    mapping(address => bool) public blacklists;
    
    bool public limitTrading;
    uint256 public maxHoldingAmount;
    uint256 public minHoldingAmount;
    address public uniswapPool;
        
    uint256 public immutable creationBlock;
    uint256 public immutable blockLimit;
    uint256 public transactionsCounter;
    uint256 public minTransactions;

    //--------------------------------------------------------------
    // CONSTRUCTOR
    constructor() ERC20("Icarus", "ICARUS") {
        initialSupply = 149597870700 * 10 ** decimals();
        owner = msg.sender;
        dexWallet = <dex_wallet>;
        cexWallet = <cex_wallet>;
        limitTrading = true;
        creationBlock = block.number;
        blockLimit = 2555000;
        minTransactions = 1000000;
        
    
        uint256 creatorSupply = initialSupply / 10;
        uint256 dexSupply = initialSupply * 8 / 10;
        uint256 cexSupply = initialSupply / 10;
        
        _mint(msg.sender, creatorSupply);
        _mint(dexWallet, dexSupply);
        _mint(cexWallet, cexSupply);
    }
    
    //--------------------------------------------------------------
    // BLACKLIST
    function blacklist(address _address, bool _isBlacklisting) external onlyOwner {
        blacklists[_address] = _isBlacklisting;
    }   
    
    //--------------------------------------------------------------
    // SET TRADING RULES
    function setRule(bool _limitTrading, address _uniswapPool, uint256 _maxHoldingAmount, uint256 _minHoldingAmount) external onlyOwner {
        limitTrading = _limitTrading;
        uniswapPool = _uniswapPool;
        maxHoldingAmount = _maxHoldingAmount;
        minHoldingAmount = _minHoldingAmount;
    }
    
    //--------------------------------------------------------------
    // INITIALIZE LIQUIDITY POOL
    function _beforeTokenTransfer(address from, address to, uint256 amount) override internal {
        require(!blacklists[to] && !blacklists[from], "Address Blacklisted");

        if (uniswapPool == address(0)) {
            require(from == dexWallet || to == dexWallet, "Token transfer not available");
            return;
        }

        if (limitTrading && from == uniswapPool) {
            require(super.balanceOf(to) + amount <= maxHoldingAmount && super.balanceOf(to) + amount >= minHoldingAmount, "Trading limited");
        }
    }
    
    //--------------------------------------------------------------    
    // BURN TOKEN
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
    
    //--------------------------------------------------------------
    // RENOUNCE CONTRACT OWNERSHIP
    function renounceOwnership() external onlyOwner {
        renounceOwn();
    }
    
    //--------------------------------------------------------------
    // SET SELF_DESTRUCTION
    function setDestruct(bool _destructCondition) external onlyOwner {
        require(msg.sender == owner, "Only the owner can set the condition.");
        destructCondition = _destructCondition;
    }

    //--------------------------------------------------------------
    // SELF-DESTRUCT
    function selfDestruct() public {
        require(block.number >= creationBlock.add(blocklimit), "The Doomsday Block hasn't been reached.");
        require(destructCondition == true, "The condition is not met.");
        selfdestruct(owner);
    } 




}

